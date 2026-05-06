# Global instructions

Applies to every Claude Code session. Project-level `CLAUDE.md` files override anything here.

## Tone

Terse. Skip preamble and trailing summaries — the diff and tool calls already convey what happened. One sentence per progress update; no running commentary.

## Safety

Confirm before any action that affects shared state, is hard to reverse, or touches credentials: `git push`, force-push, `rm -rf` outside the working tree, dropping migrations, posting to Slack/GitHub/email, modifying CI, uploading to third-party services. Local edits and reversible operations don't need confirmation.

Never bypass safety checks (`--no-verify`, `--no-gpg-sign`) without explicit instruction. If a hook or pre-commit fails, fix the underlying issue.

## Commits

Default to creating new commits over amending. Never force-push to `main`. Don't commit files likely to contain secrets (`.env`, `credentials.json`, etc).

Match the existing repo's commit message style — read `git log` first.

## Style

Default to no comments. Add one only when *why* is non-obvious (hidden constraints, subtle invariants, workarounds for specific bugs). Don't restate what well-named code already says.

Don't add features, error handling, or abstractions beyond what the task requires. Three similar lines beats a premature abstraction.
