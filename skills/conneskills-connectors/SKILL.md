---
name: conneskills-connectors
description: Read current values from the workspace's authorized live connections through Conneskills Connectors — database rows and aggregates, documents, issue trackers, repositories and BI warehouses. Use it when the answer depends on what a connected system contains now, such as a count, total, today's figure, open tickets, current file contents or a dataset measure. Triggers on "how many", "what's the current", "check the database", "look in Drive", "open tickets", and Spanish "cuántos hay", "consulta la base de datos", "mira en Drive", "tickets abiertos", "el dato de hoy". Do not use it for database schema discovery; exact schemas, tables, columns, relationships, sizes, risk and warnings belong to Conneskills Knowledge's indexed snapshot.
---

# Conneskills Connectors

This server reaches the **live source**: every call queries the real database,
Drive, Jira, repo or BI dataset behind a workspace connection. That is its value
and also its cost — a live query is slower than retrieval, it puts load on
someone's production system, and it bills against the workspace. So it is worth
using deliberately, not as a first reflex.

## Where this server fits

Conneskills indexes connections into knowledge bases. The indexed copy answers
"what do we know / how does this work / where is X described" cheaply and with
citations. This server answers "what is the value **right now**".

Reach for `conneskills-knowledge` first for anything conceptual, definitional or
descriptive — including *which* table or field holds a figure. Come here once you
know what to ask for and need the current answer.

The Knowledge server may also expose live connector tools for backwards
compatibility. When both servers are installed, use this server for live reads:
it keeps the source boundary and its cost legible to the user. The exception is
the indexed database schema trio, which belongs to Knowledge and is not exposed
by Connectors.

## Workflow

1. Call `list_active_connections` when you do not already know which
   connections exist. It groups them by family and gives you the connection IDs
   every other tool needs.
2. For a database, resolve structure first through `conneskills-knowledge`.
   `database_list_schemas`, `database_list_tables` and
   `database_describe_table` are deterministic indexed tools; if they are not
   available, report the missing Knowledge access rather than probing the live
   source for schema.
3. Ask the narrowest live question that answers the user. `database_count` and
   `database_aggregate` return an answer; `database_select` returns rows you
   then have to summarize. When the user wants a number, ask for the number.
4. Report which connection and object you read, so the user can tell a live
   figure from a remembered one.

The tools take **structured arguments** — table, columns, filters, limit,
group-by — not SQL text. There is no raw-query tool, deliberately: reads run
inside a READ ONLY transaction and nothing here can mutate a connected system.
If a request needs an INSERT, a DDL change or a query no argument set can
express, say so rather than approximating it.

See `references/tool-families.md` for the full tool inventory by family and the
argument shapes that are easy to get wrong.

## When a tool you expected is not there

Tool availability is per credential, per family. The workspace grants
`connectors:database:read`, `connectors:document:read` and so on through Access
Groups, and a family that was not granted simply has no tools registered — the
absence is the permission boundary working, not a bug or an outage.

So when a family is missing, tell the user which access their credential lacks
and let them ask a workspace administrator. Do not try to reach the same data
through another family, and never ask the user for raw database credentials or
API tokens to work around it.

A `403` with a `WWW-Authenticate` header is the other half of the same idea: the
credential exists but this action was not consented. The header names the scope
to request; re-authorizing is the user's action to take, not something to retry
around.

## Reading results honestly

- A connection that fails to answer is a fact about that system, not about the
  data. Report the failure with the connection name; do not fill the gap with
  the indexed copy without saying so.
- Row limits truncate. If you selected with a limit and hit it, say the result
  is partial — an unqualified "there are 100" from a `LIMIT 100` is wrong.
- The table names, columns, relationships and warnings used for a database read
  came from the last indexed snapshot. Say when that snapshot may be stale; do
  not imply that Connectors revalidated the schema live.
- `warehouse_*` is the current prefix for BI tools. The older `powerbi_*` names
  still work during their deprecation window; if you only see those, use them
  and mention the connector is on the legacy naming.
- Answer in the user's language, but keep table, field and project identifiers
  exactly as the source spells them.
