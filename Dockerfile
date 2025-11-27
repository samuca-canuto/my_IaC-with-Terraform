# Exemplo Básico de Dockerfile (Se sua app for Node.js)
# Estágio de Build
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build # Se houver um build step

# Estágio de Produção (Imagem final mais leve)
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app .
EXPOSE 80 
CMD ["node", "server.js"] # Comando para iniciar sua aplicação
