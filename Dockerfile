# Etapa 1: Construcción del proyecto
FROM node:18 AS builder

# Configura el directorio de trabajo
WORKDIR /app

# Copia los archivos de configuración de dependencias
COPY package.json package-lock.json ./

# Verifica que los archivos package.json se copiaron
RUN ls -l /app

# Instala las dependencias
RUN npm install

# Instala astro globalmente
RUN npm install -g astro

# Copia los archivos del proyecto
COPY . .

# Ejecuta la construcción del proyecto
RUN npm run build

# Etapa 2: Servidor de producción
FROM node:18-alpine

WORKDIR /app

# Copia los archivos construidos desde la etapa anterior
COPY --from=builder /app/dist /app

# Define las variables de entorno necesarias
ENV PUBLIC_API_BASE_URL=${PUBLIC_API_BASE_URL}

# Expone el puerto de la app
EXPOSE 3000

# Sirve la app construida en producción
CMD ["npx", "serve", "-s", ".", "-l", "3000"]
