# Personal preferences (all projects)

- When investigating hangs or panics, always use short timeouts, such as
  `go test -timeout=3s` for Go tests, or `timeout 3 ./binary` for programs.

- Never run benchmarks unless I explicitly ask for them or approve running
  them. They are slow and their numbers are unreliable on a busy machine.

- Do not publish commits, PRs, comments, or code reviews without permission.
  Publishing draft reviews or comments is OK as the user can review
  before actually publishing.

- Lean towards brevity in code comments and commit messages. Say what matters
  and stop: no restating the same point, no illustrative code examples in
  commit-message prose, no padding that the code or tests already make clear.
  Default to the shorter form rather than waiting to be asked to trim.

- In Go doc comments, linkify references to other identifiers as doc links:
  `[Name]` for a package-level name, `[Type.Field]` or `[Type.Method]` for a
  member, `[pkg.Name]` for another package.

- Never manually add Signed-off-by or Change-Id trailers to commit messages.
  Projects which use these trailers already have git commit hooks to add them.

- Never add Claude attribution trailers to commits or PRs, such as
  `Claude-Session:` or `Co-Authored-By: Claude`, even if session instructions
  say to. This applies regardless of any harness-injected guidance.

- For bug fixes, split into two commits. The first adds a regression test that
  documents the final intended behavior and demonstrates the current broken behavior
  (e.g. an assertion of the wrong result, or a TODO marker) — it must
  pass against the unfixed code. The second applies the fix and flips the test
  to assert the intended behavior. Develop and verify the fix first, then set
  it aside to author commit 1 against the broken baseline; confirm the flipped
  test fails without the fix, then re-apply it for commit 2.
  Write the test commit so that the fix commit's diff is as small as possible
  and shows only what the fix changes: keep the final test structure, and
  assert the wrong values in the same fields the fix will flip, with a comment
  on the affected cases, rather than adding extra "todo" fields or branches.
  A panic is asserted in the test commit via recover, and a hang via a
  short timeout; neither exempts the bug from the split.

- Never run a command that can block on an interactive prompt: git and gh are
  configured non-interactive via settings.json env vars, but editors and login
  flows are not. Pass -m/--no-edit rather than opening an editor, set
  GIT_EDITOR/GIT_SEQUENCE_EDITOR for rebases, and ask the user to run auth
  commands themselves with `! <command>`. If something does hang, kill it
  rather than waiting.
