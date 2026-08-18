#!/usr/bin/env bash
# whereami.sh — ¿En que VPS estoy?
# Uso:  bash whereami.sh            (informe completo)
#       bash whereami.sh --corto    (solo el nombre del entorno)
#
# Orden de identificacion:
#   1. /etc/omni-entorno            <- marca fija escrita por marcar-entorno.sh
#   2. variable de entorno OMNI_ENTORNO
#   3. coincidencia del hostname con los nombres conocidos
#   4. DESCONOCIDO

set -uo pipefail

MARCA="/etc/omni-entorno"
CONOCIDOS="VPSVIMED ASENFCUARTA ASENF20"

# IP real de cada VPS registrado (ver entorno/entornos.json)
IP_VPSVIMED="216.185.51.168"
IP_ASENFCUARTA="216.185.51.156"
IP_ASENF20="109.72.119.70"

ips_de() {
  case "$1" in
    VPSVIMED)    echo "$IP_VPSVIMED" ;;
    ASENFCUARTA) echo "$IP_ASENFCUARTA" ;;
    ASENF20)     echo "$IP_ASENF20" ;;
  esac
}

detectar_entorno() {
  if [ -r "$MARCA" ]; then
    ENTORNO="$(head -n1 "$MARCA" | tr -d '[:space:]')"
    ORIGEN="$MARCA"
    return
  fi
  if [ -n "${OMNI_ENTORNO:-}" ]; then
    ENTORNO="$OMNI_ENTORNO"
    ORIGEN="variable OMNI_ENTORNO"
    return
  fi
  local h
  h="$(hostname | tr '[:lower:]' '[:upper:]')"
  for c in $CONOCIDOS; do
    case "$h" in
      *"$c"*) ENTORNO="$c"; ORIGEN="hostname ($(hostname))"; return ;;
    esac
  done
  # 4. coincidencia por IP (local o publica)
  local mias ip_pub
  mias="$(hostname -I 2>/dev/null || true)"
  ip_pub="$(curl -s --max-time 4 https://ifconfig.me 2>/dev/null || true)"
  for c in $CONOCIDOS; do
    local esperada
    esperada="$(ips_de "$c")"
    [ -n "$esperada" ] || continue
    case " $mias " in
      *" $esperada "*) ENTORNO="$c"; ORIGEN="IP local $esperada"; return ;;
    esac
    if [ -n "$ip_pub" ] && [ "$ip_pub" = "$esperada" ]; then
      ENTORNO="$c"; ORIGEN="IP publica $esperada"; return
    fi
  done

  ENTORNO="DESCONOCIDO"
  ORIGEN="sin marca, ni hostname, ni IP conocida"
}

detectar_entorno

if [ "${1:-}" = "--corto" ]; then
  echo "$ENTORNO"
  exit 0
fi

linea() { printf '%s\n' "------------------------------------------------------------"; }
campo() { printf '  %-18s %s\n' "$1" "$2"; }

linea
printf '  ENTORNO: %s\n' "$ENTORNO"
printf '  (detectado por: %s)\n' "$ORIGEN"
linea

echo "IDENTIDAD DEL SERVIDOR"
campo "hostname"   "$(hostname)"
campo "fqdn"       "$(hostname -f 2>/dev/null || echo n/d)"
campo "sistema"    "$(. /etc/os-release 2>/dev/null && echo "${PRETTY_NAME:-n/d}")"
campo "kernel"     "$(uname -r)"
campo "arquitect." "$(uname -m)"
campo "uptime"     "$(uptime -p 2>/dev/null || uptime)"
campo "usuario"    "$(whoami)"
echo

echo "RED"
campo "IPs locales" "$(hostname -I 2>/dev/null | tr -s ' ' || echo n/d)"
IP_PUB="$(curl -s --max-time 4 https://ifconfig.me 2>/dev/null || true)"
campo "IP publica"  "${IP_PUB:-no disponible}"
IP_ESPERADA="$(ips_de "$ENTORNO")"
if [ -n "$IP_ESPERADA" ]; then
  if [ "${IP_PUB:-}" = "$IP_ESPERADA" ] || printf ' %s ' "$(hostname -I 2>/dev/null)" | grep -q " $IP_ESPERADA "; then
    campo "IP registrada" "$IP_ESPERADA  (coincide)"
  else
    campo "IP registrada" "$IP_ESPERADA  (NO coincide - revisar)"
  fi
fi
echo

echo "RECURSOS"
campo "CPU"    "$(nproc 2>/dev/null || echo n/d) nucleos"
campo "RAM"    "$(free -h 2>/dev/null | awk '/^Mem:/{print $3" usados de "$2}' || echo n/d)"
campo "Disco"  "$(df -h / 2>/dev/null | awk 'NR==2{print $3" usados de "$2" ("$5")"}' || echo n/d)"
echo

echo "SERVICIOS WEB"
for svc in nginx apache2 caddy docker; do
  if command -v "$svc" >/dev/null 2>&1; then
    estado="instalado"
    if command -v systemctl >/dev/null 2>&1; then
      systemctl is-active --quiet "$svc" 2>/dev/null && estado="ACTIVO"
    fi
    campo "$svc" "$estado"
  fi
done
if command -v docker >/dev/null 2>&1; then
  echo
  echo "CONTENEDORES"
  docker ps --format '  {{.Names}}  {{.Image}}  {{.Status}}' 2>/dev/null || echo "  (sin permiso para consultar docker)"
fi
echo

echo "DESPLIEGUES DE omni-manual ENCONTRADOS"
encontrado=0
for d in /var/www /srv /opt /home /root; do
  [ -d "$d" ] || continue
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    printf '  %s  (%s)\n' "$f" "$(date -r "$f" '+%Y-%m-%d %H:%M' 2>/dev/null)"
    encontrado=1
  done < <(find "$d" -maxdepth 4 -name 'index.html' -path '*omni*' 2>/dev/null)
done
[ "$encontrado" -eq 0 ] && echo "  ninguno bajo /var/www /srv /opt /home /root"
linea

if [ "$ENTORNO" = "DESCONOCIDO" ]; then
  echo "Este servidor no esta marcado. Para fijarlo de forma permanente:"
  echo "  sudo bash scripts/marcar-entorno.sh ASENF20"
  linea
fi
