---
name: conneskills
description: Query your company's knowledge and data through Conneskills. Triggers on questions about company knowledge bases, internal documentation, business data, connected databases, customer/order/sales data, Jira issues, company documents in Drive/OneDrive, or when the user mentions Conneskills, the company brain, or "our data". Also triggers on "what do we know about X", "check our KB", "query our database", "how are sales", or any question whose answer lives in the company's own systems rather than public knowledge. También se activa con preguntas en español sobre datos o conocimiento de la empresa — "cómo van las ventas", "consulta la base de datos", "qué sabemos de X", "busca en la base de conocimiento", "el cerebro de la empresa", "cuántos pedidos/clientes/facturas", "cuál es la receta estándar", "qué dice el manual/procedimiento", "inventario", "proveedores", "ventas por sede/marca/ciudad" — o cualquier pregunta cuya respuesta viva en los sistemas propios de la empresa.
---

# Conneskills — Company Knowledge & Data

Conneskills is the company's governed context layer: knowledge bases (KBs) built from
connected sources (databases, Google Drive, OneDrive, Jira, GitHub, APIs) plus native
"Company Brain" KBs written by agents and people. Every tool call is scoped to what
THIS user is allowed to see (workspace ∩ teams ∩ personal), audited, and metered —
never bypass it by asking the user for raw credentials.

## Decision matrix

| The user asks about… | Do this |
|---|---|
| Company knowledge, docs, policies, past analyses | `search_knowledge_base` across relevant KBs |
| What data sources exist | `list_knowledge_bases` + `list_active_connections` |
| What a database table/column means | `search_knowledge_base` on the schema KB first (it has LLM-written descriptions), THEN `database_describe_table` if needed |
| Live business data (counts, records, lookups) | `database_select` / `database_count` |
| A specific document or file | `document_list_files` → `document_read_file` |
| Jira issues / project status | `issue_list_issues` → `issue_get_issue` |
| Source code in connected repos | `code_list_files` → `code_read_file` |

## Core workflow: answering a business question

1. **Discover once per session**: `list_knowledge_bases` and `list_active_connections`.
   Cache mentally — do not repeat on every question.
2. **Semantic first**: `search_knowledge_base` with a natural-language query against the
   most relevant KB(s). For database questions, the schema KB explains which tables and
   columns encode the concept (e.g. "cancellation" → `subscriptions.status`), because
   Conneskills indexes the schema with LLM-generated descriptions.
3. **Then live data**: use `database_select` (structured filters, pagination via
   `limit`/`offset` + `order_by`) and `database_count` (get totals BEFORE paginating).
   All queries are server-enforced read-only. There is no raw SQL — compose equality
   filters and pagination.
4. **Cite sources**: chunks come back with file/url/kb metadata — surface them.

## Rules

- Prefer `search_knowledge_base` over guessing table names; prefer `database_count`
  before pulling rows.
- `database_select` caps at 500 rows/call. For aggregations beyond `database_count`,
  fetch the minimal columns and state clearly that the figure was computed from a
  sample/pagination, or ask the user to narrow the question.
- If a KB returns "not ready", tell the user it is still indexing — do not retry in a loop.
- On `budget_exceeded` errors, stop and tell the user to contact their workspace admin.
- Never ask the user for database credentials, connection strings, or API keys —
  connections are managed in the Conneskills app (app → Connections).
- If a tool is missing (e.g. no `database_*` tools), the capability isn't granted to
  this credential — point the user to their Conneskills admin, don't work around it.
- Answer in the user's language. KB content and schema descriptions may be in Spanish
  (e.g. "Entradas", "Platos Fuertes", "sede") — query in the language of the data.
