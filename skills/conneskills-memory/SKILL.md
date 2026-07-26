---
name: conneskills-memory
description: Retrieve and maintain governed long-term memory and intentions through Conneskills Memory. Use when prior decisions, user preferences, project history, recurring context or pending intentions may affect the current task, or when the user explicitly asks to remember, recall, improve, consolidate or forget information.
---

# Conneskills Memory

Retrieve relevant memory before acting on history-dependent work, and store
only information that will remain useful beyond the current turn.

## Workflow

1. Use `search_memory` for a focused recall query.
2. Use `fetch_context` when a broader task context is required.
3. Distinguish retrieved facts from current verified state; refresh facts that
   may have changed.
4. Use `save_memory` for stable decisions, preferences or reusable findings.
5. Use `improve_memory` when correcting or refining an existing memory.

Use `remember_intention`, `list_intentions` and `fulfill_intention` for durable
pending commitments. Use consolidation tools only when the user requests
consolidation or the workflow explicitly requires it.

## Rules

- Never store passwords, tokens, private keys or unnecessary personal data.
- Do not save transient tool output, speculation or facts that are cheap to
  rediscover.
- Do not present stale memory as confirmed current state.
- Treat `forget_memory` as destructive. Use it only when present and explicitly
  requested for an exact target.
- If a tool is unavailable, explain that its scope was not granted rather than
  bypassing the permission boundary.
