# Insights: tools and response shape

## Tools

| Tool | Permission | Arguments | Returns |
|---|---|---|---|
| `insights_brief` | `insights:read` | optional `topic`, `tier`, `limit` | The radar: run status, coverage, ranked signals, summary |
| `insights_explain` | `insights:read` | `signal_id` | Why one signal fired: rule, thresholds, evidence, exclusions |
| `insights_report_outcome` | `insights:outcome` | `signal_id`, `outcome`, `request_id`, optional `note` | Confirmation; idempotent by `request_id` |

`outcome` is one of `confirmed` (it was real), `dismissed` (false alarm),
`acted` (an action was taken) or `resolved` (the situation is over).

## `insights_brief`

| Field | Meaning |
|---|---|
| `as_of` | Business day the radar was computed for |
| `run.status` | `fresh`, `stale` (with `run.reason`) or `not_configured` |
| `run.playbooks` | The signed playbooks behind the answer, as `key@version` |
| `coverage.entities_checked` / `entities_excluded` | How many entities were evaluated and how many were left out |
| `coverage.topics` | Topics this workspace covers |
| `summary.total` / `shown` | Signals found and signals returned |
| `summary.by_kind`, `summary.by_tier` | Counts for header tiles |
| `summary.money_at_stake` | Weekly money by nature: `risk`, `opportunity`, `shift` |
| `signals[]` | Ranked by `money_at_stake`, largest first |
| `next` | What to call next |

Each signal:

| Field | Meaning |
|---|---|
| `signal_id` | Stable for the same entity, kind and period |
| `tier` | `certified` or `discovered` |
| `kind`, `label` | Machine id and the label to show |
| `nature` | `risk`, `opportunity` or `shift` |
| `entity.type`, `entity.name` | What the signal is about |
| `magnitude_pct` | The change that defines the signal |
| `money_at_stake` | Weekly money, positive |
| `period.from`, `period.to` | Window the signal was computed on |
| `series[]` | `{ period, value }` points for a small trend |
| `decomposition` | Certified only: `lines_pct` and `value_per_line_pct` |
| `action` | Certified only: `recommendation`, `reason_code`, `requires_approval`, `decision_record_id` |
| `stats`, `provenance` | Discovered only: the template's numbers and where the finding came from |

Certified kinds: `slow_drift`, `sharp_break`, `mix_shift`, `sustained_growth`.
Discovered kinds: `own_drift`, `acceleration`, `multivariate_outlier`, `peer_gap`.

## `insights_explain`

`signal`, `why` (sentences ready to read, in order), `rule` (`description` and
`thresholds`), `evidence`, `run` (playbook, version, hash, dates), `excluded`
(entities left out, with the reason) and `next`.

## Errors

One envelope: `{ "error": { "code", "message", "retryable" } }`.

| Code | Meaning |
|---|---|
| `topic_not_covered` | The topic does not exist here; the error lists `topics` |
| `signal_not_found` | No current signal has that id |
| `signal_expired` | The signal existed and its retention ended |

A stale run is **not** an error: it is a valid answer marked `stale`.
