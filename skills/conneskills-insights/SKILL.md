---
name: conneskills-insights
description: Read the signals radar that Conneskills already computed over the company's own data — slow drifts, sharp breaks, mix shifts, sustained growth and discovered findings, ranked by money at stake, each with its trend, its explanation and its recommended action. Use it first for any open question about how the business is doing, what is at risk, where the opportunities are, what needs attention, or to build a dashboard or summary of risks and opportunities. Triggers on "how is the business doing", "what should I worry about", "any risks", "where are the opportunities", "build me a dashboard", and Spanish "cómo va el negocio", "qué riesgos hay", "qué debería mirar", "dónde hay oportunidades", "arma un tablero", "qué tiendas van mal". Do not use it to fetch a specific current value from a table; that belongs to Conneskills Connectors.
---

# Conneskills Insights

This server is the answer to a question nobody can phrase well: *what in my data
needs a decision that I am not seeing?* The analysis is not yours to do. The
platform runs signed playbooks every day against the connected systems, compares
each entity with its own history and with its peers, and stores the result. These
tools read that result. They never query the customer's database and they do not
take tables, dates or metrics as arguments.

That is the point. If you find yourself planning aggregate queries to answer
"how is the business doing", stop and call `insights_brief` instead: the method
already ran, deterministically, and two people asking get the same answer.

## Workflow

1. Call `insights_brief` with no arguments. Do not ask the user what to analyse
   first.
2. Read `run.status` before anything else:
   - `fresh` — answer normally.
   - `stale` — answer, and say the radar is out of date, with `run.reason`.
   - `not_configured` — there is no analysis for this workspace yet. Do not
     improvise one with other tools and present it as the radar. If the user is
     a workspace owner or admin, offer to turn it on with `insights_setup`
     (see below); otherwise say who can.
3. Lead with what is at stake, not with the list: `summary.money_at_stake` by
   nature (`risk`, `opportunity`, `shift`), then the top signals. They arrive
   already ranked by money.
4. Before recommending an action on a signal, call `insights_explain` with its
   `signal_id`. It returns the rule that fired with its thresholds, the weekly
   numbers, what the rest of the group did that same week, and which entities
   were left out and why.
5. When the user tells you what happened with a signal, record it with
   `insights_report_outcome`. That is how the radar learns which signals matter.

## Turning the radar on

`insights_setup` is how an owner or admin starts the analysis, from this same
server. It takes a template (`salud_tiendas`: weekly sales per store, with the
company's action rule published as a decision), the connected database to read
and `min_weekly_money` (the weekly sales under which a store is not judged, in
the table's currency). `connection_id` can be omitted when the workspace has one
database; the schema, table and column names default to the template's and can
be overridden. Confirm them first with `database_describe_table` on the
knowledge server when in doubt. The platform registers the playbook, signs it in
the caller's name and runs it right away, so `insights_brief` answers with real
signals a few seconds later. Calling it again with the same definition only
re-activates it; a different definition creates the next version.

## Reading a signal

Every signal has a `tier`, and the difference is not cosmetic:

- **`certified`** comes from a signed rule. It carries an `action` decided by a
  published business decision, with `requires_approval` when a person has to
  sign off. You can present the action as the company's own policy.
- **`discovered`** comes from an analysis template (seasonal decomposition,
  multivariate outliers, peer clusters). It has no `action`; it has
  `provenance`, which says which template produced it and why it was chosen.
  Present it as something worth looking at, never as a conclusion, and say that
  nobody has signed it yet.

`magnitude_pct` is the change that defines the signal. `decomposition` splits a
sales change into number of lines and value per line, which is what tells apart
a traffic problem from a pricing or mix problem — use it when you explain.
`money_at_stake` is weekly money, always positive; `nature` says whether it is a
risk or an opportunity.

`coverage` says how many entities were checked and how many were left out.
Mention the exclusions when they matter: a store that opened last month is not
"fine", it is unmeasured.

## Building a dashboard

`insights_brief` returns everything a dashboard needs in one call, so build it
from that response alone:

- header totals from `summary` (`by_kind`, `by_tier`, `money_at_stake`);
- the ranked list from `signals`, with `label`, `entity.name`, `magnitude_pct`,
  `money_at_stake` and `action.recommendation`;
- one small trend per signal from `signals[].series`;
- certified and discovered kept visibly apart, using `tier`;
- the freshness line from `as_of` and `run`.

Raise `limit` (up to 200) if `summary.shown` is lower than `summary.total`.
Do not enrich the dashboard with live queries: a figure computed another way
will not match the radar and the user cannot tell which one to trust.

## What this server does not do

- It does not answer "what is the value of X right now" — that is
  `conneskills-connectors`.
- It does not explain how a process works or where something is documented —
  that is `conneskills-knowledge`.
- It does not cover a topic outside `coverage.topics`. Asking for one returns
  `topic_not_covered` with the list of topics that exist; relay that list
  instead of approximating the topic by hand.

## When a tool you expected is not there

`insights:read` is opt-in and is granted from the workspace's Access Group.
`insights_report_outcome` needs `insights:outcome`, which is granted separately
because it writes. A missing tool is the permission boundary working, not an
outage.

See `references/response-shape.md` for the fields of each response and the error
envelope.
