# Antigravity Claude Proxy — Despliegue en Coolify (Dockerfile / hybrid)

Despliegue listo de **`antigravity-claude-proxy`** en VPS (x86_64 / ARM64) con **Coolify**, estrategia **`hybrid`** y multi-cuenta.

> [!WARNING]
> **ToS de Google**: el uso de proxies no oficiales con cuentas personales puede violar términos del servicio. Usa solo cuentas secundarias (*burner*). Asumes el riesgo.

---

## Características

- **Foreground en Docker**: `start --log` como PID 1 (evita daemon / "already in orbit" / rollback de Coolify).
- **Puerto nativo 3000**: alineado con el listener del proxy.
- **HEALTHCHECK** con `curl` a `/health` (`start-period` 40s).
- **Compilación nativa** `better-sqlite3` (python3, make, g++, sqlite-dev) para ARM64/x86_64.
- **Estrategia hybrid** en el CMD y en `config/config.example.json`.
- **Persistencia**: `/home/node/.config/antigravity-proxy`.

---

## Despliegue en Coolify

### 1. Recurso

1. **+ New Resource** → **Public Repository**
2. URL: `https://github.com/bridevmx/antigravity-oracle`
3. Branch: `main`
4. **Build Pack** → **Dockerfile** (no Nixpacks)

### 2. Environment Variables (Runtime)

En Coolify → **Environment Variables**. Marca secretos como secret.  
**`NODE_ENV` solo Runtime** (desmarca "Available at Buildtime").

| Variable | Valor sugerido | Notas |
| :--- | :--- | :--- |
| `PORT` | `3000` | Debe coincidir con Ports Exposes |
| `HOST` | `0.0.0.0` | Obligatorio detrás de Traefik |
| `API_KEY` | *(secreto largo)* | Bearer para clientes |
| `WEBUI_PASSWORD` | *(secreto largo)* | Login del dashboard |
| `NODE_ENV` | `production` | Solo runtime |
| `FALLBACK` | `true` | Opcional |
| `DEV_MODE` | `false` | Opcional |

Plantilla comentada: [`.env.example`](./.env.example).

### 3. Storages (persistencia OAuth)

| Campo | Valor |
| :--- | :--- |
| Destination Path | `/home/node/.config/antigravity-proxy` |

Sin esto, cada redeploy borra las cuentas enlazadas.

### 4. Puerto y dominio

1. **Ports Exposes / Port** = **`3000`**
2. FQDN (ej. `https://proxy.midominio.com`) → SSL Let's Encrypt
3. **Deploy**

### 5. Si el healthcheck falla

1. Confirma en logs **una sola** línea de arranque y que **no** aparezca spam de `already in orbit`.
2. Debe verse el proceso en foreground (`--log`).
3. Si hace falta depurar: desactiva healthcheck temporalmente en Coolify → verifica WebUI → reactívalo.
4. Path de health: `/health` en puerto `3000`.

---

## Vinculación de cuentas Google

### WebUI

1. Abre `https://tu-dominio`
2. Entra con `WEBUI_PASSWORD`
3. **Accounts → Add Account** (modo manual/headless si no hay browser en el server)
4. Settings → confirma strategy **hybrid**

### CLI headless (terminal del contenedor en Coolify)

```bash
antigravity-claude-proxy accounts add --no-browser
```

Autoriza la URL en tu PC y pega el código de vuelta.

Ver cuota:

```bash
curl -fsS https://tu-dominio/health
# account-limits (si el endpoint está expuesto en tu versión)
```

---

## Clientes

### Claude Code CLI

```bash
export ANTHROPIC_BASE_URL="https://tu-dominio"
export ANTHROPIC_API_KEY="TU_API_KEY"
```

### OpenCode / OpenAI-compatible

Apunta el provider a `https://tu-dominio` (o la base que documente tu versión del proxy) con header:

`Authorization: Bearer TU_API_KEY`

---

## Prueba local (opcional)

```bash
cp .env.example .env
# edita API_KEY y WEBUI_PASSWORD
docker compose up --build
curl -fsS http://127.0.0.1:3000/health
```

---

## Seguridad

- Nunca subas `.env` ni el volumen `data/` al git.
- Rota `API_KEY` si se filtra.
- Solo cuentas burner.
- No expongas el puerto del host sin auth; usa el reverse proxy de Coolify + `API_KEY`.

---

## Licencia

MIT. El binario `antigravity-claude-proxy` es proyecto de terceros; respeta su licencia y los ToS de Google.
