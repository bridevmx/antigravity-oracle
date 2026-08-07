# Antigravity Claude Proxy — Despliegue en Coolify (Dockerfile / ARM64)

Este repositorio contiene la configuración lista para desplegar **`antigravity-claude-proxy`** en tu VPS (x86_64 / ARM64 Oracle Cloud) utilizando **Coolify** y la estrategia `hybrid`.

> [!WARNING]
> **Aviso de Términos de Servicio (ToS)**:
> El uso de proxies de retransmisión API con cuentas personales de Google/Antigravity puede infringir las políticas de uso del servicio. Se recomienda utilizar exclusivamente cuentas de prueba o secundarias (*burner accounts*).

---

## 🚀 Características Principales

- **Puerto Nativo (3000)**: Alineado con el puerto de escucha interno por defecto del proxy (`http://localhost:3000`).
- **Healthcheck Nativo en Node.js**: Utiliza `fetch` incorporado en Node.js 20 para verificar la disponibilidad sin depender de comandos de sistema externos.
- **Compilación Nativa ARM64 & x86_64**: Incluye herramientas de compilación (`python3`, `make`, `g++`, `sqlite-dev`) para compilar de forma nativa `better-sqlite3` en arquitectura ARM64 / Ampere.
- **Estrategia `hybrid`**: Combina balanceo de carga round-robin con prioridad inteligente basada en cuota disponible por cuenta.
- **Persistencia garantizada**: Mapeo del directorio de configuración `/home/node/.config/antigravity-proxy` para no perder sesiones OAuth al reiniciar el contenedor.

---

## 🛠️ Guía de Despliegue en Coolify

### Paso 1: Configurar el Recurso en Coolify
1. En tu panel de **Coolify**, dirígete a tu proyecto y selecciona **+ New Resource**.
2. Elige **Public Repository** e introduce la URL: `https://github.com/bridevmx/antigravity-oracle`
3. En la pestaña **General** -> **Build Pack**, selecciona **Dockerfile**.

---

### Paso 2: Configuración de Variables de Entorno (Environment Variables)
En la pestaña **Environment Variables** de Coolify, agrega:

| Variable | Valor Sugerido | Descripción |
| :--- | :--- | :--- |
| `PORT` | `3000` | Puerto en el que escucha internamente el contenedor. |
| `HOST` | `0.0.0.0` | Escucha en todas las interfaces de red. |
| `API_KEY` | `GeneraUnaClaveMuySeguraAqui` | Clave secreta requerida para conectar los clientes. |
| `WEBUI_PASSWORD` | `GeneraUnaContraseñaSeguraAqui` | Contraseña para acceder a la WebUI. |
| `NODE_ENV` | `production` | Modo de producción. |

---

### Paso 3: Configurar Volumen Persistente (Storages)
Para no perder las sesiones de autenticación OAuth:

1. Ve a la pestaña **Storages** en Coolify.
2. Agrega la ruta de volumen:
   - **Destination Path**: `/home/node/.config/antigravity-proxy`

---

### Paso 4: Puerto de la Aplicación en Coolify
1. En la pestaña **General** de Coolify, asegúrate de definir el puerto de la aplicación (**Ports Exposed** / **Port**) en **`3000`**.
2. Asigna tu FQDN/Dominio (ej. `https://proxy.midominio.com`).
3. Haz clic en **Deploy**.

---

## 🔐 Vinculación de Cuentas Google OAuth

### Desde la WebUI:
1. Navega a `https://proxy.midominio.com`.
2. Inicia sesión con tu `WEBUI_PASSWORD`.
3. Sigue el asistente para vincular cuentas Google.

### Desde Terminal (CLI Headless):
```bash
docker exec -it antigravity-claude-proxy sh
antigravity-claude-proxy accounts add --no-browser
```

---

## 🔌 Configuración de Clientes

### Claude Code CLI
```bash
export ANTHROPIC_BASE_URL="https://proxy.midominio.com"
export ANTHROPIC_API_KEY="TU_API_KEY"
```

---

## 📄 Licencia

MIT
