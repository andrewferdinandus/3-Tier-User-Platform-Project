FROM node:20-alpine AS client-builder

WORKDIR /usr/src/app/client
COPY client/package*.json ./
RUN npm install
COPY client/ ./
RUN npm run build

FROM node:20-alpine AS server-builder

WORKDIR /usr/src/app/server
COPY server/package*.json ./
RUN npm install --omit=dev
COPY server/ ./

FROM node:20-alpine

WORKDIR /usr/src/app/server
ENV NODE_ENV=production
COPY --from=server-builder /usr/src/app/server ./
RUN mkdir -p ./public

COPY --from=client-builder /usr/src/app/client/public ./public/
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
RUN chown -R appuser:appgroup /usr/src/app/server

USER appuser

EXPOSE 5000
CMD ["node", "index.js"]
