# Imagen base Node.js LTS en Alpine Linux
FROM node:20-alpine

# Instalar herramientas de compilación C++/Python para better-sqlite3 y utilidades
RUN apk add --no-cache python3 make g++ sqlite-dev ca-certificates wget curl

# Instalar el paquete global antigravity-claude-proxy
RUN npm install -g antigravity-claude-proxy@latest

# Crear directorio de trabajo y configuración persistente con permisos para el usuario node
RUN mkdir -p /home/node/.config/antigravity-proxy && \
    chown -R node:node /home/node/.config

# Cambiar al usuario no privilegiado
USER node

# Directorio de trabajo predeterminado
WORKDIR /home/node

# Variables de entorno por defecto (Puerto predeterminado: 3000)
ENV HOST=0.0.0.0 \
    PORT=3000 \
    NODE_ENV=production

# Exponer el puerto predeterminado del servidor proxy
EXPOSE 3000

# Chequeo de salud mediante fetch nativo de Node.js (robusto y sin dependencias externas)
HEALTHCHECK --interval=10s --timeout=5s --start-period=15s --retries=5 \
  CMD node -e "fetch('http://127.0.0.1:3000/health').then(r => r.status < 500 ? process.exit(0) : process.exit(1)).catch(() => process.exit(1))"

# Comando por defecto para iniciar el proxy con la estrategia hybrid
CMD ["antigravity-claude-proxy", "start", "--strategy=hybrid"]
