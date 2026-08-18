#!/usr/bin/env bash
# marcar-entorno.sh — Marca este servidor con el nombre de su VPS.
# Se ejecuta UNA VEZ en cada VPS, con sudo.
#
# Uso:  sudo bash scripts/marcar-entorno.sh ASENF20
#       sudo bash scripts/marcar-entorno.sh ASENF20 /var/www/omni
#
# Hace dos cosas:
#   1. Escribe /etc/omni-entorno  -> lo lee whereami.sh y cualquier script
#   2. Escribe entorno.json junto al index.html desplegado
#      -> lo lee la propia app en el navegador y muestra el nombre en la cabecera

set -euo pipefail

CONOCIDOS="VPSVIMED ASENFCUARTA ASENF20"
MARCA="/etc/omni-entorno"

NOMBRE="${1:-}"
DESTINO_WEB="${2:-}"

if [ -z "$NOMBRE" ]; then
  echo "Falta el nombre del entorno."
  echo "Uso: sudo bash $0 <NOMBRE> [ruta_del_despliegue_web]"
  echo "Nombres registrados: $CONOCIDOS"
  exit 1
fi

NOMBRE="$(printf '%s' "$NOMBRE" | tr '[:lower:]' '[:upper:]')"

reconocido=0
for c in $CONOCIDOS; do
  [ "$NOMBRE" = "$c" ] && reconocido=1
done
if [ "$reconocido" -eq 0 ]; then
  echo "AVISO: '$NOMBRE' no esta en el registro ($CONOCIDOS)."
  echo "       Se marcara igualmente. Agregalo a entorno/entornos.json si es un VPS nuevo."
fi

# 1) Marca del sistema
printf '%s\n' "$NOMBRE" > "$MARCA"
chmod 644 "$MARCA"
echo "Escrito $MARCA -> $NOMBRE"

# 2) entorno.json para la app web
if [ -z "$DESTINO_WEB" ]; then
  for d in /var/www/omni /var/www/html /srv/omni /opt/omni; do
    if [ -f "$d/index.html" ]; then DESTINO_WEB="$d"; break; fi
  done
fi

if [ -n "$DESTINO_WEB" ] && [ -d "$DESTINO_WEB" ]; then
  cat > "$DESTINO_WEB/entorno.json" <<JSON
{
  "entorno": "$NOMBRE",
  "hostname": "$(hostname)",
  "ip": "$(hostname -I 2>/dev/null | awk '{print $1}')",
  "marcado": "$(date '+%Y-%m-%d %H:%M:%S %Z')"
}
JSON
  chmod 644 "$DESTINO_WEB/entorno.json"
  echo "Escrito $DESTINO_WEB/entorno.json"
else
  echo "No se encontro despliegue web. Pasa la ruta como segundo argumento si quieres el entorno.json:"
  echo "  sudo bash $0 $NOMBRE /ruta/al/directorio/web"
fi

echo
echo "Comprobacion:"
bash "$(dirname "$0")/whereami.sh" --corto
