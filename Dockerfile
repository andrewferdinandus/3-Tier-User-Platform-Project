FROM node:20-alpine


WORKDIR /usr/src/app/client
COPY client/package*.json ./
RUN npm install
COPY client/ ./
RUN npm run build


WORKDIR /usr/src/app/server
COPY server/package*.json ./
RUN npm install --omit=dev
COPY server/ ./


RUN mkdir -p /usr/src/app/server/public && cp -R /usr/src/app/client/public/* /usr/src/app/server/public/


ENV NODE_ENV=production


RUN addgroup -S appgroup && adduser -S appuser -G appgroup
RUN chown -R appuser:appgroup /usr/src/app

USER appuser


EXPOSE 5000


CMD ["node", "server.js"]
