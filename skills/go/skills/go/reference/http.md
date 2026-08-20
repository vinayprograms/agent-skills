# reference / http — production HTTP services on the stdlib

Load when writing or reviewing an HTTP server, handler, or client. The theme: since Go 1.22 the
stdlib covers what LLM training data reaches for frameworks to do.

## Routing: the 1.22 ServeMux

`net/http.ServeMux` handles method and path-parameter routing natively — don't reflexively import
chi or gorilla/mux:

```go
mux := http.NewServeMux()
mux.HandleFunc("GET /users", listUsers)
mux.HandleFunc("POST /users", createUser)
mux.HandleFunc("GET /users/{id}", func(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	…
})
mux.HandleFunc("GET /files/{path...}", serveFile) // wildcard
```

Reach for a router package only for named route generation or regex constraints — middleware never
justifies a framework (see below).

## Production servers: always set timeouts

`http.ListenAndServe(addr, mux)` ships with **no timeouts** — one slow client holds a connection
forever (slow-loris). Never emit a production server without them:

```go
srv := &http.Server{
	Addr:              ":8080",
	Handler:           mux,
	ReadHeaderTimeout: 5 * time.Second,   // slow-loris protection
	ReadTimeout:       10 * time.Second,  // full request read
	WriteTimeout:      30 * time.Second,  // response write (covers handler time)
	IdleTimeout:       120 * time.Second, // keep-alive connections
}
```

Per-route control beyond `WriteTimeout`: `http.TimeoutHandler` or handler-level
`context.WithTimeout`. Outbound calls need the same discipline — `http.DefaultClient` has no
timeout either; construct a client with one.

## Graceful shutdown

Every production server needs a drain path:

```go
func run(ctx context.Context) error {
	ctx, stop := signal.NotifyContext(ctx, os.Interrupt, syscall.SIGTERM)
	defer stop()

	srv := &http.Server{ /* … timeouts as above … */ }

	errCh := make(chan error, 1)
	go func() { errCh <- srv.ListenAndServe() }()

	select {
	case err := <-errCh:
		return err // ListenAndServe failed at startup
	case <-ctx.Done():
		shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()
		return srv.Shutdown(shutdownCtx) // drain in-flight, then exit
	}
}
```

- `Shutdown` needs a **fresh** context with its own deadline — the signal context is already
  canceled.
- Long-lived connections (SSE, websockets) must watch `r.Context()` or they hold shutdown until
  the drain deadline.

## Middleware is just a function

`func(http.Handler) http.Handler` — no framework:

```go
func withRequestLog(logger *slog.Logger, next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		next.ServeHTTP(w, r)
		logger.Info("request", "method", r.Method, "path", r.URL.Path, "dur", time.Since(start))
	})
}

handler := withRequestLog(logger, withAuth(mux)) // compose by wrapping — outermost runs first
```
