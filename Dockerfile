# Imagen base Node.js LTS en Alpine Linux
FROM node:20-alpine

# Compilación nativa (better-sqlite3) + curl para HEALTHCHECK de Docker/Coolify
RUN apk add --no-cache python3 make g++ sqlite-dev ca-certificates curl

# Instalar el paquete global antigravity-claude-proxy
RUN npm install -g antigravity-claude-proxy@latest

# Directorio de configuración persistente (tokens OAuth / config)
RUN mkdir -p /home/node/.config/antigravity-proxy && \
    chown -R node:node /home/node/.config

# Usuario no privilegiado
USER node

WORKDIR /home/node

# Puerto alineado con el default del proxy (logs: localhost:3000)
ENV HOST=0.0.0.0 \
    PORT=3000 \
    NODE_ENV=production

EXPOSE 3000

# start-period generoso: el proxy tarda en levantar el listener
HEALTHCHECK --interval=15s --timeout=5s --start-period=40s --retries=5 \
  CMD curl -fsS "http://127.0.0.1:3000/health" || exit 1

# CRÍTICO: --log mantiene el proceso en foreground (PID 1).
# Sin --log, "start" daemoniza → "already in orbit" + healthcheck unhealthy en Coolify.
CMD ["antigravity-claude-proxy", "start", "--log", "--strategy=hybrid"]
