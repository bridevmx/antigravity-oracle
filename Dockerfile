# Imagen base Node.js LTS en Alpine Linux
FROM node:20-alpine

# Instalar dependencias necesarias del sistema (como wget, ca-certificates)
RUN apk add --no-cache ca-certificates wget

# Instalar el paquete global antigravity-claude-proxy
RUN npm install -g antigravity-claude-proxy@latest

# Crear directorio de trabajo y configuración persistente con permisos para el usuario node
RUN mkdir -p /home/node/.config/antigravity-proxy && \
    chown -R node:node /home/node/.config

# Cambiar al usuario no privilegiado
USER node

# Directorio de trabajo predeterminado
WORKDIR /home/node

# Variables de entorno por defecto
ENV HOST=0.0.0.0 \
    PORT=8080 \
    NODE_ENV=production

# Exponer el puerto del servidor proxy
EXPOSE 8080

# Chequeo de salud del contenedor
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# Comando por defecto para iniciar el proxy con la estrategia hybrid
CMD ["antigravity-claude-proxy", "start", "--strategy=hybrid"]
