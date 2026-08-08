# Imagen base Node.js LTS en Alpine Linux
FROM node:20-alpine

# Compilación nativa (better-sqlite3) + curl para HEALTHCHECK de Docker/Coolify
RUN apk add --no-cache python3 make g++ sqlite-dev ca-certificates curl

# Instalar el paquete global antigravity-claude-proxy
RUN npm install -g antigravity-claude-proxy@latest

# Path real de storage del proxy (ver logs: Storage: /home/node/.antigravity-claude-proxy)
RUN mkdir -p /home/node/.antigravity-claude-proxy && \
    chown -R node:node /home/node/.antigravity-claude-proxy

# Usuario no privilegiado
USER node

WORKDIR /home/node

# Puerto alineado con el default del proxy (logs: localhost:3000)
ENV HOST=0.0.0.0 \
    PORT=3000 \
    NODE_ENV=production

EXPOSE 3000

# /health devuelve 401 si API_KEY está configurada. curl -f marca 401 como error.
# Cualquier respuesta del servidor (< connection error) con 200 o 401 = healthy.
HEALTHCHECK --interval=15s --timeout=5s --start-period=40s --retries=5 \
  CMD code=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3000/health) && \
      [ "$code" = "200" ] || [ "$code" = "401" ]

# --log = foreground (PID 1). hybrid = multi-cuenta inteligente.
CMD ["antigravity-claude-proxy", "start", "--log", "--strategy=hybrid"]
