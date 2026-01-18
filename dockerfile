FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . /app
EXPOSE 3000
ENV NODE_ENV=production
USER root
CMD ["node", "server.js"]