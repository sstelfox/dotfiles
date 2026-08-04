# Global instructions

## Tone

Terse. Skip preamble and trailing summaries. One sentence per progress update; no running commentary.

## Safety

Confirm before any action that affects shared state, is hard to reverse, or touches credentials: `git push`, force-push, `rm -rf` outside the working tree, dropping migrations, posting to Slack/GitHub/email, modifying CI, uploading to third-party services. Local edits and reversible operations don't need confirmation.

Never bypass safety checks (`--no-verify`, `--no-gpg-sign`) without explicit instruction. If a hook or pre-commit fails, fix the underlying issue.

## Commits

Default to creating new commits over amending. Never force-push to `main`. Don't commit files likely to contain secrets (`.env`, `credentials.json`, etc).

Use conventional commits style.

## Style

Comments need to have a purpose beyond describing the code. Limit the use to non-obvious considerations that went into the code (hidden constraints, expected invariants, workarounds for specific bugs). Don't restate what well-named code already says.

Don't add features, error handling, or abstractions beyond what the task requires. Keep the feature creep in check.

No broken windows. If you see a warning, error, or dangerous pattern don't leave it till later. Address problems upon detection.

Re-use existing code before writing new code. Minor alteration for a new use case is preferred over multiple redundant implementations.
