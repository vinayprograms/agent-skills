# Documentation

## Godoc Conventions

1. **Doc comments start with the declared name.** Optionally preceded by "A" or "An".
   ```go
   // A Request represents a request to run a command.
   type Request struct { ... }

   // Encode writes the JSON encoding of req to w.
   func Encode(w io.Writer, req *Request) { ... }
   ```

2. **"reports whether" for boolean functions.** Not "returns true if".
   ```go
   // HasPrefix reports whether s begins with prefix.
   func HasPrefix(s, prefix string) bool
   ```

3. **Package comments: `// Package [name] ...`** Immediately before `package` clause, no blank line.
   ```go
   // Package path implements utility routines for manipulating
   // slash-separated paths.
   package path
   ```

4. **Document cleanup requirements.** If `Close()`, `Stop()`, or `Release()` is needed, say so.
   ```go
   // NewTicker returns a Ticker. Call Stop to release associated resources.
   func NewTicker(d Duration) *Ticker
   ```

5. **Document error conditions.** Which errors can a function return?
   ```go
   // Chdir changes the current working directory.
   // If there is an error, it will be of type *PathError.
   func Chdir(dir string) error
   ```

6. **Document concurrency safety.** Assume unsafe unless stated.
   ```go
   // Regexp is safe for concurrent use by multiple goroutines,
   // except for configuration methods, such as Longest.
   type Regexp struct { ... }
   ```

7. **Deprecated: marker.** Include what to use instead.
   ```go
   // Deprecated: Use NewReader instead.
   func OldReader() *Reader { ... }
   ```

8. **Named returns only for doc clarity.** Disambiguate multiple same-typed returns. Don't use for naked returns.
   ```go
   // GOOD — clarifies meaning
   func (f *Foo) Location() (lat, long float64, err error)
   // BAD — redundant
   func (n *Node) Parent() (node *Node)
   ```

## README Conventions

1. **One README.md per package.**
2. **Lead with a usage example.** The ideal call-site snippet.
3. **Document the interface, not the implementation.**
4. **Show configuration format if the package parses config.**
5. **Keep it concise.** "What is this? How do I use it?"
6. **Update README when you rename.** Stale names are worse than no README.

## Design the architecture, name the components, document the details.
