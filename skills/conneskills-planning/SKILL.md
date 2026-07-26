---
name: conneskills-planning
description: Inspect and manage governed engineering plans through Conneskills Planning, including sessions, transitions, signatures, contracts, reviews, test runs and governance checks. Use for implementation planning, resuming an existing plan, checking gates, recording review or test evidence, or requests involving Conneskills planning sessions and ADR-linked governance.
---

# Conneskills Planning

Use the server as the source of truth for governed plan state and evidence.

## Workflow

1. Use `planning_list` or `planning_get_sessions` to find an existing session.
2. Read it with `planning_get` before starting or changing anything.
3. Use `planning_start` only when no suitable session exists and the user asks
   to create a governed plan.
4. Update the contract before transitions when scope or acceptance criteria
   change.
5. Record reviews and tests with `planning_record_review` and
   `planning_record_test_run`.
6. Run `governance_check` before signing or completing a governed transition.

## Rules

- Preserve session IDs, revisions and states exactly as returned.
- Do not sign, transition or overwrite a contract based on assumed intent.
- Record grill, review and test evidence against the relevant session.
- Treat missing ADR tools as the default permission boundary. Do not call
  `manage_adr`, `get_adrs_for_symbol` or `submit_adr_feedback` unless they are
  present and the user explicitly requests ADR work.
- Report validation and governance failures without fabricating success.
