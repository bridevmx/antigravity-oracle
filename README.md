# Antigravity Claude Proxy — Despliegue en Coolify (Hybrid Strategy)

Este repositorio contiene la configuración lista para desplegar **`antigravity-claude-proxy`** en tu VPS utilizando **Coolify**. Permite compartir y rotar inteligentemente la cuota de múltiples cuentas entre clientes como OpenCode y Claude Code CLI mediante la estrategia `hybrid`.

> [!WARNING]
> **Aviso de Términos de Servicio (ToS)**:
> El uso de proxies de retransmisión API con cuentas personales de Google/Antigravity puede infringir las políticas de uso del servicio. Se recomienda utilizar exclusivamente cuentas de prueba o secundarias (*burner accounts*).

---

## 🚀 Características Principales

- **Estrategia `hybrid`**: Combina balanceo de carga round-robin con prioridad inteligente basada en cuota disponible por cuenta.
- **Persistencia garantizada**: Mapeo del directorio de configuración `/home/node/.config/antigravity-proxy` para no perder sesiones OAuth al reiniciar el contenedor.
- **Seguridad**: Ejecución sobre usuario sin privilegios `node` en Alpine Linux.
- **WebUI & CLI Headless**: Panel web y comandos para vincular cuentas de Google sin interfaz gráfica.

---

## 🛠️ Guía de Despliegue en Coolify

### Paso 1: Crear la Aplicación en Coolify
1. En tu panel de **Coolify**, dirígete a tu proyecto y selecciona **+ New Resource**.
2. Elige **Public Repository** e introduce la URL de este repositorio:
   `https://github.com/bridevmx/antigravity-oracle`
3. Selecciona la rama `main` y el tipo de compilación **Dockerfile**.

### Paso 2: Configuración de Variables de Entorno (Environment Variables)
En la pestaña **Environment Variables** de Coolify, agrega las siguientes variables:

| Variable | Valor Sugerido | Descripción |
| :--- | :--- | :--- |
| `PORT` | `8080` | Puerto en el que escucha el contenedor. |
| `HOST` | `0.0.0.0` | Escucha en todas las interfaces de red. |
| `API_KEY` | `GeneraUnaClaveMuySeguraAqui` | Clave secreta para que los clientes se conecten. |
| `WEBUI_PASSWORD` | `GeneraUnaContraseñaSeguraAqui` | Contraseña para entrar a la WebUI de gestión. |
| `NODE_ENV` | `production` | Modo de producción. |

### Paso 3: Configurar Volumen Persistente (Storages)
Para evitar tener que re-autenticar tus cuentas de Google cada vez que se actualice o reinicie el contenedor:

1. Ve a la pestaña **Storages** en Coolify.
2. Agrega una nueva ruta de volumen:
   - **Source Path**: `antigravity-data` (o una ruta absoluta en el host como `/var/lib/coolify/volumes/antigravity-data`)
   - **Destination Path**: `/home/node/.config/antigravity-proxy`

### Paso 4: Puerto y Dominio (Traefik / Proxy)
1. En la pestaña **General**, configura el puerto expuesto de la aplicación a `8080`.
2. Asigna tu FQDN/Dominio (ej. `https://proxy.midominio.com`) para habilitar SSL automático vía Let's Encrypt.
3. Haz clic en **Deploy**.

---

## 🔐 Vinculación de Cuentas Google OAuth

Una vez desplegada la aplicación, debes vincular tus cuentas de Google:

### Opción A: A través de la WebUI (Recomendado)
1. Abre tu navegador e ingresa a `https://proxy.midominio.com`.
2. Inicia sesión con la contraseña definida en `WEBUI_PASSWORD`.
3. Sigue el asistente para añadir nuevas cuentas OAuth.

### Opción B: Modo Headless / Manual desde Terminal (CLI)
Si prefieres vincular cuentas por línea de comandos dentro del contenedor:

```bash
# Accede a la terminal del contenedor desde Coolify o SSH
docker exec -it antigravity-claude-proxy sh

# Ejecuta el comando de autorización manual (sin abrir navegador automáticamente)
antigravity-claude-proxy accounts add --no-browser
```
Copia la URL generada, autoriza en tu navegador, y pega el código de verificación resultante en la consola.

---

## 🔌 Configuración de Clientes

### Conectar con Claude Code CLI
```bash
export ANTHROPIC_BASE_URL="https://proxy.midominio.com"
export ANTHROPIC_API_KEY="TU_API_KEY_CONFIGURADA"
```

### Conectar con OpenCode / otros clientes OpenAI/Claude compatibles
Configurar el Endpoint como `https://proxy.midominio.com` y la clave Bearer Header con tu `API_KEY`.

---

## 🛡️ Seguridad y Buenas Prácticas

- **No expongas credenciales**: Nunca subas el archivo `.env` o el directorio `data/` a ningún repositorio git público.
- **Rotación de API_KEY**: Si sospechas que tu `API_KEY` fue expuesta, cámbiala inmediatamente en Coolify y redepliega.
- **Chequeo de Salud**: El contenedor incluye un endpoint de comprobación en `/health` que Coolify utiliza automáticamente.

---

## 📄 Licencia y Contribución

Proyecto mantenido bajo licencia MIT. Las contribuciones y sugerencias son bienvenidas vía Pull Request.
