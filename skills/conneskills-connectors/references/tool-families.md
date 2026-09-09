# Connector tool inventory

Tools are registered per family, and a family appears only when the credential
holds its read action. `list_active_connections` is discovery and is unlocked by
*any* connector read.

Every tool takes a connection ID from `list_active_connections` (or from its own
family's `*_list_connections`).

## general — unlocked by any connector read

| Tool | Purpose |
|---|---|
| `list_active_connections` | Every MCP-enabled connection, grouped by family. Start here. |

## database — `connectors:database:read`

Reads run through the configured database connection with structured arguments;
there is no SQL string to compose.

| Tool | Purpose |
|---|---|
| `database_list_connections` | Database connections only. |
| `database_count` | Row count, with optional filters. The right tool for "how many". |
| `database_aggregate` | `group_by` + aggregates. The right tool for totals and breakdowns. |
| `database_select` | Rows, with columns, filters, `order_by`, `limit`, `offset`. |

Notes that save a wrong answer:

- `database_select` always applies a limit. Treat a full page of rows as
  possibly truncated and say so.
- Filters and `group_by` are argument objects, not fragments of SQL text. If the
  question needs a join or a window function, no argument set expresses it — say
  what is missing instead of approximating with several selects.
- Identifiers are case- and schema-sensitive. Resolve them first with the
  deterministic `database_list_schemas`, `database_list_tables` and
  `database_describe_table` tools on `conneskills-knowledge`; they are
  intentionally absent from this live surface.

## document — `connectors:document:read`

Google Drive, OneDrive/SharePoint, GitHub as a document source.

| Tool | Purpose |
|---|---|
| `document_list_connections` | Document connections. |
| `document_list_directories` | Folders under a path. |
| `document_list_files` | Files in a folder. |
| `document_read_file` | A file's current contents. |

A large document read is expensive and can flood context. Narrow with the
listing tools first, and prefer the indexed KB when the user wants *what a
document says* rather than its exact current bytes.

## issue — `connectors:issue:read`

Jira and GitHub Issues.

| Tool | Purpose |
|---|---|
| `issue_list_connections` | Issue-tracker connections. |
| `issue_list_projects` | Projects/repositories available. |
| `issue_list_issues` | Issues, filtered. |
| `issue_get_issue` | One issue in full, by key. |

## code — `connectors:code:read`

Repository browsing on the live remote. This is *not* the code graph: for
symbols, callers, impact and architecture use `conneskills-code`, which answers
from an index built for exactly that.

| Tool | Purpose |
|---|---|
| `code_list_connections` | Code connections. |
| `code_list_repositories` | Repositories available. |
| `code_list_files` | Files in a path. |
| `code_read_file` | A file's current contents on the remote. |

## warehouse — `connectors:warehouse:read`

Power BI today; the family is the BI/warehouse surface, not one vendor.

| Tool | Purpose |
|---|---|
| `warehouse_list_connections` | Warehouse connections. |
| `warehouse_list_datasets` | Datasets in a connection. |
| `warehouse_describe_dataset` | Tables, columns and measures of a dataset. |
| `warehouse_aggregate` | Grouped aggregation over a dataset. |
| `warehouse_evaluate_measure` | Evaluate a defined measure — use the model's own measure rather than recomputing it. |
| `warehouse_query_table` | Rows from a dataset table. |
| `warehouse_dataset_refresh_status` | Last refresh. Check it before presenting a figure as current. |

The `powerbi_*` names are legacy aliases of these seven, kept during the
deprecation window and served by the same handlers.
