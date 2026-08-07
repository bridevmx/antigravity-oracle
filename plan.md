# Plan de despliegue y estructura de repositorio: antigravity-claude-proxy + hybrid en Coolify

Este plan establece la creación de la estructura completa del repositorio listo para ser subido a GitHub (público) y desplegado en un VPS mediante **Coolify**, permitiendo el uso de cuota multi-cuenta con la estrategia `hybrid` de `antigravity-claude-proxy`.

> [!WARNING]
> **Riesgo de ToS de Google**: Utilizar herramientas proxy de retransmisión de API con cuentas personales de Google/Antigravity conlleva riesgo de suspensión o restricción. Se recomienda encarecidamente utilizar únicamente cuentas de prueba o secundarias ("burner accounts").

---

## User Review Required

> [!IMPORTANT]
> **Estrategia y Modos de Inicio**:
> - Se configurará el `Dockerfile` para ejecutar el servidor proxy en foreground escuchando en `0.0.0.0:8080`.
> - Se incluirá la bandera `--strategy=hybrid` en el comando por defecto (y documentada en `config.example.json` y WebUI).
> - Se definirá la persistencia de datos en el directorio home del contenedor (`/home/node/.config/antigravity-proxy`) para garantizar que la autenticación OAuth no se pierda al reiniciar o redesplegar en Coolify.

---

## Proposed Changes

Se estructurará el repositorio público con los siguientes componentes y plantillas (totalmente libres de secretos):

### Repositorio del Proyecto

#### [NEW] [Dockerfile](./antigravity-oracle/Dockerfile)
- Basado en `node:20-alpine` (LTS ligero).
- Instala globalmente `antigravity-claude-proxy`.
- Configura usuario no-root (`node`) y variables de entorno por defecto (`HOST=0.0.0.0`, `PORT=8080`, `NODE_ENV=production`).
- Expone el puerto `8080`.
- Incluye `HEALTHCHECK` HTTP contra el endpoint `/health`.
- CMD ejecuta `antigravity-claude-proxy start --strategy=hybrid`.

#### [NEW] [.env.example](./antigravity-oracle/.env.example)
- Plantilla con comentarios exhaustivos describiendo cada variable.
- Variables principales: `PORT`, `HOST`, `API_KEY`, `WEBUI_PASSWORD`, `NODE_ENV`, `FALLBACK`, `DEV_MODE`, `MAX_ACCOUNTS`, `GLOBAL_QUOTA_THRESHOLD`.
- Instrucciones de uso para Coolify UI (Secrets).

#### [NEW] [.gitignore](./antigravity-oracle/.gitignore)
- Ignora `.env`, `.env.local`, `config.json`, `data/`, `logs/`, `node_modules/`, tokens de Google OAuth y credenciales.

#### [NEW] [docker-compose.yml](./antigravity-oracle/docker-compose.yml)
- Configuración para pruebas y desarrollo local.
- Mapeo de puertos `8080:8080`.
- Definición del volumen persistente local `./data:/home/node/.config/antigravity-proxy`.
- Carga de variables desde `.env`.

#### [NEW] [config/config.example.json](./antigravity-oracle/config/config.example.json)
- Plantilla de configuración de referencia con `"accountSelection": { "strategy": "hybrid" }`.

#### [NEW] [README.md](./antigravity-oracle/README.md)
- Guía completa paso a paso en español:
  1. Propósito de la aplicación y arquitectura.
  2. Guía detallada de despliegue en Coolify (Creación de recurso, variables de entorno, volumen persistente `/home/node/.config/antigravity-proxy`, SSL/Traefik).
  3. Flujo de vinculación de cuentas Google OAuth (modo Headless / Manual Authorization desde la WebUI o CLI con `accounts add --no-browser`).
  4. Configuración y conexión con clientes (OpenCode y Claude Code CLI).
  5. Advertencias de seguridad, rotación de `API_KEY` y gestión de riesgos ToS.
  6. Runbook de mantenimiento y recuperación ante desastres.

---

## Verification Plan

### Manual Verification
1. **Verificación de archivos y plantillas**: Confirmar que no exista ningún secreto ni token expuesto en los archivos generados.
2. **Validación de Dockerfile**: Probar la construcción del contenedor Docker para asegurar que se instale la versión LTS y que el proceso responda correctamente en el puerto 8080.
3. **Verificación de documentación**: Revisar que el README incluya todas las rutas de volúmenes persistentes (`/home/node/.config/antigravity-proxy`), pasos para Coolify y comandos de CLI `accounts add --no-browser`.

---



quiero que esta carpeta actual de antigravity-oracle se suba a github debes crear el repo commit y push, NUNCA debes arcodear keys, passwords o algo similar que sea bulnerable.

