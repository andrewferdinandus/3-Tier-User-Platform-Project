# ==========================================
# STAGE 1: Build the Client (Frontend)
# ==========================================
FROM node:20-alpine AS client-builder

WORKDIR /usr/src/app/client
COPY client/package*.json ./
RUN npm install
COPY client/ ./
RUN npm run build

# ==========================================
# STAGE 2: Build the Server (Backend)
# ==========================================
FROM node:20-alpine AS server-builder

WORKDIR /usr/src/app/server
COPY server/package*.json ./
RUN npm install --omit=dev
COPY server/ ./

# ==========================================
# STAGE 3: Final Production Image
# ==========================================
FROM node:20-alpine

# Root Directory to /usr/src/app 
WORKDIR /usr/src/app
ENV NODE_ENV=production

# Server code copyto /usr/src/app/server 
COPY --from=server-builder /usr/src/app/server ./server

# Public directory copy to Frontend build 
RUN mkdir -p ./server/public
COPY --from=client-builder /usr/src/app/client/public ./server/public/

# Security Best Practices: Non-root user 
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
RUN chown -R appuser:appgroup /usr/src/app

USER appuser


EXPOSE 5000

CMD ["node", "server/index.js"]
