# Conneskills Code tools by purpose

Grouped by the action each needs. The default consent grants `code:read`,
`code:index` and `code:episodes`; `code:write` is opt-in, so the mutation tools
are usually absent.

## Orientation — `code:read`

| Tool | Use it for |
|---|---|
| `list_projects` | Which repositories are indexed. Start here when unsure. |
| `get_architecture` | High-level structure before reading anything. |
| `analyze_structure` | Structural breakdown of a subtree. |
| `get_api_surface` | What a module or service exposes publicly. |
| `load_context` | A bundled context pack for a task. |

## Finding a symbol — `code:read`

| Tool | Use it for |
|---|---|
| `search_graph` | Name or qualified-name patterns, filtered by label. The default finder. |
| `semantic_code_search` | You know the behavior, not the name. |
| `search_code` | Literal text: config keys, error strings, magic values. |
| `find_symbol_definition` | Resolve a name to its definition. |
| `get_symbols_overview` | What a file or package defines. |
| `graph_list` | Enumerate nodes of a kind. |
| `extract_symbol` | Pull one symbol out with its immediate context. |

## Reading source — `code:read`

| Tool | Use it for |
|---|---|
| `get_code_snippet` | Exact source of a qualified name, precise ranges. |
| `read_symbol_code` | Source of a resolved symbol. |

## Relationships and impact — `code:read`

| Tool | Use it for |
|---|---|
| `trace_path` | Call chains and data flow between two points. |
| `find_references` | Every use of a symbol, resolved rather than textual. |
| `get_blast_radius_graph` | What a change to this reaches. |
| `get_cross_repo_impact` | The same question across repository boundaries. |
| `query_graph` | Cypher, for patterns the specific tools do not cover. |
| `plan_refactor` | A proposed change plan from the graph. |

## Quality and history — `code:read`

| Tool | Use it for |
|---|---|
| `find_dead_code_graph` | Unreferenced symbols. Check the graph is complete before acting on it. |
| `get_clones` | Duplicated code. |
| `get_temporal_diff` | What changed between two points. |
| `get_regression_suspects` | Likely culprits for a regression. |
| `analyze_sast` | Static security findings. |
| `frontend_gaps` | Frontend coverage gaps. |
| `detect_changes` | Drift between the index and the working tree. |

## Indexing — `code:index`

| Tool | Use it for |
|---|---|
| `index_repo` | Build or refresh an index. On request only — it is expensive. |
| `get_index_status` | Poll asynchronous indexing. |

## Episodes — `code:episodes`

| Tool | Use it for |
|---|---|
| `observe_episode` | Record a durable code-specific finding. |
| `recall_episode` | Retrieve past findings for this code. |
| `consolidate_episode` | Merge related findings. |
| `episode_stats` | What has been recorded. |

## Mutation — `code:write`, usually not granted

| Tool | Use it for |
|---|---|
| `rename_symbol` | Rename across every resolved reference. |
| `replace_symbol_body` | Replace an implementation. |
| `move_symbol` | Move a symbol between files/modules. |
| `resolve_calls` | Writes CALLS edges into the graph — a write even when auditing. |
| `submit_code_feedback` | Record feedback against the graph. |
