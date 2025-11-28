# Database package - только для сборки других сервисов
# Этот пакет не деплоится отдельно, а используется как зависимость

FROM node:22-alpine AS builder
WORKDIR /app

COPY package*.json ./
COPY prisma ./prisma/

RUN npm install
RUN npx prisma generate

# Экспортируем сгенерированный клиент
FROM scratch AS export
COPY --from=builder /app/node_modules/.prisma /prisma-client

