# seguridad-web

Skill personal para Claude Code que aplica reglas de seguridad al crear, modificar o revisar proyectos web y apps.

## Contenido

| Fichero | Función |
|---|---|
| `SKILL.md` | Reglas obligatorias, flujo de trabajo y acciones que requieren confirmación. Se carga cuando la tarea coincide con su descripción. |
| `checklist.md` | Checklist por áreas para revisar antes de cada entrega y antes de cada deploy. |
| `ejemplos.md` | Patrones inseguros frecuentes en código generado con IA y su versión segura. |
| `plantillas/CLAUDE.md` | Reglas de seguridad para copiar a la raíz de un proyecto. |
| `plantillas/settings.json` | Deny rules y configuración del hook para `.claude/settings.json`. |
| `plantillas/block_dangerous.py` | Hook `PreToolUse` que bloquea comandos peligrosos de Bash. |
| `install.sh` | Enlaza el skill en `~/.claude/skills/` y, opcionalmente, copia las plantillas a un proyecto. |

## Instalación

```bash
git clone <URL_DEL_REPOSITORIO> ~/seguridad-web-skill
cd ~/seguridad-web-skill
./install.sh                     # skill personal
./install.sh ~/mi-proyecto       # además, plantillas en el proyecto
```

`install.sh` crea un enlace simbólico, así que `git pull` actualiza el skill sin volver a instalarlo.

Para verificar: abre Claude Code y escribe `/skills`; debe aparecer `seguridad-web`.

### Plugins complementarios de Trail of Bits (opcional, recomendado)

El skill usa, si están instalados, plugins del marketplace público [`trailofbits/skills`](https://github.com/trailofbits/skills). No se incluyen en este repositorio. Dentro de Claude Code:

```
/plugin marketplace add trailofbits/skills
/plugin menu
```

Desde `/plugin menu` instala al menos `static-analysis`, `insecure-defaults`, `supply-chain-risk-auditor`, `differential-review` y `fp-check`. Añade `modern-python`, `c-review` o `rust-review` según el lenguaje del proyecto.

## Actualizar

```bash
cd ~/seguridad-web-skill && git pull
```

## Notas

- Las deny rules y el hook reducen riesgos, pero no son una frontera de seguridad. Úsalos junto con `/sandbox` y, en proyectos sensibles, con un contenedor.
- Revisa cualquier skill de terceros que instales antes de activarla: pueden contener instrucciones maliciosas.
- Este skill se basa en una guía propia y en buenas prácticas OWASP. Verifica la sintaxis de configuración de Claude Code en la documentación oficial si cambia.
- Los plugins de `trailofbits/skills` no se redistribuyen aquí. Su contenido tiene licencia CC-BY-SA-4.0 y se instala desde su marketplace oficial.
