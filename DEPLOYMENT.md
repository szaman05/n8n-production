# n8n Deployment Guide for Dokploy

This guide covers deploying n8n to production using Dokploy with PostgreSQL database.

## Prerequisites

- Dokploy account and server access
- PostgreSQL database (managed or self-hosted)
- Domain name (optional, for SSL)

## Environment Variables

Create these environment variables in your Dokploy application:

### Core Configuration
```
NODE_ENV=production
N8N_HOST=0.0.0.0
N8N_PORT=5678
N8N_PROTOCOL=http
WEBHOOK_URL=https://your-domain.com/
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=your-admin-username
N8N_BASIC_AUTH_PASSWORD=your-secure-password
```

### Database Configuration (PostgreSQL)
```
DB_TYPE=postgresdb
DB_HOST=n8n-db-euovlt  # Actual Dokploy hostname
DB_PORT=5432
DB_NAME=n8n-db
DB_USER=n8n-user
DB_PASSWORD=2XwLPkJIIq632NCp83QL
DB_SSL_MODE=prefer
```

**Connection URL**: `postgresql://n8n-user:2XwLPkJIIq632NCp83QL@n8n-db-euovlt:5432/n8n-db`

**Note**: Use the exact connection details from your Dokploy PostgreSQL service. The hostname `n8n-db-euovlt` is the actual internal service name.

### Optional: Redis for Queue
```
QUEUE_BULL_REDIS_HOST=your-redis-host
QUEUE_BULL_REDIS_PORT=6379
QUEUE_BULL_REDIS_PASSWORD=your-redis-password
```

### Security & Performance
```
N8N_METRICS=true
N8N_LOG_LEVEL=info
N8N_LOG_OUTPUT=file
N8N_FILE_LOG_PATH=/home/node/.n8n/logs
N8N_LOG_FILE_MAX_SIZE=10m
N8N_LOG_FILE_MAX_FILES=10
```

## Database Setup

### Option 1: Dokploy PostgreSQL (Recommended)
Create PostgreSQL database directly in Dokploy:

1. **Create Database Service**:
   - Name: `n8n-db`
   - Database Name: `n8n-db`
   - User: `n8n-user`
   - Docker Image: `postgres:18`

2. **Get Connection Details**:
   After creation, Dokploy will provide the connection URL and credentials.

### Option 2: Managed PostgreSQL
Use external services like:
- Railway
- Supabase
- PlanetScale
- AWS RDS
- DigitalOcean Managed Database

### Database Initialization
n8n will automatically create the necessary tables on first startup.

## Deployment Steps

### 1. Build Configuration
In Dokploy, set:
- **Build Context**: `/`
- **Dockerfile Path**: `Dockerfile`
- **Docker Ignored File**: `.dockerignore.prod`

### 2. Resource Allocation
Recommended minimum:
- **CPU**: 1 core
- **Memory**: 2GB RAM
- **Storage**: 10GB+

### 3. Health Check
Dockerfile includes health check:
- **Path**: `/healthz`
- **Interval**: 30s
- **Timeout**: 10s
- **Retries**: 3

### 4. Persistent Storage
Mount volume for data persistence:
- **Path**: `/home/node/.n8n`
- **Type**: Persistent Volume

### 5. Port Configuration
- **Internal Port**: 5678
- **External Port**: 80 (HTTP) / 443 (HTTPS with SSL)

### 6. Service Dependencies
Add `n8n-db` as a dependency in Dokploy to ensure the database starts before n8n.

## SSL Configuration

### Automatic SSL (Dokploy Managed)
1. Add your custom domain in Dokploy
2. Enable SSL certificate
3. Update `WEBHOOK_URL` to use `https://`

### Manual SSL
Set environment variables:
```
N8N_PROTOCOL=https
WEBHOOK_URL=https://your-domain.com/
```

## Monitoring & Logs

### Application Logs
Monitor logs in Dokploy dashboard or set up log aggregation.

### Health Monitoring
The health check endpoint `/healthz` returns:
- `200 OK` when healthy
- `503 Service Unavailable` when unhealthy

### Metrics
Enable metrics with `N8N_METRICS=true` and monitor:
- Memory usage
- CPU usage
- Active workflows
- Execution queue

## Security Best Practices

1. **Authentication**: Always enable basic auth or OAuth
2. **Environment Variables**: Use strong, unique passwords
3. **Network**: Restrict database access to application only
4. **SSL**: Always use HTTPS in production
5. **Updates**: Regularly update n8n and dependencies
6. **Backups**: Regular database backups

## Scaling

### Horizontal Scaling
- Use external PostgreSQL and Redis
- Deploy multiple instances behind a load balancer
- Set `EXECUTIONS_MODE=queue`

### Vertical Scaling
- Increase CPU and memory allocation
- Monitor resource usage
- Optimize workflow performance

## Troubleshooting

### Common Issues

1. **Database Connection**
   - Verify database credentials
   - Check network connectivity
   - Ensure database is running

2. **Memory Issues**
   - Increase memory allocation
   - Optimize workflow memory usage
   - Enable execution queue

3. **Performance Issues**
   - Use Redis for queue management
   - Optimize database queries
   - Enable caching

### Log Locations
- Application logs: `/home/node/.n8n/logs`
- Error logs: Same location, check `error.log`

## Backup Strategy

### Database Backups
```bash
# PostgreSQL backup
pg_dump -h your-db-host -U n8n -d n8n > backup.sql

# Restore
psql -h your-db-host -U n8n -d n8n < backup.sql
```

### Configuration Backups
Backup environment variables and n8n settings:
- Export workflows: `n8n export:workflow --all`
- Export credentials: `n8n export:credentials --all`

## Updates

### Updating n8n
1. Update the repository
2. Build new image
3. Deploy in Dokploy
4. Monitor for issues

### Zero-Downtime Updates
- Use rolling deployments
- Health checks prevent bad deployments
- Database migrations handled automatically
