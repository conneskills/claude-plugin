# Changelog

## 2.0.1

### Esquema de base de datos determinista

- `database_list_schemas`, `database_list_tables` y
  `database_describe_table` se documentan como tools de **Knowledge**. Reciben
  `kb_id`, leen exclusivamente el último snapshot indexado y nunca abren una
  conexión a la base de datos viva.
- La skill de Knowledge explica los campos de tamaño, relaciones, riesgo y
  warnings que hay que revisar antes de preparar una consulta.
- La skill y el inventario de Connectors dejan de atribuirse esas tres tools.
  La familia DB viva queda formada por discovery, `database_count`,
  `database_select` y `database_aggregate`.
- El validador comprueba las cinco URIs canónicas y la propiedad de las tools de
  base de datos para evitar que el contrato vuelva a divergir del servidor.

No cambian las URLs ni los permisos respecto a `2.0.0`, por lo que esta
actualización no requiere una nueva autorización OAuth.

## 2.0.0

### Nuevo: servidor Connectors

`conneskills-connectors` (`/api/mcp/connectors`) expone los datos vivos de las
conexiones del workspace: bases de datos, documentos, issue trackers,
repositorios y datasets de BI.

El servidor existía en la plataforma pero **no se podía instalar en un cliente
MCP**: no era un recurso OAuth, así que contestaba un `401` sin
`WWW-Authenticate` y sin ese puntero (RFC 9728) el cliente no tenía ningún
documento que descubrir — no llegaba a abrir la pantalla de consentimiento. Con
Connectors como dominio OAuth propio, el flujo es el mismo que el de los otros
cuatro.

> Requiere la versión de la plataforma que publica
> `/.well-known/oauth-protected-resource/api/mcp/connectors`. Contra una versión
> anterior, este servidor no autoriza.

### Breaking: URIs canónicas y renombrado de KBS → Knowledge

Los cinco servidores apuntan ya a las URIs canónicas, y `conneskills-kbs` pasa a
llamarse `conneskills-knowledge`, como el producto en el catálogo.

| Antes | Ahora |
|---|---|
| `conneskills-kbs` → `/api/mcp/kbs` | `conneskills-knowledge` → `/api/mcp/knowledge` |
| `conneskills-code` → `/api/mcp/brain/code` | `conneskills-code` → `/api/mcp/code` |
| `conneskills-memory` → `/api/mcp/brain/memory` | `conneskills-memory` → `/api/mcp/memory` |
| `conneskills-planning` → `/api/mcp/brain/planning` | `conneskills-planning` → `/api/mcp/planning` |

**Qué tienes que hacer al actualizar:**

1. **Volver a autorizar los cuatro servidores desde `/mcp`.** El cliente guarda
   el token por URL, así que una URL nueva es un servidor nuevo para él. Los
   grants del workspace no se pierden: el dominio OAuth es el mismo.
2. **Revisar allowlists de permisos.** Los nombres de tool del servidor de
   conocimiento cambian de `mcp__…conneskills-kbs__*` a
   `mcp__…conneskills-knowledge__*`.

Los paths antiguos siguen sirviendo hasta el sunset del 2027-08-20, así que una
instalación 1.x no se rompe: simplemente sigue usando paths deprecados.

### Skills

- Nueva skill `conneskills-connectors`, con el inventario de tools por familia
  en `references/tool-families.md`.
- `conneskills-kbs` → `conneskills-knowledge`, con la regla de enrutado
  explícita: el índice primero para saber **qué** preguntar (incluida la tabla o
  el campo), el conector después para el valor actual.
- `conneskills-code` mueve el catálogo de ~45 tools a
  `references/tool-map.md`, agrupado por la acción que exige cada una.
- Las cinco descripciones se reescriben para disparar de forma fiable, con
  frases reales de usuario en español y en inglés. El coste siempre-en-contexto
  sube de ~525 tok (4 skills) a ~900 tok (5 skills): es lo que se paga por que
  la skill se active cuando toca, que es el fallo que de verdad cuesta.
- Todas explican el **por qué** de sus límites (una tool ausente es un permiso
  no concedido, no un fallo) en lugar de enumerar prohibiciones.

### Validación

`scripts/validate.py` (y su workflow) comprueban lo que no se ve en un diff: que
el frontmatter de cada skill parsea como YAML —una descripción con `: ` dentro
lo rompe y se publica en silencio—, que `name` coincide con su directorio, que
cada servidor de `.mcp.json` tiene skill y viceversa, y que las versiones de los
dos manifiestos cuadran.

## 1.0.1

- Los dominios Code, Memory y Planning se enrutan por los endpoints
  `/api/mcp/brain/*`.

## 1.0.0

- Primera versión: KBS, Code, Memory y Planning como cuatro recursos OAuth.
