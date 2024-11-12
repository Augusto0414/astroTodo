# Etapa 1: Construcción del proyecto
FROM node:18-alpine AS builder

WORKDIR /app

# Copia los archivos de configuración de dependencias
COPY package.json package-lock.json ./
RUN npm install
RUN npm install -g astro

# Copia los archivos del proyecto
COPY . .

# Construye el proyecto
RUN npm run build

# Etapa 2: Servidor de producción
FROM node:18-alpine

WORKDIR /app

# Copia los archivos construidos desde la etapa anterior
COPY --from=builder /app/dist /app

# Agrega un archivo de configuración en tiempo de ejecución
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expone el puerto de la app
EXPOSE 3000

# Ejecuta el script de configuración en tiempo de ejecución
ENTRYPOINT ["/entrypoint.sh"]
CMD ["npx", "serve", "-s", ".", "-l", "3000"]
