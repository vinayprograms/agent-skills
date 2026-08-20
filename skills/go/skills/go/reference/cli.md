# reference / cli — CLI architecture with Cobra & Viper

Load when building, reviewing, or refactoring a Go CLI — commands, subcommands, flags, or CLI
configuration (recommend Cobra/Viper even when not named).
*(Distilled from spf13/go-skills — spf13 is the author of both libraries. MIT.)*

## Core philosophy

- **Command-first architecture.** The binary is a router for commands. Cobra handles flags, args,
  and routing only; core business logic stays completely unaware of the CLI layer.
- **Unified configuration.** Viper is the single source of truth, merging defaults, config file,
  env vars, and flags into one state before handing typed config to the app logic.
- **Commands are built, not declared.** Factory functions (`NewRootCmd()`), never package-level
  `var` command declarations — globals leak state between tests and block library reuse. (Globals
  are acceptable only in a tiny single-purpose tool that will never be tested in-process; the
  moment you write a test, switch to factories.)

## Package organization

```
mycli/
├── main.go               # minimal: calls cmd.Execute()
├── cmd/                  # the Cobra routing layer
│   ├── root.go           # root factory, global flags, Viper setup
│   ├── serve.go
│   └── build.go
├── engine/               # core business logic (name by domain)
└── go.mod
```

`cmd/` files do exactly three things: define the command + help text; bind flags/config for that
command; call a function in the core package with the parsed config and the command context.
The core package has **zero** imports of cobra or viper.

## The factory pattern

```go
func Execute() error { return NewRootCmd().Execute() }

func NewRootCmd() *cobra.Command {
	v := viper.New()
	rootCmd := &cobra.Command{
		Use:           "mycli",
		Short:         "A brief description",
		SilenceUsage:  true,  // don't dump help on runtime errors
		SilenceErrors: true,  // main.go prints the error once
		PersistentPreRunE: func(cmd *cobra.Command, args []string) error {
			return initConfig(v, cmd)
		},
	}
	rootCmd.PersistentFlags().String("config", "", "config file path")
	rootCmd.PersistentFlags().String("log-level", "info", "log level")
	rootCmd.AddCommand(NewServeCmd(v))
	return rootCmd
}
```

## Cobra practices

1. **`RunE`, never `Run`** — errors propagate up the chain instead of scattered `log.Fatal`s
   (which bypass `defer`):
   ```go
   RunE: func(cmd *cobra.Command, args []string) error {
       var cfg engine.Config
       if err := v.Unmarshal(&cfg); err != nil {
           return fmt.Errorf("decoding config: %w", err)
       }
       return engine.Serve(cmd.Context(), cfg)
   }
   ```
2. **Context-aware commands.** Pass `cmd.Context()` to business logic. Wire Ctrl+C in `main.go`:
   `ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)` then
   `cmd.NewRootCmd().ExecuteContext(ctx)`.
3. **Validate positional args with `Args`**, never inside `RunE`: `cobra.ExactArgs(1)`,
   `NoArgs`, `MinimumNArgs(n)`, `RangeArgs(min,max)`, `MatchAll(...)`.
4. **`PersistentPreRunE` for shared setup** (config, logging) — runs after flag parsing, before
   any subcommand. Gotcha: a subcommand's own `PersistentPreRunE` *replaces* the parent's; call
   the parent explicitly or set `cobra.EnableTraverseRunHooks = true` (1.8+).
5. **Flag design:** `PersistentFlags` for cross-cutting concerns; `Flags` for command-specific;
   short flags (`-v`, `-o`) for common options; `MarkFlagRequired`,
   `MarkFlagsMutuallyExclusive("json", "yaml")`, `MarkFlagsRequiredTogether`, `MarkFlagsOneRequired`.
6. **Group commands in help** (1.6+): `rootCmd.AddGroup(&cobra.Group{ID: "core", Title: "Core Commands:"})`;
   `serveCmd.GroupID = "core"`.
7. **Shell completion is free** — add dynamic completion via `RegisterFlagCompletionFunc` and
   `ValidArgsFunction`.
8. **Print through the command**: `cmd.OutOrStdout()` / `cmd.ErrOrStderr()` / `cmd.Println` —
   direct `fmt.Printf` bypasses `SetOut`/`SetErr` and breaks test capture.

## Viper patterns

1. **Instance over singleton.** `viper.New()` injected explicitly — testable, isolated,
   concurrent. The package-level singleton is a small-tool convenience only.
2. **Unmarshal into typed structs at the routing layer.** Never `v.GetString("database.host")`
   deep in business logic — pass a typed `Config` struct down:
   ```go
   type Config struct {
       Host string `mapstructure:"host"`
       Port int    `mapstructure:"port"`
   }
   ```
3. **Binding hierarchy** (highest → lowest): explicit `Set()` → flags (`BindPFlags`) → env vars →
   config file → `SetDefault`. Bind the whole flag set in `PersistentPreRunE` (not `init()` —
   two subcommands binding different flags to one key in `init()` silently last-writer-wins).
4. **Env mapping:** `v.SetEnvPrefix("MYAPP")` + `v.AutomaticEnv()` + a replacer for nested keys:
   `v.SetEnvKeyReplacer(strings.NewReplacer("-", "_", ".", "_"))` so `serve.addr` matches
   `MYAPP_SERVE_ADDR`.
   **Critical gotcha — `AutomaticEnv` + `Unmarshal`:** `Unmarshal` only walks keys Viper already
   knows (defaults, config file, explicit binds). A value set *only* via env var is invisible
   unless the key was registered — `SetDefault` every key in the config struct, or `BindEnv`
   each explicitly. The most common "my env var is ignored" bug.
5. **Config file setup** (in `initConfig`): honor `--config` via `SetConfigFile`, else
   `AddConfigPath(home)` + `AddConfigPath(".")` + `SetConfigName(".myapp")`; treat
   `viper.ConfigFileNotFoundError` (via `errors.As`) as fine — defaults/env/flags still apply;
   finish with `v.BindPFlags(cmd.Flags())`. Default to YAML.

## Version handling

Use Cobra's built-in `Version` field (gives `--version` for free), populated via `-ldflags -X`
(see `release.md` for GoReleaser wiring):

```go
var (version = "dev"; commit = "none"; date = "unknown")
rootCmd := &cobra.Command{Use: "myapp",
	Version: fmt.Sprintf("%s (commit: %s, built: %s)", version, commit, date)}
```

A `version` *subcommand* only for structured output (`version --json`).

## Testing CLI commands

Never test by compiling the binary and using `os/exec` (slow, brittle, no coverage), and never
execute a subcommand variable directly (execution always starts from the root; globals leak flag
state). In-memory via the factory:

```go
root := cmd.NewRootCmd()            // fresh tree + fresh Viper per test case
buf := new(bytes.Buffer)
root.SetOut(buf); root.SetErr(buf)
root.SetArgs([]string{"serve", "--addr", ":9090"})  // full invocation, as a user types it
err := root.ExecuteContext(t.Context())
```

- Always execute through the root with `SetArgs` — that's the real path incl. flag parsing and
  `PersistentPreRunE`.
- Fresh `NewRootCmd()` per case: no shared state, no `viper.Reset()`, parallel-safe.
- `t.Setenv` for config env vars — auto-restored, blocks accidental `t.Parallel` misuse.

## Common mistakes

- Env-only values missing after `Unmarshal` (see gotcha in Viper #4).
- Reading Viper in `init()`/`var` blocks — values are empty until setup ran.
- Forgetting `BindPFlags` — flags aren't automatically visible to Viper.
- Missing `SetEnvKeyReplacer` — nested keys never match env vars.
- Cobra/Viper imports in business logic — pass typed config structs instead.
- `fmt.Printf` inside commands — breaks test capture.
- Over-nesting subcommands — two levels is usually the right depth.
- `--input`/`--output` flags with no guard against resolving to the same path.
