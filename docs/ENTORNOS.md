# Entornos / VPS del proyecto

Este documento y las piezas que describe existen para responder a una sola
pregunta, en cualquier momento: **¿en qué servidor estoy trabajando?**

## Los servidores registrados

| Cloud   | Nombre        | Rol         | Dominio / IP  |
|---------|---------------|-------------|---------------|
| Cloud-1 | `VPSVIMED`    | por definir | *(rellenar)*  |
| Cloud-2 | `ASENFCUARTA` | por definir | *(rellenar)*  |
| Cloud-3 | `ASENF20`     | por definir | *(rellenar)*  |

El registro editable está en `entorno/entornos.json`. Al añadir un VPS nuevo,
agrégalo ahí **y** en el array `ENTORNOS` del final de `index.html`.

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

Sin marca, `whereami.sh` sólo puede adivinar por el hostname. Para fijarlo:

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
4. El hostname de la URL, contra la lista `hosts` de cada entorno en el array
   `ENTORNOS` de `index.html`.
5. `localhost` o `file://` → `LOCAL` / `ARCHIVO LOCAL`.
6. Si nada coincide → `SIN IDENTIFICAR`.

El botón **Auto** del panel borra la selección manual y vuelve a la detección
automática.

### Detección por dominio (opcional)

Si cada VPS sirve la app bajo un dominio o IP fija, añádelos y la app se
identifica sola sin necesidad de `entorno.json`:

```js
var ENTORNOS = [
  { id:'VPSVIMED',    cloud:'Cloud-1', color:'#06b6d4', hosts:['vimed.midominio.cl','203.0.113.10'] },
  { id:'ASENFCUARTA', cloud:'Cloud-2', color:'#a78bfa', hosts:['cuarta.midominio.cl'] },
  { id:'ASENF20',     cloud:'Cloud-3', color:'#22c55e', hosts:['asenf20.midominio.cl'] }
];
```

---

## Nota sobre las sesiones de Claude Code

Las sesiones de Claude Code **no corren en ninguno de estos tres VPS**. Corren
en un contenedor efímero de Anthropic (entorno `Default`, `cloud_default`), con
el repositorio clonado de cero al arrancar. Por eso `whereami.sh` ahí dice
`DESCONOCIDO`: es correcto, no es ninguno de tus servidores. Lo que se escribe
en el contenedor se pierde salvo que se haya hecho commit y push.
