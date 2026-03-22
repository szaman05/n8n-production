# Environment Variables Reference

Copy and paste these exact environment variables into your Dokploy n8n application:

## Database Configuration
```
DB_TYPE=postgresdb
DB_HOST=n8n-db-euovlt
DB_PORT=5432
DB_NAME=n8n-db
DB_USER=n8n-user
DB_PASSWORD=2XwLPkJIIq632NCp83QL
DB_SSL_MODE=prefer
```

## Core Application
```
NODE_ENV=production
N8N_HOST=0.0.0.0
N8N_PORT=5678
N8N_PROTOCOL=http
WEBHOOK_URL=https://your-domain.com/
```

## Security (Configure these)
```
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=your-admin-username
N8N_BASIC_AUTH_PASSWORD=your-secure-password
```

## Optional: Logging & Monitoring
```
N8N_METRICS=true
N8N_LOG_LEVEL=info
N8N_LOG_OUTPUT=file
N8N_FILE_LOG_PATH=/home/node/.n8n/logs
N8N_LOG_FILE_MAX_SIZE=10m
N8N_LOG_FILE_MAX_FILES=10
```

## Connection String
Full connection URL for reference:
```
postgresql://n8n-user:2XwLPkJIIq632NCp83QL@n8n-db-euovlt:5432/n8n-db
```

## Notes
- Replace `your-domain.com` with your actual domain
- Set secure authentication credentials
- Database will auto-create tables on first startup
