# reference / files — safe file operations (fileflow & pathologize)

Load when Go code moves, copies, renames, downloads, extracts, or generates files, or builds a
destination path from untrusted input (user data, scraped names, regex captures) — including any
`EXDEV`/"invalid cross-device link" or "file already exists" handling. Two small composable
libraries close the gaps naive `os.Rename` + `io.Copy` + `filepath.Clean` code gets wrong.
*(Distilled from spf13/go-skills — spf13 is the author of both. MIT.)*

Why not stdlib alone: `os.Rename` fails across filesystems (`EXDEV`) and silently overwrites;
`filepath.Clean` normalizes `..` but leaves characters illegal on *other* OSes and reserved names
(`CON`, `NUL`) — a name fine on Linux breaks when it syncs to a Windows client.

## The core pattern: join a trusted root with untrusted parts, then move

```go
// destRoot is trusted (configured); id/name are untrusted.
dstDir := pathologize.Join(destRoot, "ig", id)   // parts sanitized + contained under root
dst := filepath.Join(dstDir, filepath.Base(src))

final, err := fileflow.Move(src, dst)            // cross-fs safe, conflict safe
// final is where the file actually landed (may be suffixed on conflict).
```

`fileflow.Move` creates missing destination directories — no separate `os.MkdirAll`.

## fileflow

```go
func Move(src, dst string) (string, error)    // rename if same FS, else copy+delete
func Rename(src, dst string) (string, error)  // same-FS only; fails cross-device
func Copy(src, dst string) (string, error)    // atomic copy
func Exists(path string) bool                 // accessible regular file only (false for dirs)
func Equal(f1, f2 string) (bool, error)       // byte-for-byte
```

All three return the **final destination path** — always use it; never assume the file landed at
`dst`. Prefer `Move` unless you specifically want cross-filesystem failure.

**Conflict handling (the key feature).** When `dst` exists, fileflow never blindly overwrites:
identical file → `Copy` is a no-op returning `dst`, `Move`/`Rename` remove `src`; differing file →
incrementing suffix (`photo.jpg` → `photo-1.jpg`, up to 100 candidates, limit not configurable).

**Configure per instance with `Flow`** (zero value ready to use):

```go
f := fileflow.Flow{
	FindAvailableName: fileflow.FindAvailableNameAuto, // nil → FindAvailableNameInc
	DirMode:           0o700,                          // zero → DefaultDirMode (0o755)
	NoCreateDirs:      true,  // dest dirs must pre-exist (e.g. required mount points);
	                          // else error matching fs.ErrNotExist via errors.Is
}
final, err := f.Move(src, dst)
```

Configure before first use; don't mutate while running. The old mutable package globals and
`CopyWithPaths` are gone (`Copy` creates parents itself).

Naming strategies: `FindAvailableNameInc` (default — preserve full name, append `-1, -2…`);
`FindAvailableNameCont` (continue a trailing counter: `file-3.txt` → `file-4.txt`, but treats
`report-2024.txt` as a counter too); `FindAvailableNameAuto` (continues 1–2-digit counters,
preserves years/IDs of 3+ digits); `FindAvailableNameTS` (nanosecond timestamp); or any
`func(string) (string, error)`.

Write safety: `Rename` uses no-replace primitives (Windows `MoveFileEx` without replace; Unix
atomic link-and-remove; best-effort fallback on FAT/network mounts). `Copy` writes a temp file in
the destination dir, syncs, preserves the source mode, renames into place — a failed copy never
exposes a partial destination or leaves its temp file.

Errors: `fileflow.ErrSameFile` (detects equivalent paths, symlinks, case-only differences — treat
as no-op success only when that matches the caller's semantics), `ErrMaxAttemptsReached`
(`errors.Is`); `*ErrFailedMovingFile{Src, Dst, Err}`, `*ErrFailedRemovingOriginal{File, Err}`
(`errors.As`) — the latter can accompany a returned final path (content arrived; source
couldn't be deleted).

## pathologize

Make a name or path safe on **every** modern OS, not just the host. Intentionally restrictive.

```go
func Clean(filename string) string             // sanitize ONE name/segment
func CleanPath(path string) string             // make a full path VALID (volume-aware) — NOT safe
func Join(root string, parts ...string) string // trusted root + untrusted parts, contained
func IsClean(filename string) bool
```

`Clean`: strips control chars plus `` \ / : * ? " < > | ``; invalid UTF-8 → U+FFFD;
trims leading/trailing whitespace and trailing dots; caps at 255 bytes; defuses reserved device
names (`CON` → `CON_`); idempotent; never returns empty (falls back to `"file"`).

**`Join` — the safe default for building destinations.** `root` passes through **verbatim**
(must be trusted — separators/drive prefix preserved, never sanitized); each `part` is split on
`/` and `\`, structural segments (empty, `.`, `..`) dropped, every remaining segment `Clean`ed.
The result is guaranteed lexically **under** `root` — a part cannot escape it or inject an
absolute path:

```go
pathologize.Join("/data", "../../etc", "pass:wd")   // "/data/etc/passwd" — contained + cleaned
pathologize.Join(`C:\Sorted`, "ig", userName)       // root verbatim, userName sanitized
```

**`CleanPath` makes a path VALID, not SAFE.** `path.Clean` semantics + per-component `Clean`;
volume-aware (accepts `/` and `\`, outputs `/`, preserves `C:` and UNC prefixes) — but it keeps a
leading `..` and keeps absolute paths absolute. Only for paths you control; for untrusted input
use `Join` (or `Clean` each segment yourself — `Clean` resolves `".."` to a harmless segment).

## Common mistakes

| Mistake | Fix |
|---|---|
| `os.Rename` across volumes → `EXDEV` | `fileflow.Move` (copy+delete fallback) |
| Assuming the file landed at `dst` | Use the returned path |
| Pre-checking existence to avoid overwrite | fileflow already suffixes non-identical files |
| Manual `os.MkdirAll` before an operation | Parents are created by default |
| Requiring a mount point but allowing dir creation | `Flow{NoCreateDirs: true}` |
| Building a dest from untrusted input by hand | `pathologize.Join(root, parts...)` |
| `CleanPath` on untrusted input | VALID ≠ SAFE — use `Join` |
| Sanitizing the trusted root too | `Join` takes root verbatim; only parts are untrusted |
