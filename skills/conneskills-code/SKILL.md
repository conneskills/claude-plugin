---
name: conneskills-code
description: Explore indexed repositories with Conneskills Code using structural and semantic code search, architecture summaries, call traces, impact analysis and code episodes. Use for codebase orientation, locating symbols, tracing callers or data flow, architecture questions, regression analysis, cross-repository impact, indexed code search, or requests to inspect a Conneskills code workspace.
---

# Conneskills Code

Use the indexed knowledge graph before broad filesystem or text searches.

## Workflow

1. Call `list_projects` when the indexed project is not already known.
2. Start broad architecture questions with `get_architecture`.
3. Locate implementations with `search_graph`, `search_code` or
   `semantic_code_search`.
4. Read a precise implementation with `get_code_snippet` or
   `read_symbol_code`.
5. Use `trace_path`, `find_references`, `get_blast_radius_graph` or
   `get_cross_repo_impact` for relationships and change impact.
6. State when the index may be stale or incomplete.

Use `index_repo` only when the user asks to index a repository or no usable
index exists. Poll asynchronous work with `get_index_status`.

## Rules

- Prefer graph relationships over assumptions based on filenames.
- Resolve an exact symbol before requesting its source.
- Separate confirmed graph evidence from inference.
- Treat absent mutation tools as the expected safe permission boundary.
- Do not use `rename_symbol`, `replace_symbol_body`, `move_symbol` or
  `submit_code_feedback` unless the tool is present and the user requested a
  change.
- Use episode tools only for durable code-specific observations, not ordinary
  conversational notes.
