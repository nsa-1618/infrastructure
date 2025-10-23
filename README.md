# Infrastructure

Infrastructure as Code & Operations for WGL Lab

**Master Architect**: Nikolai Anton  
**Last Update**: 2025-10-22

## 🎯 Purpose

Central repository for:
- Server configurations & deployments
- Network management (VPN, DNS, Firewall)
- Docker templates & scripts
- Automation & maintenance scripts
- Architecture documentation

## 🏗️ Architecture
```
┌─────────────────────────────────────────────┐
│                                             │
│         WGL LAB INFRASTRUCTURE              │
│                                             │
├─────────────────────────────────────────────┤
│                                             │
│  PRODUCTION (Contabo Cloud)                 │
│  ├─ team-portal (8511)                      │
│  ├─ nginx (80, 443)                         │
│  └─ [planned services]                      │
│                                             │
│  INTERNAL (Terminal Server)                 │
│  ├─ SQL Server (1433) - WGL Data            │
│  ├─ RDP Access (3389)                       │
│  └─ VPN Required                            │
│                                             │
│  DEVELOPMENT (Local WSL)                    │
│  ├─ data-engineering (8501)                 │
│  ├─ PostgreSQL (5432)                       │
│  └─ MongoDB (27017)                         │
│                                             │
└─────────────────────────────────────────────┘
```

## 📂 Structure
```
infrastructure/
├── servers/              # Server-specific configs
│   ├── contabo/         # Contabo VPS
│   └── wgl-terminal/    # WGL Terminal Server
├── network/             # Network configs
│   ├── vpn/            # VPN (Sophos, Proton)
│   ├── dns/            # DNS (Cloudflare)
│   └── firewall/       # Firewall rules
├── docker/             # Docker assets
│   ├── compose-templates/
│   ├── dockerfiles/
│   └── scripts/
├── scripts/            # Automation
│   ├── deployment/
│   ├── backup/
│   ├── monitoring/
│   └── maintenance/
├── docs/              # Documentation
└── secrets/           # Examples only!
```

## 🌐 Servers

| Server | IP | Purpose | Access |
|--------|----|---------| -------|
| **Contabo VPS** | 207.180.207.183 | Production Cloud | SSH (nsa) |
| **WGL Terminal** | 192.168.100.203 | Internal DB/Services | RDP (via VPN) |

## 🔌 Port Schema

### Local Development
- **8501**: data-engineering (streamlit)
- **5432**: PostgreSQL
- **27017**: MongoDB
- **8081**: dbt docs

### Cloud Production (Contabo)
- **22**: SSH
- **80**: HTTP (Nginx)
- **443**: HTTPS (Nginx) [planned]
- **8511**: team-portal
- **9000**: Portainer [planned]
- **8080**: Filebrowser [planned]

### Port Blocks
- **8501-8509**: data-engineering services
- **8510-8519**: team-portal services
- **8520-8529**: tech-knowledge services
- **9000-9099**: management tools

## 🚀 Quick Start

### Connect to Contabo
```bash
ssh nsa@207.180.207.183
```

### Deploy team-portal
```bash
cd servers/contabo
./deploy-team-portal.sh
```

### Backup
```bash
cd scripts/backup
./backup-contabo.sh
```

## 📚 Documentation

- [Architecture Overview](docs/architecture.md)
- [Port Schema Details](docs/port-schema.md)
- [Deployment Workflow](docs/deployment-workflow.md)
- [Backup Strategy](docs/backup-strategy.md)
- [Troubleshooting](docs/troubleshooting.md)

## 🔒 Security

**IMPORTANT**: This repo contains NO actual secrets!
- Passwords → KeePass
- SSH Keys → `~/.ssh/` (referenced here)
- .env files → `.gitignore`d (examples only)

## 🛠️ Tools

- **VS Code**: Development & Remote-SSH
- **GitHub**: Version Control
- **Docker**: Containerization
- **Nginx**: Reverse Proxy
- **Certbot**: SSL/TLS

## 📝 Next Steps

- [ ] Setup CI/CD (GitHub Actions)
- [ ] Implement automated backups
- [ ] Setup monitoring (Uptime Kuma)
- [ ] Configure SSL (Let's Encrypt)
- [ ] Document disaster recovery

---

**Master Architect**: Building WGL Lab infrastructure with ❤️
