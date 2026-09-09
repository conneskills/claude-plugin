---
name: conneskills-knowledge
description: Search the company's governed knowledge bases through Conneskills Knowledge — internal policies, procedures, documents, business definitions, Jira content, connected repositories, and exact database schema from the indexed snapshot. Use it whenever a question is about what this company knows, decided, documents or defines rather than about the public world, including tables, columns, relationships, indexes, sizes, risk or query warnings. Triggers on "what's our policy", "check the KB", "which table or field", "describe this table", and Spanish "busca en la base de conocimiento", "qué sabemos de", "cuál es nuestra política", "qué tablas hay", "describe esta tabla". Reach for it before answering from general knowledge and before querying any live system.
---

# Conneskills Knowledge

This is the governed retrieval layer over the company's own material. Search it
before answering from general knowledge: when a question is about *this*
organization, a plausible-sounding general answer is usually a wrong one, and
the KB gives you something you can cite.

Everything you reach stays inside the user's workspace, team and personal scope.
You never need to widen that, and there is no tool here that would let you.

## Workflow

1. Call `list_knowledge_bases` when you do not already know the relevant KB
   IDs. It tells you what exists and each KB's indexing status.
2. Call `search_knowledge_base` with the user's question in natural language
   and the `kb_ids` that plausibly hold the answer. It is semantic retrieval —
   phrase the query as the question, not as keywords, and let the ranking work.
3. Answer from the retrieved chunks and cite their file, URL or KB metadata, so
   the user can go read the source.
4. If the top chunks are off-topic, reformulate once with the vocabulary the
   corpus actually uses (which the first results usually reveal). Repeating the
   same query against more KBs rarely helps.

Say what you searched. "Nothing in the KBs I searched covers this" is a useful
answer; implying you searched everything is not — a KB you did not select was
not consulted, and the user may know of one you missed.

## Database and connector questions

For a descriptive or business question, use `search_knowledge_base`. For an
exact structural question, use the indexed database schema tools instead of
semantic search:

1. `database_list_schemas` with the ready database `kb_id`.
2. `database_list_tables` with `kb_id` and `schema`; paginate with `limit` and
   `offset` when `has_more` is true.
3. `database_describe_table` with `kb_id`, `schema` and `table` for exact
   columns, keys, indexes, relationships, constraints, triggers and warnings.

These three tools read only the last KB snapshot. Their result declares
`source: knowledge_base_index`, `deterministic: true` and
`live_database_queried: false`; an error never falls back to the live database.
Read `references/database-schema.md` whenever the task involves database
structure or prepares a live query.

Use the schema's business descriptions to map the user's language to real
identifiers. Before any live read, inspect row-count accuracy, table and index
size, `performance_risk`, relationships and ordered `warnings`; do not silently
turn a warning about scans, locking, approximate counts or bloat into a safe
query assumption.

Once you know what to ask for and the user needs a current value, use the
`conneskills-connectors` server — that is the canonical place for live reads.
Knowledge may also expose live connector tools for backwards compatibility.
When both servers are present, keep the boundary explicit: the three schema
tools above belong here; live `database_count`, `database_select` and
`database_aggregate` belong to Connectors.

## Reading the state of a KB honestly

- A KB whose status is not ready is still indexing. Report that and answer from
  what is available; polling it in a loop will not make it finish sooner.
- On `budget_exceeded`, stop and tell the user to talk to their workspace
  administrator. Retrying spends what is already exhausted.
- A missing tool means the credential's Access Group did not grant that action.
  That is the permission boundary working — name the missing access instead of
  routing around it.
- Answer in the user's language, but keep source terminology exactly as the
  documents spell it: internal names are how people find the material again.
