# Conneskills — Plugin de Claude

Conecta Claude (claude.ai, Claude Code o la Messages API) al contexto gobernado de tu
empresa en Conneskills: knowledge bases, bases de datos conectadas, documentos, Jira y
código — con OAuth por empleado, permisos por equipo, auditoría y medición de consumo.

**El punto:** tu empresa ya usa Anthropic. No tiene que dejar de usarlo — Conneskills se
enchufa como una fuente de contexto más, en 2 minutos.

Un solo endpoint sirve las tres superficies: `https://<tu-host>/api/mcp/plugin`.

---

## 1. Claude Code (este plugin)

```bash
/plugin marketplace add conneskills/claude-plugin
/plugin install conneskills@conneskills
```

Al primer uso, Claude Code abre el navegador para el login OAuth de Conneskills
(el usuario aprueba en la página de consentimiento; sin API keys que copiar).
Autenticación manual si hiciera falta: `/mcp` → conneskills → Authenticate.

Alternativa sin marketplace:

```bash
claude mcp add --transport http conneskills https://<tu-host>/api/mcp/plugin
```

## 2. claude.ai (Team / Enterprise) — custom connector

No requiere artefacto: Settings → Connectors → **Add custom connector** → pegar
`https://<tu-host>/api/mcp/plugin`. El registro de cliente OAuth es automático (DCR);
cada empleado autoriza con SU cuenta de Conneskills y ve solo lo que su scope permite.

## 3. Messages API (agentes propios del cliente)

```json
{
  "mcp_servers": [{
    "type": "url",
    "url": "https://<tu-host>/api/mcp/plugin",
    "name": "conneskills",
    "authorization_token": "csk_live_..."
  }]
}
```

---

## Qué obtiene Claude

| Capability | Tools | Scope OAuth |
|---|---|---|
| Knowledge bases | `list_knowledge_bases`, `search_knowledge_base` | `kb:query` |
| Conexiones en vivo | `list_active_connections`, `database_*` (read-only), `document_*`, `issue_*`, `code_*` | `connectors:read` |

Todo con: RLS multi-tenant, scope personal por empleado (workspace ∩ equipos ∩ personal),
atribución de gasto `user:<id>`, rate limiting y ledger de créditos por tool call.

## Requisitos del lado Conneskills

- Feature flag `integrations.claude_plugin` activo para el workspace (gate por plan).
- Plugin habilitado y capabilities seleccionadas en la config del workspace
  (`workspace_plugin_configs`).
- `PLUGIN_PUBLIC_URL` apuntando al origen público https (en dev: el túnel
  cloudflared/ngrok). La página de consentimiento corre en `APP_BASE_URL`.

## Estructura

```
.claude-plugin/plugin.json        # manifiesto del plugin (incluye el MCP server remoto)
.claude-plugin/marketplace.json   # catálogo para /plugin marketplace add
skills/conneskills/SKILL.md       # enseña a Claude el workflow KB → datos en vivo
```

> Nota de distribución: para instalarlo con `/plugin marketplace add conneskills/claude-plugin`,
> este directorio se publica como repo público `conneskills/claude-plugin` (o se agrega por
> ruta git del monorepo). El contenido es estático — no hay build.
