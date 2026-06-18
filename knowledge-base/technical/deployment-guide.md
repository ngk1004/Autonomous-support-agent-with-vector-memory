---
title: Deployment Guide
category: technical
tags: [deployment, cicd, production, rollback]
---

# Deployment Guide

Deploy applications to AcmeCloud using the CLI, API, or Git integration.

## CLI Deployment

```bash
# Install CLI
npm install -g @acmecloud/cli

# Login
acmecloud login

# Deploy
acmecloud deploy --project=proj_xyz --env=production
```

## Git Integration

1. Connect repository: **Project → Settings → Git**
2. Select branch (e.g., `main`)
3. Configure build command: `npm run build`
4. Set output directory: `dist`
5. Enable **Auto-deploy on push**

## Deployment States

| State | Description |
|-------|-------------|
| `queued` | Waiting for build slot |
| `building` | Running build command |
| `deploying` | Uploading artifacts |
| `live` | Serving traffic |
| `failed` | Build or deploy error |

## Rollback

Rollback to any previous deployment:

1. **Project → Deployments**
2. Select a previous successful deployment
3. Click **Promote to Production**

Rollback completes in under 60 seconds. No rebuild required.

## Environment Variables per Environment

Set variables per environment under **Project → Settings → Environment Variables**:

- `production`: Live secrets
- `staging`: Test values
- `preview`: PR preview deployments

Preview deployments inherit from `staging` unless overridden.

## Health Checks

Configure health check path (default `/health`). Failed health checks trigger automatic rollback within 5 minutes.

## Zero-Downtime Deployments

AcmeCloud uses rolling deployments. Traffic shifts gradually to new instances. Old instances drain for 30 seconds before termination.
