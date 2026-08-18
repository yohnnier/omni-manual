#!/usr/bin/env bash
# Se ejecuta al inicio de cada sesion de Claude Code.
# Lee entorno/VPS-ACTIVO y lo inyecta al contexto, para que Claude sepa
# siempre sobre que VPS debe trabajar aunque la conversacion se resuma.

set -uo pipefail
cd "$(dirname "$0")/../.." 2>/dev/null || exit 0

ARCHIVO="entorno/VPS-ACTIVO"
[ -r "$ARCHIVO" ] || exit 0

VPS="$(head -n1 "$ARCHIVO" | tr -d '[:space:]')"
[ -n "$VPS" ] || exit 0

DATOS="$(python3 - "$VPS" <<'PY' 2>/dev/null
import json, sys
try:
    d = json.load(open('entorno/entornos.json'))
except Exception:
    sys.exit(0)
for e in d.get('entornos', []):
    if e.get('id') == sys.argv[1]:
        r = e.get('recursos', {})
        print("IP %s | %s | %s CPU, %s GiB RAM, %s GB disco | rol: %s" % (
            e.get('ip','?'), e.get('cloud','?'),
            r.get('cpu','?'), r.get('ram_gib','?'), r.get('disco_gb','?'),
            e.get('rol','sin definir')))
        break
PY
)"

CONTEXTO="VPS ACTIVO DE ESTE PROYECTO: $VPS"
[ -n "$DATOS" ] && CONTEXTO="$CONTEXTO
$DATOS"
CONTEXTO="$CONTEXTO

Este es el servidor seleccionado por el usuario en entorno/VPS-ACTIVO.
Todo comando, script o configuracion que prepares debe apuntar a $VPS
salvo que el usuario nombre otro servidor explicitamente en su mensaje.
Si una peticion no encaja con $VPS, avisale antes de continuar.
Claude Code NO tiene acceso de red a los VPS: prepara las instrucciones
para que el usuario las ejecute por SSH desde su equipo."

python3 -c '
import json,sys
print(json.dumps({"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":sys.stdin.read()}}))
' <<< "$CONTEXTO"
