FROM node:20-alpine AS builder
WORKDIR /usr/src/app
COPY app/package*.json ./
RUN npm install --only=production
COPY app/ ./

FROM node:20-alpine
# Security Hardening: Patch OS packages and remove global npm/yarn to eliminate CVEs
RUN apk update && apk upgrade --no-cache && rm -rf /usr/local/lib/node_modules/npm /opt/yarn*
ENV NODE_ENV=production
WORKDIR /app
USER node
COPY --chown=node:node --from=builder /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=builder /usr/src/app/server.js ./server.js
EXPOSE 3000
CMD ["node", "server.js"]
