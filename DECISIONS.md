# Decisions — mobile-app-template

> Auto-captured decisions land 🟡 Presumed / ❓ Open / 🔬 Needs-Research. The operator
> dispositions them — 🔒 Locked (confirm), ⏸ Deferred (park, not now), or 🗑 Superseded
> (kill); auto-capture never sets those three. Locked decisions are injected into agent
> context — agents MUST NOT reopen them. The injected L0 layer is a *pending cockpit*:
> it leads with unresolved decisions (stalest-first) and collapses locked/deferred to
> one-line summaries. Every entry carries `decided:` and `validated:` dates; trust
> anchors to the most recent `validated:` date, not to age.
>
> Entry format:
> ### <ID> — <short title>
> <!-- tier: locked|deferred|presumed|open|needs-research|superseded · area: <area> · files: <glob> · decided: <YYYY-MM-DD> · validated: <YYYY-MM-DD> · issue: #<N> · source: code|pr|walkthrough|operator -->
> <Why, as a war story: what was chosen, the alternatives rejected, and why. One short paragraph.>

## Index
| ID | Title | Tier | Area | Validated |
|----|-------|------|------|-----------|

## 🔒 Locked

## ⏸ Deferred — consciously parked (not now; revivable)

## 🟡 Presumed — acting on it, not yet confirmed

## ❓ Open — needs a decision

## 🔬 Needs-Research — blocked on legal/cost/spike; do not touch

## 🗑 Superseded
<!-- annotate, never delete. Archive to DECISIONS-archive.md once this section exceeds ~10 entries. -->
