#!/usr/bin/env bash
# Instala el skill seguridad-web como skill personal de Claude Code.
#
# Uso:
#   ./install.sh                    # solo enlaza el skill en ~/.claude/skills/
#   ./install.sh /ruta/proyecto     # además copia las plantillas al proyecto
#                                   # (nunca sobrescribe ficheros existentes)

set -euo pipefail

ORIGEN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DESTINO_SKILL="${HOME}/.claude/skills/seguridad-web"

mkdir -p "${HOME}/.claude/skills"

if [ -L "${DESTINO_SKILL}" ] || [ ! -e "${DESTINO_SKILL}" ]; then
  ln -sfn "${ORIGEN}" "${DESTINO_SKILL}"
  echo "Skill enlazado: ${DESTINO_SKILL} -> ${ORIGEN}"
else
  echo "Ya existe ${DESTINO_SKILL} y no es un enlace. Muévelo o bórralo y repite."
  exit 1
fi

if [ "${1:-}" != "" ]; then
  PROYECTO="$1"
  if [ ! -d "${PROYECTO}" ]; then
    echo "No existe el directorio del proyecto: ${PROYECTO}"
    exit 1
  fi

  copiar_si_no_existe() {
    local origen="$1" destino="$2"
    if [ -e "${destino}" ]; then
      echo "Omitido (ya existe): ${destino}"
    else
      mkdir -p "$(dirname "${destino}")"
      cp "${origen}" "${destino}"
      echo "Creado: ${destino}"
    fi
  }

  copiar_si_no_existe "${ORIGEN}/plantillas/CLAUDE.md" "${PROYECTO}/CLAUDE.md"
  copiar_si_no_existe "${ORIGEN}/plantillas/settings.json" "${PROYECTO}/.claude/settings.json"
  copiar_si_no_existe "${ORIGEN}/plantillas/block_dangerous.py" "${PROYECTO}/.claude/hooks/block_dangerous.py"
  chmod +x "${PROYECTO}/.claude/hooks/block_dangerous.py" 2>/dev/null || true
fi

echo "Listo. Reinicia Claude Code o abre una sesión nueva para cargar el skill."
