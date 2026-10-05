<!--
Gracias por el PR. Si el cambio toca código/producto, rellena la sección
"Evidencia AI-DLC". Política: PRO-378#document-policy.
-->

## Qué cambia

<!-- Describe el cambio y por qué. -->

## Evidencia AI-DLC

<!--
Obligatoria para cambios de código/producto en los 4 repos de conneskills-platform.
Referencia el workflow/plan AI-DLC y la verificación build/test. Ejemplo:

- Workflow: `.aidlc/scopes/<scope>.md` (estado persistido en `.aidlc/`)
- Plan: aprobado — PRO-### #document-plan
- Verificación: `pnpm test` / `pytest` → verde

Si el cambio está exento (solo docs/config trivial, o incidente/rollback con
AI-DLC retroactivo en 24 h), escribe en su lugar una línea:

AI-DLC-Exempt: <motivo>

Borra este comentario y rellena la sección.
-->

- Workflow:
- Plan:
- Verificación:

## Checklist

- [ ] Evidencia AI-DLC incluida (o exención declarada con `AI-DLC-Exempt:`)
- [ ] Build/test verificado y registrado
