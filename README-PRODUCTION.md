# n8n Production Deployment

This repository contains a production-ready n8n deployment configuration optimized for Dokploy.

## 🚀 Quick Start

### 1. Clone this repository
```bash
git clone https://github.com/szaman05/n8n-production.git
cd n8n-production
```

### 2. Set up database
Create a PostgreSQL database and note the connection details.

### 3. Configure environment variables
See `DEPLOYMENT.md` for detailed configuration options.

### 4. Deploy to Dokploy
- Build Context: `/`
- Dockerfile: `Dockerfile`
- Port: `5678`
- Volume: `/home/node/.n8n`

## 📁 What's Included

- ✅ **Production Dockerfile** - Optimized multi-stage build
- ✅ **Docker Compose** - Local development setup
- ✅ **Database Configuration** - PostgreSQL setup guide
- ✅ **Deployment Guide** - Complete Dokploy instructions
- ✅ **Security Best Practices** - Production-ready configuration

## 🗄️ Database Setup

### PostgreSQL (Dokploy)
Create PostgreSQL database in Dokploy:
- **Service Name**: `n8n-db`
- **Database Name**: `n8n-db`
- **User**: `n8n-user`
- **Password**: Generate secure password

### Environment Variables
```bash
DB_TYPE=postgresdb
DB_HOST=n8n-db-euovlt  # Actual Dokploy hostname
DB_PORT=5432
DB_NAME=n8n-db
DB_USER=n8n-user
DB_PASSWORD=2XwLPkJIIq632NCp83QL
```

**Connection URL**: `postgresql://n8n-user:2XwLPkJIIq632NCp83QL@n8n-db-euovlt:5432/n8n-db`

## 🐳 Docker Commands

### Local Development
```bash
docker-compose up -d
```

### Build Production Image
```bash
docker build -t n8n-production .
```

### Run Production Container
```bash
docker run -d \
  --name n8n \
  -p 5678:5678 \
  -v n8n_data:/home/node/.n8n \
  -e DB_TYPE=postgresdb \
  -e DB_HOST=postgres \
  -e DB_PORT=5432 \
  -e DB_NAME=n8n \
  -e DB_USER=n8n \
  -e DB_PASSWORD=your_password \
  n8n-production
```

## 📚 Documentation

- **DEPLOYMENT.md** - Complete deployment guide
- **docker-compose.yml** - Local development setup
- **Dockerfile** - Production configuration

## 🔧 Configuration

Key environment variables for production:

```bash
# Core
NODE_ENV=production
N8N_HOST=0.0.0.0
N8N_PORT=5678

# Security
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=secure_password

# Database
DB_TYPE=postgresdb
DB_HOST=your-db-host
DB_NAME=n8n
DB_USER=n8n
DB_PASSWORD=your-db-password
```

## 🌐 Access

Once deployed, access n8n at:
- Local: `http://localhost:5678`
- Production: `https://your-domain.com`

## 📊 Monitoring

- Health check: `/healthz`
- Logs: `/home/node/.n8n/logs`
- Metrics: Enable with `N8N_METRICS=true`

## 🤝 Support

For issues and questions:
1. Check the [Deployment Guide](DEPLOYMENT.md)
2. Review [n8n Documentation](https://docs.n8n.io)
3. Open an issue in this repository

---

**Repository**: https://github.com/szaman05/n8n-production  
**Based on**: n8n v2.13.0 - https://n8n.io
