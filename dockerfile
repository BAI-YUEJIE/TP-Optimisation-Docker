FROM node:latest
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . /app
RUN apt-get update && apt-get install -y build-essential ca-certificates locales
EXPOSE 3000 4000 5000
ENV NODE_ENV=development
RUN npm run build
USER root
CMD ["node", "server.js"]