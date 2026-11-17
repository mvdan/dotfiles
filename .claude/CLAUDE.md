# Personal preferences (all projects)

- Go tests run with `-timeout=30s` by default, via GOFLAGS in settings.json, so
  that a hung test fails fast instead of burning the machine. Do not set GOFLAGS
  in a command without keeping the timeout; pass `-timeout` directly instead,
  raising it only for a package known to be slower than that.

- Prefer external Go test packages (`package foo_test`) for new test files,
  and use an in-package test only when it needs unexported API. Any in-package
  test file, including export_test.go, makes every package that imports foo in
  foo's test binary compile again just for that binary, which slows builds and
  bloats the build cache. Since one in-package file keeps all of that cost, do
  not add one to a package whose tests are all external without a good reason.

- When investigating hangs or panics, always use short timeouts, such as
  `go test -timeout=3s` for Go tests, or `timeout 3 ./binary` for programs.

- Starting many parallel subagents is fine, but each should only run the
  part of the test suite relevant to its change. The main agent decides when
  to run the whole test suite, so that many full runs don't compete for CPU.

- Never run benchmarks or fuzzing unless I ask for or approve them; they are
  slow, benchmark numbers are unreliable on a busy machine, and fuzzing runs
  open-ended until it is stopped.

- Outside a Go benchmark, compare performance by instructions executed,
  measured with `perf stat -e instructions:u`, which counts child processes
  too; it is the steadiest measure on a noisy machine. User and system CPU
  time, as `perf stat` or `/usr/bin/time` report them, are other options, but
  they still vary with load, especially system time when spawning many
  processes. Do not use wall time unless I explicitly ask for it, as it mostly
  measures the scheduler on a busy machine.

- Before acting on an unexplained performance difference in hot Go code,
  link each side with a few `-ldflags=-randlayout=N` seeds, which shuffle
  function order, and count `cycles:u` as well as instructions. If the
  cycles overlap across seeds, the difference costs no time and is not worth
  working around. `go tool` takes no `-ldflags`; use `go build` instead.

- Never run a command that can block on an interactive prompt. git and gh are
  non-interactive via settings.json env vars, but editors and login flows are
  not: pass -m/--no-edit, set GIT_EDITOR/GIT_SEQUENCE_EDITOR for rebases, and
  ask me to run auth commands myself with `! <command>`. If something does
  hang, kill it rather than waiting.

- Use git's -q where output scales with the change (stash pop/apply, mixed
  reset, rm -r, clean, am, rebase -x), not on commit, worktree add, or
  checkout -b/switch, whose few lines are useful. bisect, cherry-pick, and
  rebase --continue/--abort/--skip do not take -q, and `git diff -q` is not
  `--quiet`.

- `git filter-repo` is installed; `git filter-branch` is not. Use it instead
  of a rebase when every pending commit needs the same mechanical change,
  such as a text replacement via `--file-info-callback`, so that no conflicts
  arise. Back up the branch under refs/claude/backup/ first, and always limit
  it with `--refs <branch> '^@{u}'`, which implies `--partial`: a plain run
  rewrites every ref, removes the origin remote, and expires the reflogs. It
  needs `--force` outside a fresh clone, which includes any linked worktree.

- Do not publish commits, PRs, comments, or code reviews without permission.
  Drafts are fine, as I can review them before they are published.

- Lean towards brevity in code comments and commit messages. Say what matters
  and stop: no restating the same point, no code examples in commit-message
  prose, no padding that the code or tests already make clear. Default to the
  shorter form rather than waiting to be asked to trim.

- Wrap any inline code snippet in commit messages and markdown in backquotes,
  such as `echo foo`, `env.HOME`, or `--out`.

- In Go doc comments, linkify references to other identifiers as doc links:
  `[Name]` for a package-level name, `[Type.Field]` or `[Type.Method]` for a
  member, `[pkg.Name]` for another package.

- When an expression mixes `&&` and `||`, add parentheses to make the grouping
  explicit, such as `a || (b && c)`, rather than relying on precedence.

- Text written for GitHub issues, discussions, and releases must not hard-wrap
  paragraphs, as those fields render single newlines within a paragraph as line
  breaks. Write each paragraph as one long line and let the browser wrap it.
  Fenced code blocks are never reflowed.

- Never manually add Signed-off-by or Change-Id trailers to commit messages;
  projects which use them already have git commit hooks to add them.

- Do not add Claude attribution trailers to commits or PRs, unless the
  session or project instructions say otherwise.

- For bug fixes, split into two commits. The first adds a regression test which
  documents the intended behavior and demonstrates the bug, asserting the wrong
  values so that it passes against the unfixed code; a panic is asserted via an
  inline recover, and a hang via a short timeout. The second applies the fix,
  flips the assertions, and removes the recover or timeout along with them:
  once the panic or hang is fixed, a regression fails the test on its own, and
  the guard only obscures what the test is about. Develop and verify the fix
  first, then set it aside to write commit 1 against the broken baseline,
  confirming that the flipped test fails without the fix. Keep the final test
  structure in commit 1, flipping values in place with a comment on the
  affected cases rather than adding extra "todo" fields or branches, so that
  the fix commit's diff shows only what the fix changes.

- Never record in a test file what the code used to do, including the position
  of a change within a series. Comments in tests, golden files, and test
  archives describe what the test asserts and why, in the present tense; past
  behavior belongs in git history and the commit message, or in a linked issue.
  The test commit of a two-commit bug fix may of course describe the bug, which
  is present tense there.
