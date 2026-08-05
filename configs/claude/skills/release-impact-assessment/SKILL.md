---
name: release-impact-assessment
description: Produce a release description, Security Impact Assessment (SIA), and Privacy Impact Assessment (PIA) for the changes between two git references (usually tags, sometimes branches), for promoting a release to production. Use when asked for an SIA, PIA, impact assessment, change description, or release review between two tags/refs/branches.
---

# Release Impact Assessment (SIA / PIA)

Produces the three-section document required to promote a release into production environments.
Output goes to the chat response, not a file.

## Inputs

Two git references, `<base>` (previously deployed) and `<head>` (release being promoted).
Usually tags but branches are also valid.

If the user gave only one ref, or none, ask which two refs to compare before proceeding.
Do not guess.

Verify both refs resolve before starting:

```
git rev-parse --verify <base> && git rev-parse --verify <head>
git log --oneline <base>..<head>
git rev-list --count <base>..<head>
```

## Method

### 1. Enumerate the commits

```
git log --format='%H%x09%s' <base>..<head>
```

Each commit in this range is one unit of review. Review every commit in the range no
matter how many there are. Never stop, block, or warn based on the size of the range.

### 2. Fan out one subagent per commit

Launch all commit-review subagents concurrently in a single message (multiple Agent tool
calls in one response). Use the `general-purpose` subagent type. Each subagent reviews
exactly one commit.

Give each subagent this brief, substituting the commit SHA:

> Review git commit `<SHA>` in this repository as part of a release security and
> privacy impact assessment. Do not summarize the commit message; read the actual diff.
>
> Run `git show --stat <SHA>` then `git show <SHA>` and read the full diff, however large
> it is. For bulk mechanical content (lockfiles, generated code, vendored dependency
> trees), read the source changes in full and characterize the mechanical portions by
> category, still accounting for all of it. Read the
> surrounding code with Read/Grep where the diff alone does not make the behavior clear,
> in particular for any permission check, redirect target, log statement, or data write.
>
> Report back:
> - Ticket IDs. Every referenced ticket or other tracker ID in the full commit message, including
>   ones only in the body. Multiple tickets per commit are normal.
> - Short SHA and PR number.
> - What the change actually does, in one to two sentences, at the level of behavior not
>   implementation.
> - Authorization: does this add, remove, or alter any permission check, role binding,
>   redirect allowlist, or authentication path? Is the net effect a tightening or a
>   loosening? Scan the whole diff for compensating loosening elsewhere, not just the
>   part the commit message advertises. For any new permission action, state which roles
>   it binds to and which call sites consume it.
> - Feature flags: is any behavioral portion gated, and is the flag on or off in
>   production?
> - External third parties and major external components: does this add or change an
>   external service, hosted backend, or major component? If so, what data flows there,
>   is any of it PII, is it a new egress, and how do we authenticate to it? Routine
>   dependency updates are not in this category, but call out any dependency change that
>   alters what talks to what.
> - Data handling: new collection of direct or indirect identifiers, new data store, new
>   retention surface, new encryption surface, or new external egress? Do existing data
>   shapes change, or only who may read or write them?
> - Logs: specifically any new logging of known PII, customer data, headers, or raw
>   requests or responses. Ignore ordinary log changes.
> - In-flight PII: does this touch parsers or deserializers that PII transits at runtime?
>   For dependency bumps, note deserialization or prototype-pollution CVEs closed.
> - Cryptography: any change to cryptographic primitives, modules, or key handling.
> - Significant-change candidates: flag against these categories explicitly, and say
>   "none" where none apply. Components, services, or infrastructure interconnections
>   added or removed; security controls or their implementation; flow, storage, or
>   processing of customer confidential data; system components added or removed;
>   authentication or access control mechanisms; cryptographic modules; infrastructure
>   or network architecture; security logging, monitoring, or audit capabilities; new
>   external services or APIs; migration to new platforms, frameworks, or hosting;
>   major version upgrades to infrastructure components.
> - Known tradeoffs the change accepts, for example durability or availability given up
>   for performance.
> - Whether you consider this a new feature or a significant change rather than a bug fix.
>
> Be concrete and cite file paths. Say "none" explicitly for categories that do not apply
> rather than omitting them. Do not speculate; if the diff does not settle a question,
> say what you could not determine.

For a dependency-refresh commit (Go toolchain bumps, package updates, base image rolls),
additionally ask the subagent to characterize: toolchain version change, whether package
moves are patch, minor, or major, whether any cross-major bump changes an external service
interaction, whether the base image source registry changes, any newly added package and
what it contributes, and the classes of CVE closed (stdlib, TLS, parser, deserialization).

### 3. Synthesize

Read every subagent report before writing. Cross-check claims that matter: if a subagent
reports a new permission action or an external egress, verify it yourself with git and
Grep before it goes in the assessment. Do not take subagent conclusions at face value on
authorization or egress claims.

Resolve conflicts and note anything a subagent could not determine.

## Voice

This document is produced by the SecOps team and as such should be authoritative in
communicating outward to other relevant parties.

- Use an active voice.
- Use verbs for actions taken.
- Avoid marketing adjectives.
- Prefer American spelling.
- Avoid stacked auxiliaries.
- Use no "-ing" main verb where simple tense works.
- Use no contractions.
- Use no semicolons.
- Use no em or en dashes.
- Cover one topic per paragraph or line item.
- Write no more than six sentences per paragraph.
- State one action per item, in imperative form.
- Write no preambles and no closing remarks.

## Output format

A single markdown document in the chat response with exactly three second-level sections
and no subsections within them.

Hard formatting rules:

- Use no hyphens as sentence punctuation. Hyphens inside identifiers, ticket IDs, and
  hyphenated technical terms are fine.
- Unordered list items in the description use a bold key prefix followed by a colon.
- The SIA is five paragraphs or fewer. The PIA is five paragraphs or fewer.
- Prose paragraphs in the SIA and PIA. No bullets there.

### Section 1: Description

Opening line naming the release, the commit it is based on, and the target environments,
following this shape:

> Deploy `<head>` based on commit `<short-sha>` to the non-production and production environments.
>
> The below diff between the previously deployed release (`<base>`) and `<head>`.

Then one list item per logical change, in the order the commits appear. Each item is one to
two sentences capturing the core of the work.

- Prefix each item with the ticket IDs and, where the prior examples did so, the short
  commit SHA in parentheses, then a colon. Multiple tickets addressed in the same
  PR go on one line, comma separated.
- Describe behavior and why, not implementation detail.
- If a ticket appears on the internal QA tracking ticket but was not included in the
  release, add a note line saying so explicitly.

Close with:

> Each of these changes was reviewed individually to ensure no significant changes or new
> features were being added. Additional details from the review of these changes are
> included in the security and privacy impact assessment.

### Section 2: Security Impact Assessment

Five paragraphs or fewer. Cover every category below, and state categories that do not
apply explicitly rather than omitting them. Silence is not the same as reviewed and clear.

- Opening paragraph: count of changes and tickets, a breakdown by change class, and a
  direct statement on whether any constitutes a significant change. Explicitly address
  the recurring negatives when true: no service added or removed, no third-party service
  relationships changed, no cryptographic primitives or key handling touched, no data
  moved to a different store.
- Authorization changes: net tightening or loosening, whether the whole diff was checked
  for compensating loosening, role bindings and consuming call sites for any new
  permission action, and feature-flag gating with production state.
- External third parties and major external components, where any exist: what data flows,
  whether it is PII, vendor management authorization, new egress and destination, and
  credential handling. Routine dependency work belongs in its own paragraph instead,
  covering toolchain moves, CVE classes closed, and whether any external interaction
  changed.
- Behavioral tradeoffs worth flagging to a reviewer, labeled as availability-class or
  correctness-class rather than as security concerns when that is what they are.
- Net security posture: a verdict of positive, neutral, or negative, with the specific
  risks added and removed enumerated.

### Section 3: Privacy Impact Assessment

Five paragraphs or fewer. Cover:

- New data handling: new collection of direct or indirect identifiers, new data store, new
  retention surface, new encryption surface, new external egress. If all are no, say so in
  one sentence.
- Data shapes versus access population: whether flows change shape, or only who may read
  or write them, and whether the principal set narrows or broadens per affected flow.
- Sensitive data in logs: call out only changes that log known PII, customer data,
  headers, or raw requests or responses. If a change adds log lines on a rejection path,
  state exactly what they contain and whether that is PII or log noise.
- In-flight PII exposure through parsers and deserializers, including exposure removed by
  dependency patches at that layer.
- Residual risk mapped to an existing mitigation or workflow, or the new mitigation
  required.
- Privacy verdict: positive, neutral, or negative, with reasoning.

## After the document

Print a short list, outside the three sections, of any change a subagent flagged as a
potential significant change, with a one-line reason each and the category it falls under,
so it can be tracked for the annual audit. If nothing was flagged, say so in one line.
