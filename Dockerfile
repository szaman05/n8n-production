# Production Dockerfile for n8n deployment on Dokploy
# Multi-stage build for optimized production image

ARG NODE_VERSION=24.13.1
ARG N8N_VERSION=2.13.0

# Build stage
FROM node:${NODE_VERSION}-alpine AS builder

# Install build dependencies
RUN apk add --no-cache python3 make g++ libc6-compat

WORKDIR /app

# Copy package files
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY patches/ ./
COPY scripts/ ./

# Install pnpm and dependencies
RUN npm install -g pnpm@10.22.0
RUN pnpm install --frozen-lockfile

# Copy source code
COPY packages/ ./packages/

# Build the application
RUN pnpm build:deploy

# Production stage
FROM node:${NODE_VERSION}-alpine AS production

# Install runtime dependencies
RUN apk add --no-cache dumb-init curl

# Create n8n user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S n8n -u 1001

WORKDIR /app

# Copy built application
COPY --from=builder --chown=n8n:nodejs /app/compiled /app/compiled
COPY --from=builder --chown=n8n:nodejs /app/packages/cli/bin/n8n /app/n8n
COPY --from=builder --chown=n8n:nodejs /app/THIRD_PARTY_LICENSES.md /app/

# Install and rebuild native dependencies
RUN cd /app/compiled && \
    npm rebuild sqlite3 isolated-vm && \
    npm install --production

# Create necessary directories
RUN mkdir -p /home/node/.n8n && \
    chown -R n8n:nodejs /home/node/.n8n /app

# Environment variables
ENV NODE_ENV=production
ENV N8N_RELEASE_TYPE=prod
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV N8N_PROTOCOL=http
ENV WEBHOOK_URL=http://localhost:5678/
ENV N8N_BASIC_AUTH_ACTIVE=false
ENV N8N_USER_FOLDER=/home/node/.n8n
ENV SHELL=/bin/sh

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5678/healthz || exit 1

# Expose port
EXPOSE 5678

# Switch to non-root user
USER n8n

# Entrypoint
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "/app/n8n"]
