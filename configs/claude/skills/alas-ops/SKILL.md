---
name: alas-ops
description: Day-to-day Jira / Confluence / JSM operations with the `alas` CLI — triage queues, work requests, approvals, comments, transitions, search, bulk edits, and the operational discipline that keeps a service desk healthy. Use when asked to check tickets, answer a service request, approve something, triage a queue, or do any routine Jira/JSM task. Not for changing project configuration like workflows or forms (use service-desk-admin).
---

# Day-to-day operations with `alas`

Routine work against Jira, Confluence, and JSM. Reads are free; mutations prompt for
confirmation unless `-y`. Prefer `--dry-run` when composing an unfamiliar mutation.

## Scope and output

- Commands act on the scoped project/board/space: `alas scope` shows what's set and
  from where; `-p/-b/-s` override per-command; `alas use` sets it per-directory.
- `-o json` for parsing, `-o keys` for piping ids into xargs, `--all` for every page.
  TSV (no header) is the default when piped — safe for cut/awk.
- `alas <KEY>` alone shows an issue. `alas open <KEY>` opens it in a browser.

## Operating rhythm

A service desk stays healthy on cadence, not heroics. The loop worth automating into
habit:

**Daily — triage before you work.** New requests get an owner and an honest status
before anyone picks up their own backlog:

```sh
alas me                       # your open sprint work + pending approvals
alas q untriaged              # unassigned, filed in the last 7 days
alas q triage                 # unassigned To Do work, oldest first
alas q approvals              # service requests waiting on your approval
```

Triage means three decisions per ticket: right request type? (if not, note it — type
changes are a UI operation), who owns it?, and does the first-response SLA need a
public reply *now*? An assigned ticket sitting in To Do is invisible triage debt —
assignment and transition go together.

**Daily — approvals are someone waiting.** `alas q approvals` should trend to zero
every day; an unanswered approval blocks a requester completely. Decline with a
reason, always (`--decline -m`).

**Weekly — sweep the edges.** The tickets that rot are the ones no queue surfaces:

```sh
alas q stale days=14          # open, untouched — ping or close
alas q blocked                # labelled blocked — still blocked?
alas groom                    # walk a set interactively: re-status, re-assign, close
```

`alas query list` shows all built-in queries (dropped, due, reported, watching, …).
Parameterized ones take args: `alas q stale days=30`.

**Work from queues, not personal filters.** Queues are the shared truth; if your real
worklist lives in a private filter, the team can't see load or cover for you. If a
queue's JQL doesn't match how the team actually works, that's config feedback —
hand it to service-desk-admin territory, don't route around it.

## Service requests (JSM)

A request is a Jira issue with a portal side. `alas jsm` reaches portal-only data
(request type, customer-facing status, SLA cycles, approvals, public/internal flag)
and even desks you can only access as a customer. Searching and bulk ops exist only
on the issue side.

```sh
alas jsm request show <KEY>              # status, SLA, approvals in one view
alas jsm request list                    # requests you raised or participate in
alas jsm queue list                      # agent queues on the desk
alas jsm queue show <id-or-name>         # what's in a queue
alas jsm request move <KEY>              # transition via the portal's transition list
alas jsm approve <KEY> [-m "reason"]     # answer an approval
alas jsm approve <KEY> --decline -m "…"  # reject (give a reason)
```

### Comments: public vs internal

```sh
alas jsm request comment <KEY> -m "…"             # PUBLIC, the customer sees it
alas jsm request comment <KEY> --internal -m "…"  # agent note, hidden from portal
```

Discipline that keeps customers informed and SLAs honest:
- **Only public replies stop the first-response clock.** An internal note is not a
  response, however thorough. If you've started work, say so publicly, even briefly.
- **Pair customer-visible transitions with a public comment.** A status jump with no
  explanation reads as a black box from the portal. Moving to a waiting-on-customer
  state *requires* a public comment saying what you need — the SLA clock is paused on
  them and they don't know it.
- "Internal" means hidden from the portal only — anyone who can browse the project
  sees it. Never put secrets in either.
- When drafting a public reply, show the user the text before posting.

### Status honesty

SLA clocks and queue membership key off status. "In progress" on a ticket nobody is
touching corrupts both. Move tickets to waiting states when they're genuinely waiting,
back when they're not — `alas q mine` only works as a worklist if statuses are true.
Reopening beats creating a duplicate: it preserves the thread and the SLA history.

## Issues

```sh
alas issue list --jql '…'          # JQL is pre-validated; --no-validate to skip
alas issue show <KEY>
alas issue edit <KEY> …            # change fields
alas issue assign <KEY> [user]     # set or clear assignee
alas issue label <KEY> …           # add/remove labels
alas issue move <KEY> [status]     # transition; omit status to pick from a list
alas issue comment <KEY> -m "…"
alas issue create
```

Useful JQL for service desks: `Approvals = myPending()`, `Approvals = pending()`,
`statusCategory != Done`, `"Time to done" < remaining("4h")` for SLA pressure.

## Bulk work

```sh
alas issue batch …                              # same change to many items
alas q triage -o keys | xargs -n1 alas issue assign  # pipe keys into per-item commands
```

Bulk discipline:
- **Select, show, confirm, apply.** Run the selection first, show the user the exact
  list, and apply with `-y` only after they confirm that set. Never widen the JQL
  between the preview and the apply.
- Public comments in bulk email every requester — bulk public messaging is a
  deliberate act, not a side effect. Bulk internal notes and label/assign changes are
  cheap; use those for housekeeping.
- Close stale tickets with a public "closing due to inactivity — reply to reopen"
  comment, not silently.

## Search and Confluence

```sh
alas search "query"            # Jira + Confluence together
alas page show SPACE/"Title"   # a page as Markdown
alas filter list               # the team's saved Jira filters
```

Repeated answers belong in a Confluence page, not in ever-longer ticket comments —
search first (`alas search`), link the page in the public reply, update the page when
it's stale. Three tickets asking the same question is a documentation bug.

## When things look wrong

- Empty results from raw JQL: the pre-flight validator usually catches typos; if you
  used `--no-validate`, that's the first suspect.
- "not an agent on this service desk": queues, SLA data, and internal notes need agent
  access — fall back to `alas jsm request show`, which uses whichever path works.
- A ticket missing from a queue it should be in: check its `statusCategory` — a status
  in the wrong category is a workflow-config bug (service-desk-admin), not a data bug.
- Stale lists: `--refresh` bypasses cached catalogs; `alas cache` inspects/clears.
- `-v` traces HTTP to stderr with credentials redacted — use it before blaming the API.
