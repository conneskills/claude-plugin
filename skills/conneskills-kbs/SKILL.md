---
name: conneskills-kbs
description: Search governed company knowledge through Conneskills KBS and, only when needed, query authorized live connectors. Use for internal policies, procedures, documents, business definitions, indexed database knowledge, Jira content, connected repositories, company data, "our data", "what do we know", "check the KB", or Spanish requests such as "busca en la base de conocimiento", "qué sabemos", "consulta nuestros datos" and "cómo van las ventas".
---

# Conneskills KBS

Use Conneskills KBS as the governed retrieval layer for company knowledge. Keep
all access within the user's workspace, team and personal scope.

## Workflow

1. Call `list_knowledge_bases` once when the relevant KB IDs are not already
   known.
2. Call `search_knowledge_base` with a natural-language query and the most
   relevant `kb_ids`.
3. Answer from the retrieved chunks and cite their file, URL or KB metadata.
4. Use a live connector only when the indexed knowledge cannot answer a
   precise current-value or structured lookup.

For database questions, always search the indexed KB first. Use its schema and
business descriptions to identify the correct tables and fields. Only then use
`database_count`, `database_select` or other granted database tools when fresh
values are required. Do not start by querying the database directly.

Connector tools are registered dynamically. Depending on granted connections,
they may include `database_*`, `document_*`, `issue_*` or `code_*` tools.

## Rules

- Prefer semantic retrieval over guessing source names, tables or fields.
- Treat a missing connector tool as an ungranted capability; do not work
  around it or request raw credentials.
- Treat a KB with a non-ready status as still indexing. Report it without
  retrying in a loop.
- Stop on `budget_exceeded` and direct the user to the workspace administrator.
- Never claim that search covered content outside the selected KBs.
- Answer in the user's language and preserve source terminology.
