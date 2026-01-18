# Stage 1: Build dependencies
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Stage 2: Production image
FROM node:20-alpine
WORKDIR /app

# Creer un utilisateur non-root
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001

COPY --from=builder /app/node_modules ./node_modules
COPY package*.json ./
COPY server.js ./

# Changer le proprietaire des fichiers
RUN chown -R nodejs:nodejs /app

EXPOSE 3000
ENV NODE_ENV=production
USER nodejs
CMD ["node", "server.js"]