# Conneskills — plugin para Claude Code

Conecta Claude Code con cuatro superficies gobernadas de Conneskills:
**Conneskills KBS**, **Conneskills Code**, **Conneskills Memory** y
**Conneskills Planning**. Cada superficie usa un recurso MCP y consentimiento
OAuth independientes.

## Instalación

```text
/plugin marketplace add conneskills/claude-plugin
/plugin install conneskills@conneskills
```

Al primer uso, autentica cada recurso desde `/mcp`. El servidor publica
Protected Resource Metadata y registra clientes dinámicamente; no hay API keys
que copiar.

## Recursos incluidos

| Recurso | URL | Uso |
|---|---|---|
| Conneskills KBS | `https://app.conneskills.com/api/mcp/kbs` | KBs y conectores gobernados |
| Conneskills Code | `https://app.conneskills.com/api/mcp/code` | Índice y grafo de código |
| Conneskills Memory | `https://app.conneskills.com/api/mcp/memory` | Memoria e intenciones |
| Conneskills Planning | `https://app.conneskills.com/api/mcp/planning` | Planes y gobernanza |

Los permisos seguros por defecto no incluyen escritura de código, borrado de
memoria ni gestión de ADRs. La disponibilidad final de cada tool depende del
workspace y de los scopes concedidos.

## Uso sin marketplace

```bash
claude mcp add --transport http conneskills-kbs https://app.conneskills.com/api/mcp/kbs
claude mcp add --transport http conneskills-code https://app.conneskills.com/api/mcp/code
claude mcp add --transport http conneskills-memory https://app.conneskills.com/api/mcp/memory
claude mcp add --transport http conneskills-planning https://app.conneskills.com/api/mcp/planning
```

Para preguntas sobre datos, la skill de KBS consulta primero el conocimiento
indexado. Sólo usa el conector en vivo cuando se necesitan valores actuales o
una consulta estructurada que el índice no puede resolver.

## Compatibilidad

`/api/mcp/plugin` continúa disponible como alias heredado de KBS, pero no
incluye Code, Memory ni Planning y no debe usarse en instalaciones nuevas.

El workspace debe tener activo temporalmente el feature flag
`integrations.claude_plugin` para KBS. El nombre del flag se mantiene por
compatibilidad y se generalizará en una entrega posterior.
