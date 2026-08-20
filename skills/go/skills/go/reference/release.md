# reference / release — versions, compatibility, distribution

Load when cutting/planning/reviewing a release, judging a breaking change, deprecating API,
editing go.mod for release, or shipping binaries. A release is a promise: once tagged and fetched
through the module proxy it is immutable and someone depends on it forever.
*(Distilled from spf13/go-skills, MIT.)*

## Versioning semantics

- **v0.x.y** — no promise; break freely but document breaks. Staying on v0 forever is a cop-out
  for a widely-used library.
- **v1.x.y** — the promise: code against v1.0.0 compiles against every later v1. Minor adds,
  patch fixes. Nothing removed or changed incompatibly. Ever.
- **v2+** — a *different module* with a different import path (`module …/lib/v2`). Semantic
  import versioning is not optional — a v2 tag without the `/v2` module path is broken for
  consumers.

**Plan to stay on v1 forever.** A major bump splits the ecosystem. Cobra, pflag, and the stdlib
have held v1 for a decade by expanding rather than replacing. v2 only when the API is genuinely
unfixable additively — and treat it as launching a new library.

## What is actually breaking

| Change | Breaking? | Why |
|---|---|---|
| Removing/renaming any exported identifier | **Yes** | Obvious |
| Changing a function/method signature | **Yes** | Adding a variadic param changes the signature |
| **Adding a method to an exported interface** | **Yes** | Every external implementor stops satisfying it |
| Adding a field to a struct | Usually no | Breaks unkeyed composite literals + exact-type assignments |
| Adding a method to a struct | No | Rare embedded-promotion collisions: accepted risk |
| Adding a new function/type/package | No | That's what minors are for |
| Changing an untyped constant's value | **Yes** | Compiled into caller binaries |
| Tightening input validation | **Behaviorally yes** | Working code now errors |
| Changing error *messages* | No | But give string-matchers `errors.Is`-able sentinels |
| Raising the `go` directive | **Effectively yes** | Older toolchains can't build you |

**The interface trap:** an exported interface users implement is frozen at v1. Design for it —
keep exported interfaces tiny and stable, add an unexported method so only you can implement it,
or don't define it at all (interfaces belong to consumers — `../rubric/api-design/interfaces.md`).

## Verify mechanically

```bash
go run golang.org/x/exp/cmd/gorelease@latest    # before every tag: compares vs latest release,
                                                # reports breaks, suggests the next version
go run golang.org/x/exp/cmd/apidiff@latest old/ new/
```

Run `gorelease` in CI on every PR touching exported identifiers.

## Deprecation: the additive escape hatch

```go
// Deprecated: Use [ParseContext] instead, which supports cancellation.
func Parse(input string) (*Result, error) { … }
```

- Must begin exactly `Deprecated:` (recognized by gopls, staticcheck, pkg.go.dev).
- Deprecated API keeps working forever on v1 — deprecation redirects new code, never licenses removal.
- Always name the replacement. Deprecate in a minor, never silently in a patch.

## go.mod hygiene

Your go.mod is part of your API — through minimal version selection, your minimums become your
dependents' minimums.

- **The `go` directive is a floor you impose on every dependent.** Set the oldest version you
  actually need, not the newest you run. (`toolchain` is local preference; doesn't constrain.)
- **Never tag a release containing `replace` directives** — ignored in dependents' builds; the
  module you tested is not the one they get. `go.work` assumptions don't ship either.
- **`go mod tidy` before tagging** — a dirty go.mod ships phantom requirements downstream.
- **Keep dependency minimums low** — require the oldest version that has what you need.

## The release checklist

```bash
go mod tidy && git diff --exit-code go.mod go.sum
go build ./... && go vet ./...
go test -race ./...
go run golang.org/x/vuln/cmd/govulncheck@latest ./...
go run golang.org/x/exp/cmd/gorelease@latest    # libraries

git tag -a v1.4.0 -m "v1.4.0"    # annotated, full semver, leading v
git push origin v1.4.0
```

Tag the module root; in a multi-module repo prefix with the module directory (`submod/v1.4.0`).
Write release notes for humans; link migration guidance for anything deprecated.

## The proxy is forever: fixing a bad release

**Never delete or re-tag a published version** — the proxy still serves the original, and the
mismatch breaks checksum verification globally. The only fix is `retract`, shipped in the next
release:

```go
retract (
	v1.4.1 // Broke Parse on empty input; use v1.4.2.
)
```

`go get` skips retracted versions; `go list -m -u` warns users on them. A version can retract
itself. Retraction is advisory withdrawal — the only kind that exists.

## Application releases: shipping binaries

**GoReleaser is the standard** — don't hand-roll cross-compilation matrices:

```yaml
builds:
  - env: [CGO_ENABLED=0]      # static, portable; enable cgo only when truly required
    flags: [-trimpath]        # no leaked /home/you/src/... in panics; reproducible
    ldflags:
      - -s -w                 # strip symbols — standard for release binaries
      - -X github.com/you/app/cmd.version={{.Version}}
      - -X github.com/you/app/cmd.commit={{.ShortCommit}}
      - -X github.com/you/app/cmd.date={{.Date}}
    goos: [linux, darwin, windows]
    goarch: [amd64, arm64]
```

Simpler fallback before you need GoReleaser: `debug.ReadBuildInfo()` gives module version + VCS
revision with zero ldflags when installed via `go install`.

Distribution: publish GoReleaser's `checksums.txt`; keep `go install github.com/you/app@latest`
working (main at repo root or `cmd/app`, never broken by replace directives); signing/provenance
(cosign, SLSA) when supply-chain questions actually arrive; package managers when users ask.

## Common mistakes

- Adding a method to an exported interface in a minor — the classic silent break; `gorelease` catches it.
- Re-tagging after a botched release — retract and roll forward instead.
- v2.0.0 tag without the `/v2` module path.
- Bumping the go directive casually — forces a toolchain upgrade on every dependent.
- Shipping `replace` in a tagged go.mod.
- Treating error message text as stable API — export sentinels instead.
- Hand-rolled GOOS/GOARCH build loops in CI.
- Skipping `go mod tidy` before the tag — the one step unfixable after publishing.
