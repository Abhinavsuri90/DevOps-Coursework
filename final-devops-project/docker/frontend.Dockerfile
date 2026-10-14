# SpendWise web UI. Build context: final-devops-project/
#   docker build -f docker/frontend.Dockerfile -t spendwise-frontend .
# Stage 1: build the static site with Node
FROM node:24-alpine AS build
WORKDIR /app
COPY application/frontend/package.json application/frontend/package-lock.json ./
RUN npm ci --no-audit --no-fund
COPY application/frontend/index.html application/frontend/vite.config.js ./
COPY application/frontend/src ./src
RUN npm run build

# Stage 2: serve it with nginx running as a non-root user (uid 101, port 8080)
FROM nginxinc/nginx-unprivileged:1.30-alpine
ENV BACKEND_HOST=backend \
    BACKEND_PORT=8000
COPY docker/nginx.conf.template /etc/nginx/templates/default.conf.template
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 8080
