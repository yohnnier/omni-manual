---
description: Ver o cambiar el VPS activo del proyecto (VPSVIMED, ASENFCUARTA, ASENF20)
---

VPS activo actual: !`cat entorno/VPS-ACTIVO 2>/dev/null || echo "(ninguno)"`

Servidores registrados: !`python3 -c "import json;d=json.load(open('entorno/entornos.json'));[print(' -',e['id'],'|',e['ip'],'|',e['cloud']) for e in d['entornos']]" 2>/dev/null`

El usuario escribió: **$ARGUMENTS**

Actúa así:

- **Si $ARGUMENTS está vacío**: solo muéstrale cuál es el VPS activo con sus datos
  (IP, recursos, rol). No cambies nada.

- **Si $ARGUMENTS trae un nombre de servidor**: verifica que exista en
  `entorno/entornos.json`. Si existe, escríbelo en `entorno/VPS-ACTIVO` (solo el
  nombre, en mayúsculas, una línea) y confirma el cambio mostrando los datos del
  nuevo servidor. Si no existe, dile cuáles son los nombres válidos y no cambies
  nada.

A partir de ese momento, todo comando o configuración que prepares en esta
conversación debe apuntar al VPS activo, salvo que el usuario nombre otro
explícitamente.
