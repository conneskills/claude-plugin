---
name: conneskills-code
description: Answer questions about an indexed codebase from the Conneskills Code graph — architecture, where a symbol is defined, who calls what, data flow, blast radius, cross-repository impact, regression suspects and dead code. Use it whenever a question spans more of a codebase than you can comfortably read — "how does X work here", "who calls this", "what breaks if I change this", "trace this flow", "is this dead code", and Spanish "quién llama a", "qué se rompe si cambio", "cómo funciona esto", "traza el flujo", "dónde está definido". Prefer it over grep and broad filesystem sweeps — the graph knows relationships text search can only guess at.
---

# Conneskills Code

The index holds resolved relationships — definitions, calls, references,
inheritance, cross-repo edges. That is the difference from text search: grep
finds a name, the graph tells you whether it is the same symbol. So for anything
relational, query the graph first; drop to reading files when you need the exact
current text of something the graph pointed you at.

## Workflow

1. Call `list_projects` when the indexed project is not already known. An
   answer about the wrong repository is worse than no answer.
2. Start wide for orientation questions: `get_architecture` before diving into
   files, so what you read afterwards has somewhere to sit.
3. Locate the symbol. `search_graph` when you know roughly what it is called,
   `semantic_code_search` when you only know what it does, `search_code` for
   literal text like a config key or an error string.
4. Resolve to one symbol before asking for source. `get_code_snippet` and
   `read_symbol_code` are precise; guessing a qualified name wastes a call and
   can return a same-named symbol from elsewhere.
5. Follow relationships with `trace_path`, `find_references`,
   `get_blast_radius_graph` or `get_cross_repo_impact`. This is what the graph
   is for, and it is where hand-rolled searching goes wrong most often.

`references/tool-map.md` lists the full toolset by purpose, including the
analysis tools worth knowing about (`get_regression_suspects`,
`find_dead_code_graph`, `get_clones`, `get_api_surface`, `analyze_sast`).

Index only on request: `index_repo` when the user asks or no usable index
exists, then poll with `get_index_status` rather than assuming it finished.

## Saying what the graph does and does not tell you

An index is a snapshot. When it looks stale or thin — a symbol the user mentions
is absent, or edge counts look implausibly low — say so, because the honest
failure ("this may not be indexed") sends the user somewhere useful, while a
confident answer from a stale graph does not.

Keep graph evidence and your own inference distinguishable. "`trace_path` shows
A → B → C" and "so this is probably where the timeout comes from" are different
claims, and the second is the one worth flagging as yours.

## Mutation tools

The default consent covers reading, indexing and episodes — not writes. So
`rename_symbol`, `replace_symbol_body`, `move_symbol`, `resolve_calls` and
`submit_code_feedback` usually are not registered at all, and that absence is
the safe default working as designed, not something to work around.

When they are present, use them only for a change the user actually asked for:
they edit real code across every file the graph says is affected, which is
exactly the power that makes an unrequested call expensive to undo.

Episode tools (`observe_episode`, `recall_episode`, `consolidate_episode`) are
for durable, code-specific findings — the non-obvious reason a module is shaped
the way it is. Ordinary conversational notes belong in `conneskills-memory`.
