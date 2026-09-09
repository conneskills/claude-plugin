# Indexed database schema contract

Use these tools when the user needs exact database structure or when a live
query must be prepared safely. They read the latest indexed KB snapshot and
never open the source database.

## Tools

| Tool | Required arguments | Result |
|---|---|---|
| `database_list_schemas` | `kb_id` | Schemas plus table, view and procedure counts. |
| `database_list_tables` | `kb_id`, `schema`; optional `limit`, `offset` | Deterministically paginated tables/views with row counts, sizes, risk, warnings and relationship counts. |
| `database_describe_table` | `kb_id`, `schema`, `table` | Exact columns, keys, indexes, incoming/outgoing relationships, constraints, triggers, size, risk and warnings. |

The multi-KB Knowledge server requires `kb_id`. Obtain it from
`list_knowledge_bases` and use only a ready KB backed by a database connector.
The embedded single-KB agent injects the KB ID itself, so its scoped form omits
that argument.

## Source guarantees

Every successful result identifies itself with:

- `source: knowledge_base_index`
- `deterministic: true`
- `live_database_queried: false`
- `snapshot_notice`, because the structure reflects the last completed sync

If indexed schema retrieval fails, the tool reports that no live fallback was
attempted. Do not replace that failure with schema discovery against Connectors.

## Reading table metadata

`database_list_tables` is for inventory and triage. Check:

- `row_count` and `row_count_approximate`
- `size_mb`, `index_size_mb` and `total_size_mb`
- `performance_risk`
- incoming and outgoing relationship counts
- ordered `warnings`

`database_describe_table` is the authority before naming columns or filters. It
adds the complete structural metadata needed to understand joins and access
paths.

Warnings are derived from indexed facts in a stable order. Current warning
codes include:

- `large_table_scan_risk`
- `approximate_row_count`
- `table_level_locking`
- `no_indexed_filter_columns`
- `table_bloat`

Treat them as query-planning constraints. They describe the indexed snapshot,
not proof that the live database is unchanged.

## Boundary with Connectors

These schema tools belong to Knowledge and require `kb:query`. The live
Connectors database surface contains only:

- `database_list_connections`
- `database_count`
- `database_select`
- `database_aggregate`

Use those only when the answer requires current rows or aggregates, after the
indexed schema has identified the real objects and risks.
