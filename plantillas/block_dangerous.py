#!/usr/bin/env python3
"""Hook PreToolUse de Claude Code: bloquea comandos de Bash peligrosos.

Claude Code envía por stdin un JSON con la herramienta a ejecutar.
Si el comando coincide con un patrón bloqueado, se sale con código 2 y el
mensaje de stderr se devuelve a Claude. En cualquier otro caso sale con 0.

Esta capa complementa las deny rules, el sandbox y el contenedor; no es una
frontera de seguridad por sí sola.
"""
import json
import re
import sys

PATRONES_BLOQUEADOS = [
    (r"(curl|wget)[^|]*\|\s*(sudo\s+)?(ba|z|da)?sh", "pipe de descarga a shell"),
    (r"--dangerously-skip-permissions", "bypass de permisos"),
    (r"\brm\s+-rf\s+(/|~|\$HOME|\*)", "borrado recursivo peligroso"),
    (r"\bchmod\s+(-R\s+)?777\b", "permisos 777"),
    (r"\b(cat|less|head|tail)\s+[^|;]*\.(env|pem|key)\b[^|;]*\|", "posible exfiltración de secretos"),
    (r"(base64|xxd)[^|]*\|\s*(curl|wget|nc)", "posible exfiltración codificada"),
    (r"\bnc\s+-[el]", "netcat en escucha"),
    (r"\bDROP\s+(DATABASE|SCHEMA)\b", "borrado de base de datos"),
]


def main() -> int:
    try:
        datos = json.load(sys.stdin)
    except json.JSONDecodeError:
        return 0

    if datos.get("tool_name") != "Bash":
        return 0

    comando = datos.get("tool_input", {}).get("command", "")
    for patron, motivo in PATRONES_BLOQUEADOS:
        if re.search(patron, comando, re.IGNORECASE):
            print(
                f"Bloqueado por política de seguridad del proyecto: {motivo}. "
                "Pide confirmación explícita al usuario.",
                file=sys.stderr,
            )
            return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
