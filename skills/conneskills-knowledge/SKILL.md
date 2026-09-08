---
name: conneskills-knowledge
description: Search the company's governed knowledge bases through Conneskills Knowledge — internal policies, procedures, documents, business definitions, indexed database schemas, Jira content and connected repositories. Use it whenever a question is about what this company knows, decided, documents or defines rather than about the public world, including which table or field holds a figure. Triggers on "what's our policy", "how do we do X here", "what does the doc say", "check the KB", "where is that documented", and Spanish "busca en la base de conocimiento", "qué sabemos de", "cuál es nuestra política", "dónde está documentado". Reach for it before answering from general knowledge and before querying any live system.
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

For anything about the company's data, search the index first even when the
final answer needs a live figure. The indexed KB carries the schema *and* the
business descriptions of tables and fields, which is how you find out that
"revenue" lives in `facturacion.importe_neto` and not in a column called
`revenue`. Guessing table and field names from the user's phrasing is the main
way these answers go wrong.

Once you know what to ask for and the user needs a current value, use the
`conneskills-connectors` server — that is the canonical place for live reads.
This server also registers connector tools for backwards compatibility, so you
may see `database_*`, `document_*`, `issue_*`, `code_*` or `warehouse_*` here
too; when both servers are present, prefer the Connectors ones.

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
