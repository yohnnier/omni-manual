# omni-manual

Asistente clínico del equipo B.Braun OMNI (TCRR/TPE) para UTI. Es una
aplicación de un solo archivo estático: `index.html`.

## VPS activo — LEER ANTES DE TRABAJAR

El servidor sobre el que se está trabajando está declarado en
**`entorno/VPS-ACTIVO`** (un archivo de una línea con el nombre del VPS).

Todo comando, script o configuración que se prepare debe apuntar a ese
servidor, salvo que el usuario nombre otro explícitamente en su mensaje.
Si una petición no encaja con el VPS activo, avisarle antes de continuar.

El usuario lo cambia con `/vps NOMBRE`. Un hook `SessionStart` inyecta el
valor al contexto al inicio de cada sesión, así que el dato no se pierde
aunque la conversación se resuma.

## Servidores registrados

Ver `entorno/entornos.json` (IP, subred, gateway, recursos, rol de cada uno)
y `docs/ENTORNOS.md` para el detalle operativo.

| Cloud   | Nombre        | IP               |
|---------|---------------|------------------|
| Cloud-1 | `VPSVIMED`    | `216.185.51.168` |
| Cloud-2 | `ASENFCUARTA` | `216.185.51.156` |
| Cloud-3 | `ASENF20`     | `109.72.119.70`  |

## Límite importante

**Claude Code no tiene acceso de red a estos VPS.** El puerto 22 está
cerrado y el proxy bloquea 80/443 hacia esas IPs. No intentar conectarse ni
afirmar que se comprobó algo en un servidor.

El flujo real es: escribir el código aquí → commit y push → el usuario entra
por SSH desde su equipo y hace `git pull`. Las instrucciones se preparan para
que las ejecute él.

## Identificación de entorno

- `scripts/whereami.sh` — informe del servidor (nombre, IP, recursos).
- `scripts/marcar-entorno.sh NOMBRE` — marca un VPS de forma permanente.
- La app muestra una insignia con el nombre del entorno en su cabecera.
