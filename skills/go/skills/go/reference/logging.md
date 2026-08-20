# reference / logging — structured logging with `log/slog` (1.21)

`log/slog` is the standard; don't import logrus/zap for new code without a measured reason.
The patterns most often gotten wrong:

```go
// Request-scoped fields: derive a logger once, all later calls carry them
logger := slog.With("request_id", r.ID, "user_id", r.UserID)
logger.Info("handling request")

// Group related fields
logger.With(slog.Group("http",
	slog.String("method", r.Method),
	slog.String("path", r.URL.Path),
	slog.Int("status", status),
))

// Log at the right level — Info is over-used
logger.Debug("cache miss", "key", key)      // internal state, high volume
logger.Info("server started", "addr", addr) // lifecycle events
logger.Warn("retrying", "attempt", n)       // recoverable problems
logger.Error("request failed", "err", err)  // needs attention
```

Rules:
- **Never** a package-level `log`/`slog` global beyond `main`. Pass `*slog.Logger` as a
  dependency (constructor/field). `slog.Default()` is the fallback only in `main`, or in a
  library when no logger was provided.
- **Never log and return the same error.** Log at the boundary; return the error through the
  call stack (see `../rubric/errors/checklist.md`).
- A kit that needs logging declares the narrow interface it needs, or takes `*slog.Logger` —
  it never configures global logging for the app.
