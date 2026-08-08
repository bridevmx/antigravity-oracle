# Antigravity Claude Proxy — Despliegue en Coolify (Dockerfile / hybrid)

Despliegue listo de **`antigravity-claude-proxy`** en VPS (x86_64 / ARM64) con **Coolify**, estrategia **`hybrid`** y multi-cuenta.

> [!WARNING]
> **ToS de Google**: el uso de proxies no oficiales con cuentas personales puede violar términos del servicio. Usa solo cuentas secundarias (*burner*). Asumes el riesgo.

---

## Características

- **Foreground en Docker**: `start --log` como PID 1 (evita daemon / "already in orbit" / rollback de Coolify).
- **Puerto nativo 3000**: alineado con el listener del proxy.
- **HEALTHCHECK** tolerante a `API_KEY`: `/health` puede devolver **401**; se considera healthy si responde 200 o 401.
- **Compilación nativa** `better-sqlite3` (python3, make, g++, sqlite-dev) para ARM64/x86_64.
- **Estrategia hybrid** en el CMD.
- **Persistencia**: `/home/node/.antigravity-claude-proxy` (path real del runtime v2.8.x).

---

## Despliegue en Coolify

### 1. Recurso

1. **+ New Resource** → **Public Repository**
2. URL: `https://github.com/bridevmx/antigravity-oracle`
3. Branch: `main`
4. **Build Pack** → **Dockerfile** (no Nixpacks)

### 2. Environment Variables (Runtime)

En Coolify → **Environment Variables**. Marca secretos como secret.

> [!IMPORTANT]
> **`NODE_ENV=production` debe ser Runtime only.** Desmarca **"Available at Buildtime"** para silenciar el warning de Coolify (no rompe este build, pero es mala práctica en imágenes Node).

| Variable | Valor sugerido | Notas |
| :--- | :--- | :--- |
| `PORT` | `3000` | Debe coincidir con Ports Exposes |
| `HOST` | `0.0.0.0` | Obligatorio detrás de Traefik |
| `API_KEY` | *(secreto largo)* | Bearer para clientes; hace que `/health` devuelva 401 sin header |
| `WEBUI_PASSWORD` | *(secreto largo)* | Login del dashboard |
| `NODE_ENV` | `production` | **Solo runtime** |
| `FALLBACK` | `true` | Opcional |
| `DEV_MODE` | `false` | Opcional |

Plantilla: [`.env.example`](./.env.example).

### 3. Storages (persistencia OAuth) — CRÍTICO

El proxy guarda datos en este path (confirmado en logs de arranque):

| Campo | Valor |
| :--- | :--- |
| **Destination Path** | `/home/node/.antigravity-claude-proxy` |

> Si tenías montado `/home/node/.config/antigravity-proxy`, **cámbialo** al path de arriba o las cuentas no persistirán.

### 4. Puerto y dominio

1. **Ports Exposes / Port** = **`3000`**
2. FQDN (ej. `https://proxy.midominio.com`) → SSL Let's Encrypt
3. **Deploy** (force rebuild)

### 5. Healthcheck: por qué fallaba el 401

Con `API_KEY` definida, `GET /health` responde **401** sin Bearer.  
`curl -f` trata 401 como error → Coolify marca unhealthy aunque el server esté perfecto.

El Dockerfile actual acepta **200 o 401** como healthy.

Logs buenos esperados:

```text
Launching Antigravity Proxy (foreground mode)...
Server started successfully on port 3000
Strategy: Hybrid
```

Sin spam de `already in orbit`.

---

## Vinculación de cuentas Google

### WebUI

1. Abre `https://tu-dominio`
2. Entra con `WEBUI_PASSWORD`
3. **Accounts → Add Account** (modo manual/headless si aplica)
4. Settings → confirma strategy **hybrid**

### CLI headless

```bash
antigravity-claude-proxy accounts add --no-browser
```

### Comprobar health (con API key)

```bash
curl -sS -o /dev/null -w "%{http_code}\n" https://tu-dominio/health
# 401 = normal sin header

curl -sS -H "Authorization: Bearer TU_API_KEY" https://tu-dominio/health
# 200 esperado

curl -sS -H "Authorization: Bearer TU_API_KEY" \
  "https://tu-dominio/account-limits?format=table"
```

---

## Clientes

### Claude Code CLI

```bash
export ANTHROPIC_BASE_URL="https://tu-dominio"
export ANTHROPIC_API_KEY="TU_API_KEY"
```

### OpenCode / otros

Base URL `https://tu-dominio` + `Authorization: Bearer TU_API_KEY`.

---

## Prueba local

```bash
cp .env.example .env
# edita API_KEY y WEBUI_PASSWORD
docker compose up --build
curl -sS -o /dev/null -w "%{http_code}\n" http://127.0.0.1:3000/health
```

---

## Seguridad

- Nunca subas `.env` ni el volumen `data/` al git.
- Rota `API_KEY` si se filtra.
- Solo cuentas burner.
- Usa el reverse proxy de Coolify + `API_KEY`; no abras el puerto del host sin auth.

---

## Licencia

MIT. El binario `antigravity-claude-proxy` es de terceros; respeta su licencia y los ToS de Google.
