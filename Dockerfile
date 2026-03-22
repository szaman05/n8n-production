# Production Dockerfile for n8n deployment on Dokploy
# Based on n8n's official Dockerfile with production optimizations

ARG NODE_VERSION=24.13.1
ARG N8N_VERSION=2.13.0

# Build stage - use n8n's existing build approach
FROM node:${NODE_VERSION}-alpine AS builder

# Install build dependencies
RUN apk add --no-cache python3 make g++ git

WORKDIR /usr/local/lib/node_modules/n8n

# Copy the entire n8n source for building
COPY . .

# Build n8n using their official build script
RUN npm install -g pnpm@10.22.0 && \
    pnpm install --frozen-lockfile --ignore-scripts && \
    node scripts/build-n8n.mjs

# Production stage
FROM node:${NODE_VERSION}-alpine AS production

# Install runtime dependencies
RUN apk add --no-cache dumb-init curl

# Create n8n user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S n8n -u 1001

WORKDIR /home/node

# Copy built application from builder
COPY --from=builder /usr/local/lib/node_modules/n8n /usr/local/lib/node_modules/n8n
COPY --from=builder /usr/local/lib/node_modules/n8n/packages/cli/bin/n8n /usr/local/bin/n8n
COPY --from=builder /usr/local/lib/node_modules/n8n/THIRD_PARTY_LICENSES.md /usr/local/lib/node_modules/n8n/

# Rebuild native dependencies for production
RUN cd /usr/local/lib/node_modules/n8n && \
    npm rebuild sqlite3 isolated-vm && \
    npm install --production

# Create necessary directories and set permissions
RUN mkdir -p /home/node/.n8n && \
    chown -R node:node /home/node && \
    rm -rf /root/.npm /tmp/*

# Environment variables
ENV NODE_ENV=production
ENV N8N_RELEASE_TYPE=prod
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV N8N_PROTOCOL=http
ENV WEBHOOK_URL=http://localhost:5678/
ENV N8N_USER_FOLDER=/home/node/.n8n
ENV SHELL=/bin/sh

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5678/healthz || exit 1

# Expose port
EXPOSE 5678

# Switch to non-root user
USER node

# Entrypoint
ENTRYPOINT ["dumb-init", "--"]
CMD ["n8n"]
