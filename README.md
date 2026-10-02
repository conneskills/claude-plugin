# Conneskills — plugin para Claude Code

Conecta Claude Code con seis superficies gobernadas de Conneskills:
**Knowledge**, **Connectors**, **Code**, **Memory**, **Planning** e **Insights**. Cada una es
un recurso MCP independiente con su propio consentimiento OAuth, así que
autorizas solo lo que vas a usar.

## Instalación

```text
/plugin marketplace add conneskills/claude-plugin
/plugin install conneskills@conneskills
```

Al primer uso, autoriza cada recurso desde `/mcp`. El servidor publica Protected
Resource Metadata (RFC 9728) y registra clientes dinámicamente: no hay API keys
que copiar ni configurar.

## Recursos incluidos

| Servidor | URL | Para qué |
|---|---|---|
| `conneskills-knowledge` | `https://app.conneskills.com/api/mcp/knowledge` | Conocimiento indexado y esquema DB determinista, con citas |
| `conneskills-connectors` | `https://app.conneskills.com/api/mcp/connectors` | Valores **vivos** de las conexiones autorizadas |
| `conneskills-code` | `https://app.conneskills.com/api/mcp/code` | Grafo de código: símbolos, relaciones, impacto |
| `conneskills-memory` | `https://app.conneskills.com/api/mcp/memory` | Memoria a largo plazo e intenciones |
| `conneskills-planning` | `https://app.conneskills.com/api/mcp/planning` | Planes gobernados, evidencia y gates |
| `conneskills-insights` | `https://app.conneskills.com/api/mcp/insights` | Radar de señales: riesgos y oportunidades **ya calculados** sobre tus datos |

## Knowledge o Connectors: cuál usar

Es la decisión que más cambia la calidad de una respuesta.

- **Knowledge** responde *qué sabemos, cómo se hace, dónde está documentado* y
  expone el esquema exacto de las bases de datos indexadas: tablas, columnas,
  claves, relaciones, índices, tamaños, riesgo y warnings. Ese contrato es
  determinista y nunca consulta la base de datos viva.
- **Connectors** responde *cuál es el valor ahora mismo*. Para bases de datos
  conserva únicamente las operaciones vivas de conexión, count, select y
  aggregate; consultar la fuente es más lento, carga el sistema conectado y
  factura.

El orden que funciona es Knowledge primero para resolver el esquema y entender
los warnings; Connectors después, y solo si hace falta un valor actual. Las
skills incluidas aplican esa separación explícitamente.

## Insights: cuándo usarlo

**Insights** responde *qué necesita una decisión y no estoy viendo*. No recibe
tablas, fechas ni métricas: la plataforma ejecuta cada día playbooks firmados
sobre los sistemas conectados y estas herramientas leen el resultado, con la
acción recomendada por una decisión publicada. Para «¿cómo va el negocio?» o
«arma un tablero de riesgos», va primero. Para un valor puntual de una tabla,
sigue siendo Connectors.

`insights:read` es opt-in; `insights:outcome` (registrar qué pasó con una señal)
se concede aparte porque escribe.

## Permisos

Los permisos por defecto son de lectura. No incluyen escritura de código,
borrado ni promoción de memoria, ni gestión de ADRs: esas acciones se conceden
a mano desde el Access Group del workspace.

Que una tool no aparezca es el límite de permisos funcionando, no un fallo: el
workspace no concedió esa acción a tu credencial. La disponibilidad final
depende del workspace, del plan y de los scopes consentidos.

## Uso sin marketplace

```bash
claude mcp add --transport http conneskills-knowledge  https://app.conneskills.com/api/mcp/knowledge
claude mcp add --transport http conneskills-connectors https://app.conneskills.com/api/mcp/connectors
claude mcp add --transport http conneskills-code       https://app.conneskills.com/api/mcp/code
claude mcp add --transport http conneskills-memory     https://app.conneskills.com/api/mcp/memory
claude mcp add --transport http conneskills-planning   https://app.conneskills.com/api/mcp/planning
claude mcp add --transport http conneskills-insights   https://app.conneskills.com/api/mcp/insights
```

## Compatibilidad

Los paths anteriores siguen sirviendo peticiones durante su ventana de
deprecación (sunset **2027-08-20**) y responden con las cabeceras `Deprecation`,
`Sunset` y `Link: rel="successor-version"`:

| Path deprecado | Sucesor |
|---|---|
| `/api/mcp/kbs` | `/api/mcp/knowledge` |
| `/api/mcp/plugin` | `/api/mcp/knowledge` |
| `/api/mcp/rag` | `/api/mcp/knowledge` |
| `/api/mcp/brain/code` | `/api/mcp/code` |
| `/api/mcp/brain/memory` | `/api/mcp/memory` |
| `/api/mcp/brain/planning` | `/api/mcp/planning` |

Las instalaciones nuevas deben usar las URIs canónicas de la tabla de recursos.
Si vienes de la 1.x, mira el [CHANGELOG](CHANGELOG.md): las URLs cambiaron y hay
que volver a autorizar una vez.

El workspace necesita el feature flag `integrations.mcp` activo.
