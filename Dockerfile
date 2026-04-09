FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY metrics-logger.js ./

CMD ["node", "metrics-logger.js"]
