FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . /app
EXPOSE 3000
ENV NODE_ENV=production
RUN npm run build
USER root
CMD ["node", "server.js"]