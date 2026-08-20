#!/usr/bin/env bash
# Stop / SubagentStop hook: enforce the Go correctness baseline deterministically.
# Exit 2 blocks the turn from ending and feeds stderr back to the model to fix.
# Reliability by structure: the compiler/tests decide, not the model's attention.
set -uo pipefail

input="$(cat 2>/dev/null || true)"

# Avoid infinite stop loops (Claude Code caps at 8, but bail early).
case "$input" in
  *'"stop_hook_active":true'*|*'"stop_hook_active": true'*) exit 0 ;;
esac

dir="${CLAUDE_PROJECT_DIR:-$PWD}"
cd "$dir" 2>/dev/null || exit 0

# Only act inside a Go module.
[ -f go.mod ] || exit 0

is_git=0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 && is_git=1

# Scope guard: if this is a git repo and no .go files changed, do nothing.
if [ "$is_git" = 1 ]; then
  git status --porcelain 2>/dev/null | grep -qE '\.go$' || exit 0
fi

fail() { printf 'Go baseline FAILED (%s). Fix before finishing:\n%s\n' "$1" "$2" >&2; exit 2; }

# gofmt — only the files YOU changed, never the whole repo (pre-existing dirt is out of scope).
if [ "$is_git" = 1 ]; then
  changed="$(git diff --name-only HEAD -- '*.go' 2>/dev/null; git ls-files --others --exclude-standard -- '*.go' 2>/dev/null)"
  if [ -n "$changed" ]; then
    unformatted="$(echo "$changed" | xargs gofmt -l 2>/dev/null)"
    [ -n "$unformatted" ] && fail "gofmt (changed files)" "$unformatted (run: gofmt -w on them)"
  fi
else
  unformatted="$(gofmt -l . 2>/dev/null)"
  [ -n "$unformatted" ] && fail "gofmt" "$unformatted (run: gofmt -w .)"
fi

# RED-BASELINE / migration mode: a migration starts with a broken build by design.
# When .go-migrate/baseline-errors exists, the whole-module gates are unsatisfiable; instead enforce
# MONOTONIC SHRINK — the build-error count must not exceed the recorded ceiling (the orchestrator
# ratchets that number down per unit; when it hits 0 it removes the file and normal gates resume).
errcount() { go build ./... 2>&1 | grep -cE '\.go:[0-9]+:' ; }
if [ -f .go-migrate/baseline-errors ]; then
  ceiling="$(tr -dc '0-9' < .go-migrate/baseline-errors)"; ceiling="${ceiling:-999999}"
  cur="$(errcount)"
  if [ "$cur" -gt "$ceiling" ]; then
    fail "migration regressed" "build errors rose to $cur (ceiling $ceiling). A unit must only SHRINK the error count."
  fi
  echo "Go migration ✓ (errors $cur ≤ ceiling $ceiling; changed-file gofmt clean)"
  exit 0
fi

# Normal mode: full green required.
out="$(go vet ./... 2>&1)"        || fail "go vet" "$out"
out="$(go build ./... 2>&1)"      || fail "go build" "$out"
out="$(go test ./... -race 2>&1)" || fail "go test -race" "$out"

echo "Go baseline ✓ (gofmt, vet, build, test -race)"
exit 0
