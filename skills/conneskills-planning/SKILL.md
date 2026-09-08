---
name: conneskills-planning
description: Read and drive governed engineering plans through Conneskills Planning — planning sessions, state transitions, signatures, contracts, grill/review/test evidence, governance gates and ADR links. Use this skill whenever work is tracked as a Conneskills plan rather than as an ad-hoc task — "resume the plan", "what state is this session in", "record the review", "log the test run", "run the governance check", "can we sign this off", "what does the contract say", "start a governed plan", and Spanish requests such as "retoma el plan", "en qué estado está", "registra la revisión", "pasa el gate", "firma la fase", "qué dice el contrato". Reach for it before inventing your own plan structure for work that already has a session.
---

# Conneskills Planning

The server holds the authoritative state of a governed plan: its contract, its
current phase, and the evidence recorded against it. That authority is the point
— a plan you keep in your head or in a scratch file is not the plan anyone else
sees, and gates decide on what is recorded here.

## Workflow

1. `planning_list` or `planning_get_sessions` to find an existing session.
   Starting a second session for work that already has one splits the history
   and the evidence, which is expensive to unpick.
2. `planning_get` to read it before changing anything, so you are acting on the
   real current state rather than an assumed one.
3. `planning_start` only when no suitable session exists *and* the user asked
   for a governed plan.
4. `planning_update_contract` before a transition when scope or acceptance
   criteria have moved. A transition against a stale contract records the wrong
   thing, and the record is what a later gate reads.
5. `planning_record_review`, `planning_record_test_run` and
   `planning_record_grill` to attach evidence to the session it belongs to.
6. `governance_check` before signing or completing a governed transition — it
   is cheaper to be told what is missing than to sign and unwind.
7. `planning_transition` and `planning_sign` last, and only for the step the
   user actually asked for.

## Fidelity of state

Preserve session IDs, revisions and state names exactly as returned. They are
identifiers, not prose, and a paraphrased state ("basically approved") makes the
plan unreadable to whoever looks next.

Report validation and governance failures as they came back, including which
gate failed and why. A plan whose failures were smoothed over is worse than no
plan: the whole reason for the gate is that someone downstream trusts it.

Never sign, transition or overwrite a contract on inferred intent. Signature and
transition are the two actions here that other people rely on, and the cost of
guessing is that someone else acts on a false record.

## ADR tools

`manage_adr`, `get_adrs_for_symbol` and `submit_adr_feedback` need
`planning:adr`, which the default consent does not include. When they are
absent, that is the safe default; when they are present, use them only for ADR
work the user explicitly asked for. Architecture decision records are read as
durable, considered artifacts, so an unrequested edit misrepresents a decision
someone else made.
