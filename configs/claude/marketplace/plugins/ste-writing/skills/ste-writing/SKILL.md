---
name: ste-writing
description: Rewrite prose (docs, READMEs, PR descriptions, error messages, release notes, or comments. Never rewrite code) into ASD-STE100 Simplified Technical English to remove "AI slop". Use when asked to make writing not sound like AI, make docs clear or plain, enforce a controlled writing style, or write technical documentation that reads human. Two modes - strict (procedures/safety) and flavored (general prose).
---

# ste-writing

Write prose in ASD-STE100 Simplified Technical English. This applies to documentation, READMEs, pull-request text, error messages, release notes, and comments. It does not apply to code, identifiers, or command syntax. It is not for marketing copy, essays, or anything that needs a voice. STE strips voice on purpose.

## Rules

WORDS
- Use one name for one thing. Do not call the same item by two different names.
- Use the short common word: start (not begin/commence/initiate), use (not utilize/leverage), help (not facilitate), make sure (not ensure), before (not prior to), after (not subsequent to), about (not regarding/concerning), get (not obtain/acquire), show (not demonstrate), also (not additionally/furthermore/moreover).
- Give each word one meaning. "fall" means to move down, not to decrease.
- No marketing adjectives: seamless, robust, powerful, cutting-edge, effortless, world-class, next-generation, revolutionary.
- American spelling.

VERBS
- Active voice. "the parser reads the file", not "the file is read by the parser".
- Use a verb for an action. "analyze the log", not "perform an analysis of the log".
- No stacked auxiliaries. Not "it is important to note that this may help to improve". Write "this improves X".
- No "-ing" main verb where a simple tense works.

SENTENCES
- One instruction per sentence. Max 20 words (instruction), max 25 (descriptive).
- No contractions. Use articles: a, an, the, this, these.

PUNCTUATION
- No semicolons. No em-dashes. Write two sentences.

STRUCTURE
- One topic per paragraph, max six sentences. For steps, use a numbered vertical list, one action per item, imperative form. Put a condition before its command.

Write only the requested text. No preamble, no summary, no closing remarks.

## Modes

- **strict**: procedures, runbooks, safety text, error messages: apply every rule and both length caps.
- **flavored**: general prose (READMEs, PR descriptions, docs): apply the sentence, paragraph, active-voice, and no-phrasal-verb discipline. Relax the ~900-word dictionary lockdown so the text keeps enough range to read naturally.

## Manual checks (run before the linter)

These need judgment. The script cannot see them.

1. Any sentence over 20 words? Split it.
2. Any semicolon? Replace with a period.
3. Any contraction? Expand it.
4. Any passive voice with a known actor? Make it active.
5. Any "-ing" main verb, nominalization ("perform an analysis"), or phrasal verb ("spin up")? Replace with a plain verb.
6. Same thing named two ways? Pick one name.

The mechanical rules above are lintable and are what removes slop. Full STE also needs human judgment (the right technical noun, whether a sentence "makes good sense"). A checker cannot certify that, and slop is not about that. This skill fixes the FORM of slop. It cannot make a hollow paragraph true.

## Linter

`scripts/ste-lint.py` counts mechanical violations. It requires `uv` on the PATH. Run it after you draft text and before you return it.

Pipe the draft to the script to get the full report:

    printf '%s' "$DRAFT" | scripts/ste-lint.py --mode flavored

Pass one or more paths to get a one-line summary per file:

    scripts/ste-lint.py --mode strict README.md docs/*.md

Add `--json` to get the full report for file arguments too. Quote a glob to let the script expand it.

Use the stdin form when you rewrite text. Use the file form to compare files or to check a rewrite against the original.

Set `--mode` to match the mode you write in. Strict counts banned dictionary words in the total. Flavored reports them but leaves them out of the total.

The script exits 1 when a hard rule is broken. It exits 0 when the text passes.

### How to read the report

| Field | Meaning | Action |
| --- | --- | --- |
| `hard_total` | hard rule breaks, drives the exit code | must be 0 |
| `long_sentence(>20w)` | sentences over the strict cap | split each one |
| `semicolon`, `contraction` | hard rule breaks | fix all of them |
| `em_dash(slop-marker)` | em dashes and en dashes | fix all of them, this count is not in `total` |
| `banned_word`, `marketing_adjective` | dictionary hits, see `sample_*` for the words | fix in strict mode, judge in flavored mode |
| `passive_voice`, `nominalization`, `ing_main_verb` | pattern guesses | read each hit before you change it |
| `total_per100w` | violation rate | use this to compare drafts of different lengths |

### Targets

- strict: `hard_total` must be 0. Drive `total_per100w` under 1.0.
- flavored: `hard_total` must be 0. Ignore `banned_word` hits that carry real meaning. Keep `total_per100w` under 3.0.

### Known false positives

The script uses regular expressions, not a parser. Read the source text before you accept a hit.

- `passive_voice` counts agentless passives such as "is required". These are often correct.
- `passive_voice` also counts adjectives such as "is related".
- `nominalization` counts any noun before "of", such as "version of".
- `contraction` counts possessives such as "the parser's output".
- The script removes code fences and backtick spans. It does not remove link URLs or tables.

Do not rewrite text only to lower a number. A hit is a question, not a verdict.
