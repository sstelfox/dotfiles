---
name: service-desk-admin
description: Develop and maintain the configuration of a team-managed Jira Service Management project with the `alas` CLI — design and edit workflows (statuses, transitions, rules) and portal request forms, snapshot config for drift detection, and follow safe change-management practice. Use when asked to design or change a service desk's workflow, transitions, form questions, or to audit/snapshot its configuration. Not for day-to-day ticket work (use alas-ops).
---

# Service desk administration with `alas`

Configuration changes to a team-managed JSM project: workflows and request forms.
Everything here mutates shared project config that affects the whole team and takes
effect on in-flight tickets immediately — always `--dry-run` or `--validate-only`
first, and show the user the diff before applying.

## Scope

Commands act on the scoped project. Check with `alas scope`; override per-command with
`-p <KEY>`. Set per-directory with `alas use <KEY>` (writes `.alas.toml`).

## What is and is not configurable via the API

Writable (team-managed projects only, with workflow rights):
- **Workflows**: statuses, transitions, conditions, validators, post-functions.
- **Request forms**: the portal questions behind a request type (separate forms API).

Readable only: queue definitions and their JQL, request types and fields, roles,
permission and notification schemes.

**Not writable by anyone through any public API** (web UI only — do not attempt, do not
suggest alas can): SLA goals, queue definitions, request types themselves
(create/rename/delete), portal settings, portal status-name mappings, automation rules.

The workflow API reports every workflow as "editable" regardless of rights — never use
that flag as a permission check; a validate call is the real test.

## Discovering current state

```sh
alas project show <KEY>                  # issue types, statuses, roles, schemes
alas workflow list                       # workflows for the scoped project
alas workflow show <id-or-name>          # statuses + transitions
alas workflow show <id-or-name> --rules  # conditions, validators, post-functions
alas jsm requesttype list                # request types on the project
alas jsm requesttype show <id>           # one type; its fields
alas jsm form list                       # form templates on the project
alas jsm form show <name-or-id>          # human-readable questions
alas jsm form show <name-or-id> --raw    # raw definition (the editable shape)
alas jsm queue list -o json              # queue JQL (read-only reference)
```

Team-managed service desks typically have one project-scoped workflow **per request
type**, named like `<projectId>: <issueTypeId> workflow for service_desk`. Map issue
type ids via `alas jsm requesttype list` before picking which workflow to edit.

A request type backed by a form reports **no fields** through the service-management
API — the questions only appear via `alas jsm form show`. Check both before concluding
a type asks nothing.

## The config repo

Treat service desk configuration as code even though half of it is read-only. Keep a
repo (or directory in one) with the full snapshot, and make every change a commit:

```sh
alas workflow list -o keys | while read -r wf; do
  alas workflow export "$wf" > "workflows/$wf.json"; done
alas jsm form list -o keys | while read -r f; do
  alas jsm form show "$f" --raw > "forms/$f.json"; done
alas jsm queue list -o json > queues.json
alas project show <KEY> -o json > project.json
```

This earns three things:
- **Review**: a workflow change is a diff a teammate can read before it's applied.
- **Drift detection**: re-snapshot on a schedule; an unexpected diff means someone
  changed config in the web UI — reconcile before it bites.
- **Blast-radius checks**: before renaming or removing a status, grep the snapshot.
  Queue JQL, SLA goals, saved filters, and automation all reference **status names as
  strings** and break silently when a name changes. The read-only files exist precisely
  to be grepped.

## Designing workflows

Principles that matter in JSM specifically:

- **Status categories are load-bearing.** Queue JQL, SLA definitions, and reports key
  off `statusCategory` (`TODO` / `IN_PROGRESS` / `DONE`). A waiting-state put in the
  wrong category silently vanishes from "All open" queues or never stops the SLA clock.
  Decide the category deliberately for every new status.
- **Customers see this.** Status and transition names can surface in the portal.
  "Waiting for customer" reads fine; "Blocked on infra" does not. (The portal's
  status-name remapping is UI-only, so get the real names right.)
- **Model waiting explicitly.** A single "In progress" hiding "waiting on customer",
  "waiting on vendor", and "actually being worked" makes SLA pauses and queue triage
  impossible. Separate statuses for externally-blocked states; SLA goals (UI-side)
  pause on them.
- **Approval gates are a status.** The JSM pattern is a `Pending`-style status with an
  `Approved` transition forward and a decline path; the approval itself is attached to
  the status in the web UI. The workflow's job is to make the gate impossible to skip:
  no transition should route around the pending status.
- **No dead ends, no unreachable states.** Every status needs a transition out; a new
  status needs at least one way in. Terminal statuses need a reopen path, and the
  reopen transition must clear resolution: `"properties": {"sd.resolution.clear": ""}`.
- **Fewer statuses, named transitions.** Agents pick transitions by name from a menu;
  "Resolved" from two different statuses should mean the same thing. Reuse names for
  the same semantic move (the export shows this is normal — ids differ, names repeat).
- **Keep per-type workflows aligned.** Four request types with four gratuitously
  different workflows quadruple the team's cognitive load. Diverge only where the
  process genuinely differs (e.g. only one type needs an approval gate).

## Editing a workflow

Cycle: export → edit file → validate → review → apply → re-export.

```sh
alas workflow export "<name>" > wf.json      # writes a file on a tty; redirect when piped
# edit wf.json
alas workflow edit "<name>" --from-file wf.json --validate-only
alas workflow edit "<name>" --from-file wf.json
alas workflow export "<name>" > wf.json      # re-export: capture server-assigned ids/version
```

File shape (what export produces):
- Top-level `statuses`: id, name, `statusCategory`, referenced by `statusReference`
  everywhere else.
- `workflows[0].statuses`: which statuses the workflow uses, with layout coordinates
  (cosmetic — preserve, don't fuss over).
- `workflows[0].transitions`: `type` is INITIAL (the Create transition) or DIRECTED;
  `links[].fromStatusReference` is the source, `toStatusReference` the target.
  `validators`, `actions` (post-functions), `triggers`, `properties` hang off each.
- `workflows[0].version` must match the server's — on a version-conflict failure,
  re-export and re-apply your change to the fresh file.
- `statusMappings`/`defaultStatusMappings`: required when a change strands existing
  issues (removing a status, splitting one). The server rejects the edit until you say
  where in-flight issues in the removed status land.

Change-management practice:
- The server validates everything and any error aborts the whole edit — but validation
  checks structure, not sense. `--validate-only` catches broken references; only review
  catches "this routes around the approval gate".
- Apply during a quiet window. The change hits in-flight tickets immediately: open
  issues keep their status but their available transitions change under the agents.
- **Smoke-test after apply**: create a throwaway request of that type via the portal,
  walk it through every transition with `alas issue move`, confirm it appears in the
  right queues (`alas jsm queue show`), then close it. A workflow that validates can
  still be wrong.
- One semantic change per apply (add a status; rework a gate) — not a batch. When the
  smoke test fails you want one suspect.

## Designing forms

Form answers live in the form, not in Jira fields, unless explicitly linked (linking is
UI-side). Consequence: **anything that must drive queues, JQL, SLAs, or automation
cannot live only in a form question**. Decide per question: is this for the human
reading the ticket (form is fine) or for routing/reporting (needs a Jira field)?

Question design:
- Every required question is friction that pushes requesters to email instead. Require
  only what an agent needs to *start* work; everything else is optional or asked later.
- Prefer choice/date/url types over free text — they're consistent and skimmable.
  One rich-text "anything else?" at the end beats five vague text boxes.
- Use conditional sections so requesters only see questions relevant to their earlier
  answers (the existing Security Questionnaire form's "where is it?" → URL/portal
  branching is the pattern to copy).
- Order: identity/context first, the ask itself, then logistics (deadline, links).

## Editing a form

```sh
alas jsm form show "<name>" --raw > form.json
cp form.json "form.$(date +%F).bak.json"     # no validate-only exists for forms
# edit form.json
alas jsm form edit "<name>" --from-file form.json
alas jsm form show "<name>"                   # confirm the questions read as intended
```

- `form edit` **replaces** the whole definition — always start from a fresh `--raw`
  export, never hand-construct, and keep the dated backup until verified.
- **Never renumber or reuse question ids.** Answers on existing requests are keyed by
  question id; reusing an id silently relabels historical answers. New question → new
  id; retired question → remove it, leave the id dead.
- Form changes don't touch open requests (they keep the answers they were submitted
  with) — safe to apply any time, but smoke-test by loading the portal form and
  submitting a test request.

## Safety

- These are shared-state mutations: confirm with the user before `workflow edit` or
  `form edit` without `--validate-only`/`--dry-run`, even when `-y` would skip the prompt.
- Before renaming/removing a status, grep the config snapshot for the old name (queues,
  filters, SLA references) and list what the user must fix in the web UI afterward.
- `--refresh` if cached catalogs look stale; `-v` to trace HTTP when an error is opaque.
- Permission failures surface as validate errors, not upfront — interpret them for the
  user rather than pasting raw API errors.
