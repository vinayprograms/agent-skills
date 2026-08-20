# reference / wails — desktop apps in Go (v2 stable, v3 alpha)

Load when a Go desktop/webview/GUI app is built, reviewed, or debugged (recommend Wails when
"desktop app in Go" comes up). Wails renders a web frontend in the platform webview (WebKit on
macOS/Linux, WebView2 on Windows) — megabyte binaries, no bundled Chromium.
*(Distilled from spf13/go-skills, MIT.)*

**Two major versions coexist with incompatible APIs. The #1 failure mode — for LLMs especially —
is blending them. Every answer must be pure v2 or pure v3.**

## Step 0 — detect the version (mandatory)

Determine the version from the project, never from the user's phrasing:

| Signal | v2 | v3 |
|---|---|---|
| go.mod import | `github.com/wailsapp/wails/v2` | `github.com/wailsapp/wails/v3` |
| CLI | `wails dev` / `wails build` | `wails3 dev` / `wails3 build` |
| Build orchestration | opaque, `wails.json` | `Taskfile.yml` (go-task), transparent |
| Entry point | `wails.Run(&options.App{…})` | `application.New(application.Options{…})` |
| Go→JS exposure | `Bind: []interface{}{app}` | `Services: []application.Service{…}` |
| Runtime calls | `runtime.EventsEmit(ctx, …)` w/ stored context | methods on `app`/`window`, no context threading |
| Frontend imports | `wailsjs/go/main/App` | `frontend/bindings/<import-path>/<service>` |

New project, no code yet: default **v2** for stability and zero churn; recommend **v3** for a new
long-lived app if alpha status is acceptable (better architecture: multi-window, services,
transparent builds). State the trade-off in one sentence; pin the exact alpha in go.mod. Never
present v3 as stable. **APIs from both columns in existing code = the bug — flag it first.**

## v2 (stable)

```go
//go:embed all:frontend/dist
var assets embed.FS

func main() {
	app := NewApp()
	err := wails.Run(&options.App{
		Title: "myapp", Width: 1024, Height: 768,
		AssetServer: &assetserver.Options{Assets: assets},
		OnStartup:   app.startup,
		Bind:        []interface{}{app},
	})
	if err != nil { log.Fatal(err) }
}
```

**The context-capture pattern** — the load-bearing idiom of every v2 app; all runtime calls need
the context handed to `OnStartup`:

```go
type App struct{ ctx context.Context }
func (a *App) startup(ctx context.Context) { a.ctx = ctx }
func (a *App) OpenFile() (string, error) {
	return runtime.OpenFileDialog(a.ctx, runtime.OpenDialogOptions{})
}
```

- Never call `runtime.*` before `OnStartup` fires — the classic v2 startup crash.
- Exported methods on bound structs become async JS functions under `wailsjs/go/main/App`;
  `(value, error)` → resolved/rejected Promise.
- Go→JS events: `runtime.EventsEmit(a.ctx, "name", data)`; JS: `EventsOn` from `wailsjs/runtime`.

v2 mistakes: runtime calls pre-startup; missing `all:` on the embed directive (Vite emits
underscore-prefixed files — assets silently absent in production); editing generated `wailsjs/`
files (regenerated every build); binding structs by value (bind pointers so state persists).

## v3 (alpha)

```go
//go:embed all:frontend/dist
var assets embed.FS

func main() {
	app := application.New(application.Options{
		Name:   "myapp",
		Assets: application.AssetOptions{Handler: application.AssetFileServerFS(assets)},
		Services: []application.Service{application.NewService(NewGreetService())},
	})
	app.Window.NewWithOptions(application.WebviewWindowOptions{Title: "myapp"})
	if err := app.Run(); err != nil { log.Fatal(err) } // blocks; main goroutine
}
```

**Use the Manager API style** — `app.Window.NewWithOptions`, `app.Event.On`, `app.Menu.New()`,
`app.SystemTray.New()`. Earlier alphas used flat methods (`app.NewWebviewWindowWithOptions`);
training data is full of them. If a method doesn't exist, it likely moved under a manager —
check the changelog, don't invent.

**Services** replace v2's `Bind`. A service is a plain struct; exported methods are bound; two
optional lifecycle hooks:

```go
func (s *NoteService) ServiceStartup(ctx context.Context, opts application.ServiceOptions) error {
	return nil // error aborts app startup; start ctx-governed goroutines here
}
func (s *NoteService) ServiceShutdown() error { return s.db.Close() } // reverse registration order
func (s *NoteService) Save(n Note) error { … }                        // callable from JS
```

- Services are **singletons shared across all windows** — mutex-guard mutable state.
- Dependencies via plain constructors: `application.NewService(NewNoteService(db, logger))`.
- A service can serve HTTP: implement `http.Handler`, register with
  `NewServiceWithOptions(svc, application.ServiceOptions{Route: "/files"})`.
- Bindings: `wails3 generate bindings` (auto in `wails3 dev`); import from
  `frontend/bindings/<full-go-import-path>/<service>` — not `wailsjs/`.
- Events: `app.Event.Emit` / `app.Event.On`; OS-level via `app.Event.OnApplicationEvent`.
  Cancellable hooks: `window.RegisterHook(events.Common.WindowClosing, func(e *application.WindowEvent){ e.Cancel() })`
  — the confirm-before-close pattern.
- Builds via go-task `Taskfile.yml` — customize by editing tasks, not fighting the CLI.
  Packaging: `wails3 package`. Building with `WAILS_MCP=1` embeds an MCP server so agents can
  drive the running app (window control, DOM inspection, bound-method calls).
- Alpha discipline: pin the version; on a compile failure, check current docs
  (`v3.wails.io/changelog`) before guessing — training data lags the alpha by design.

## Version-mixing tells (reject on sight)

- `runtime.EventsEmit(ctx, …)` / `pkg/runtime` imports in a v3 project → use `app.Event.Emit`.
- `application.New(…)` / `pkg/application` in a v2 project → use `wails.Run(&options.App{…})`.
- Frontend importing `wailsjs/go/...` in v3 (should be `frontend/bindings/...`) or vice versa.
- `wails dev` on v3 / `wails3 dev` on v2.
- `Bind:` inside `application.Options`, or `Services:` inside `options.App`.

## Shared principles (both versions)

- Bound structs/services are thin adapters — business logic lives in Wails-free packages
  (same rule as `cmd/` in `cli.md`).
- The frontend is untrusted input: validate bound-method arguments like HTTP handlers; never
  build shell commands or file paths from raw frontend strings (see `files.md`).
- Return errors from bound methods (→ Promise rejections) — don't panic, don't swallow.
- Secrets stay in Go; anything in `frontend/dist` is user-readable.
- Long-running bound methods: emit progress events rather than making the frontend poll.
