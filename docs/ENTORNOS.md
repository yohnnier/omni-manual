# Entornos / VPS del proyecto

Este documento y las piezas que describe existen para responder a una sola
pregunta, en cualquier momento: **¿en qué servidor estoy trabajando?**

## Los servidores registrados

| Cloud   | Nombre        | IP               | Subred            | Gateway         | CPU | RAM    | Disco  |
|---------|---------------|------------------|-------------------|-----------------|-----|--------|--------|
| Cloud-1 | `VPSVIMED`    | `216.185.51.168` | `255.255.255.0`   | `216.185.51.1`  | 2   | 4 GiB  | 40 GB  |
| Cloud-2 | `ASENFCUARTA` | `216.185.51.156` | `255.255.255.0`   | `216.185.51.1`  | 2   | 8 GiB  | 50 GB  |
| Cloud-3 | `ASENF20`     | `109.72.119.70`  | `255.255.255.128` | `109.72.119.1`  | 4   | 12 GiB | 100 GB |

`VPSVIMED` y `ASENFCUARTA` comparten la subred `216.185.51.0/24`. `ASENF20`
está en otra red (`109.72.119.0/25`) y es el más grande de los tres.

El registro editable está en `entorno/entornos.json`. Al añadir un VPS nuevo,
agrégalo ahí, en el array `ENTORNOS` del final de `index.html` y en las
variables `IP_*` de `scripts/whereami.sh`.

---

## 1. Desde el servidor (SSH)

```bash
cd /ruta/al/omni-manual
bash scripts/whereami.sh          # informe completo
bash scripts/whereami.sh --corto  # solo el nombre, p. ej. ASENF20
```

El informe muestra entorno, hostname, IP local y pública, sistema, recursos,
servicios web activos, contenedores docker y dónde está desplegado el
`index.html` de omni-manual.

### Marcar cada VPS (hacer una vez por servidor)

Con las IPs ya registradas, `whereami.sh` reconoce los tres servidores solo
(por hostname o por IP) sin necesidad de marcarlos. Marcarlos sirve igualmente
para dos cosas: dejarlo fijo aunque cambie la IP, y generar el `entorno.json`
que la app lee en el navegador.

```bash
sudo bash scripts/marcar-entorno.sh ASENF20
# o indicando la carpeta web del despliegue:
sudo bash scripts/marcar-entorno.sh ASENF20 /var/www/omni
```

Esto escribe dos cosas:

- `/etc/omni-entorno` — la marca del sistema que lee `whereami.sh`.
- `entorno.json` junto al `index.html` desplegado — lo lee la app en el
  navegador.

Repite el comando en cada VPS con su nombre correspondiente.

---

## 2. Desde la app en el navegador

La cabecera del asistente OMNI lleva ahora una **insignia con el nombre del
entorno**. Al pulsarla se abre un panel con el detalle: entorno, cómo se
detectó, hostname e IP del servidor, cuándo se marcó, host de la URL,
protocolo, ruta y hora local.

Si la insignia aparece en **ámbar diciendo `SIN IDENTIFICAR`**, ese servidor no
está marcado todavía.

### Cómo decide la app en qué entorno está

Por orden de prioridad:

1. `?vps=NOMBRE` en la URL — por ejemplo `…/index.html?vps=ASENF20`. Queda
   guardado en el navegador.
2. Selección manual guardada (los botones del panel).
3. **`entorno.json` servido junto al `index.html`** — la fuente fiable, la
   escribe `marcar-entorno.sh` en el propio VPS.
4. El hostname o IP de la URL, contra la lista `hosts` de cada entorno. Ya
   están cargadas las tres IPs, así que abrir `http://109.72.119.70/…` muestra
   `ASENF20` sin configurar nada más.
5. `localhost` o `file://` → `LOCAL` / `ARCHIVO LOCAL`.
6. Si nada coincide → `SIN IDENTIFICAR`.

El botón **Auto** del panel borra la selección manual y vuelve a la detección
automática.

### Añadir dominios

Si más adelante pones un dominio delante de cada VPS, agrégalo a su lista
`hosts` en `index.html` junto a la IP:

```js
var ENTORNOS = [
  { id:'VPSVIMED',    cloud:'Cloud-1', color:'#06b6d4', ip:'216.185.51.168', hosts:['216.185.51.168','vimed.midominio.cl'] },
  { id:'ASENFCUARTA', cloud:'Cloud-2', color:'#a78bfa', ip:'216.185.51.156', hosts:['216.185.51.156'] },
  { id:'ASENF20',     cloud:'Cloud-3', color:'#22c55e', ip:'109.72.119.70',  hosts:['109.72.119.70']  }
];
```

---

## Nota sobre las sesiones de Claude Code

Las sesiones de Claude Code **no corren en ninguno de estos tres VPS**. Corren
en un contenedor efímero de Anthropic (entorno `Default`, `cloud_default`), con
el repositorio clonado de cero al arrancar. Por eso `whereami.sh` ahí dice
`DESCONOCIDO`: es correcto, no es ninguno de tus servidores. Lo que se escribe
en el contenedor se pierde salvo que se haya hecho commit y push.
