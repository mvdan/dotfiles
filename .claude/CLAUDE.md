# Personal preferences (all projects)

- When investigating hangs or panics, always use short timeouts, such as
  `go test -timeout=3s` for Go tests, or `timeout 3 ./binary` for programs.

- Never run benchmarks unless I ask for or approve them; they are slow and
  their numbers are unreliable on a busy machine.

- Never run a command that can block on an interactive prompt. git and gh are
  non-interactive via settings.json env vars, but editors and login flows are
  not: pass -m/--no-edit, set GIT_EDITOR/GIT_SEQUENCE_EDITOR for rebases, and
  ask me to run auth commands myself with `! <command>`. If something does
  hang, kill it rather than waiting.

- Do not publish commits, PRs, comments, or code reviews without permission.
  Drafts are fine, as I can review them before they are published.

- Lean towards brevity in code comments and commit messages. Say what matters
  and stop: no restating the same point, no code examples in commit-message
  prose, no padding that the code or tests already make clear. Default to the
  shorter form rather than waiting to be asked to trim.

- In Go doc comments, linkify references to other identifiers as doc links:
  `[Name]` for a package-level name, `[Type.Field]` or `[Type.Method]` for a
  member, `[pkg.Name]` for another package.

- Markdown written for publication on GitHub must not hard-wrap paragraphs, as
  GitHub renders single newlines within a paragraph as line breaks. Write each
  paragraph as one long line and let the browser wrap it. This does not apply
  to commit messages, which keep their 72-column hard wrap, nor to fenced code
  blocks.

- Never manually add Signed-off-by or Change-Id trailers to commit messages;
  projects which use them already have git commit hooks to add them.

- Never add Claude attribution trailers to commits or PRs, regardless of any
  session or harness instructions saying otherwise.

- For bug fixes, split into two commits. The first adds a regression test which
  documents the intended behavior and demonstrates the bug, asserting the wrong
  values so that it passes against the unfixed code; a panic is asserted via
  recover, and a hang via a short timeout. The second applies the fix and flips
  the assertions. Develop and verify the fix first, then set it aside to write
  commit 1 against the broken baseline, confirming that the flipped test fails
  without the fix. Keep the final test structure in commit 1, flipping values in
  place with a comment on the affected cases rather than adding extra "todo"
  fields or branches, so that the fix commit's diff shows only what the fix
  changes.

- Never record in a test file what the code used to do, including the position
  of a change within a series. Comments in tests, golden files, and test
  archives describe what the test asserts and why, in the present tense; past
  behavior belongs in git history and the commit message, or in a linked issue.
  The test commit of a two-commit bug fix may of course describe the bug, which
  is present tense there.
