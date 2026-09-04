# Stage 1: Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package.json ./
RUN npm install

# Stage 2: Final minimal production runtime stage
FROM node:18-alpine AS runner
WORKDIR /app
COPY package.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY server.js ./
EXPOSE 3000
CMD ["node", "server.js"]
