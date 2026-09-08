---
name: conneskills-memory
description: Recall and maintain governed long-term memory and pending intentions through Conneskills Memory — prior decisions, user and team preferences, project history, recurring context, and commitments to follow up on. Use this skill at the start of any task whose right answer depends on what was decided or preferred before, and whenever the user says "remember", "recall", "as we discussed", "what did we decide", "you already know", "don't forget to", "remind me", "forget that", or Spanish equivalents such as "recuerda", "acuérdate", "ya lo hablamos", "qué decidimos", "no olvides", "olvida eso". Also reach for it before repeating a question the user may already have answered in a previous session.
---

# Conneskills Memory

Memory is what makes the second conversation better than the first. Two things
follow from that: recall before doing history-dependent work, and write down
only what would actually help a future session — a store full of transient noise
makes recall worse, not better.

## Workflow

1. `search_memory` with a focused query when the task might depend on earlier
   decisions or preferences. This is cheap and the downside of skipping it is
   re-litigating something already settled.
2. `fetch_context` when you need the broader picture around a task rather than
   one fact.
3. Separate what memory says from what is true now. A recorded decision is
   evidence about the past; if it names a file, a flag or a service, verify it
   still exists before recommending it.
4. `save_memory` for what will still matter later: a decision and its reasoning,
   a standing preference, a non-obvious finding that cost real effort.
5. `improve_memory` when a stored memory turns out to be partly wrong. Refining
   the existing entry keeps recall clean; adding a second, contradictory one
   leaves a future session to guess which is current.

Use `remember_intention`, `list_intentions` and `fulfill_intention` for durable
commitments — something to do when a condition is met, not a task for this turn.
Close them out with `fulfill_intention` when done, or the list becomes noise
people learn to ignore.

Consolidation (`consolidate_session`, `consolidate_nightly`,
`consolidate_weekly`) reorganizes the store. Run it when the user asks or a
workflow requires it, not opportunistically. `get_memory_stats` tells you how
much is in there, which is the honest way to answer "what do you remember about
me" without dumping the store.

## What not to store

Never store credentials — passwords, tokens, private keys — or personal data the
task did not require. A memory store is long-lived and shared more widely than
the conversation that produced it, which is exactly what makes a secret in it
dangerous.

Skip transient tool output, speculation, and anything cheap to rediscover: the
code's own structure, what a file contains, a command's output. Storing those
costs recall quality and buys nothing, since the next session can just look.

## Boundaries worth respecting

`forget_memory` is destructive and usually not granted at all — deletion is
opt-in. Use it only when it is present and the user asked to forget a specific
thing they identified.

`promote_memory` raises a personal memory to team or workspace scope, making one
person's note visible to others. It needs both the scope and the permission to
write shared knowledge, so a refusal here can be authorization rather than
consent — report which one it was instead of retrying.

When a tool is missing, say which access the credential lacks. The absence is
the permission boundary working; there is nothing to route around.
