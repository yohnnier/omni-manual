---
description: Ver o cambiar el VPS activo del proyecto (VPSVIMED, ASENFCUARTA, ASENF20)
---

VPS activo actual: !`cat entorno/VPS-ACTIVO 2>/dev/null || echo "(ninguno)"`

Servidores registrados: !`python3 -c "import json;d=json.load(open('entorno/entornos.json'));[print(' -',e['id'],'|',e['ip'],'| alias:',', '.join(e.get('alias',[]))) for e in d['entornos']]" 2>/dev/null`

El usuario escribió: **$ARGUMENTS**

Actúa así:

- **Si $ARGUMENTS está vacío**: muéstrale cuál es el VPS activo con sus datos
  (IP, recursos, rol). No cambies nada.

- **Si $ARGUMENTS trae un nombre**: resuélvelo contra `entorno/entornos.json`
  con tolerancia — sin distinguir mayúsculas, aceptando el `id` completo,
  cualquier valor de su lista `alias`, o una coincidencia parcial inequívoca
  (`vimed` → `VPSVIMED`, `cuarta` → `ASENFCUARTA`, `20` → `ASENF20`).
  - Si resuelve a un solo servidor: escribe su `id` en mayúsculas en
    `entorno/VPS-ACTIVO` (una línea) y confirma mostrando IP, recursos y rol.
  - Si es ambiguo o no resuelve: dile los nombres válidos con sus alias y no
    cambies nada.

A partir de ese momento, todo comando o configuración que prepares en esta
conversación debe apuntar al VPS activo, salvo que el usuario nombre otro
explícitamente.

Recuérdale, solo si es relevante, que esto fija el destino de las
instrucciones que preparas — no abre ninguna conexión con el servidor.
