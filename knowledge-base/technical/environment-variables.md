---
title: Environment Variables and Configuration
category: technical
tags: [configuration, env-vars, deployment, secrets]
---

# Environment Variables and Configuration

Configure AcmeCloud CLI and SDK using environment variables.

## Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `ACMECLOUD_API_KEY` | Your API key | `sk_live_abc123` |
| `ACMECLOUD_PROJECT_ID` | Default project | `proj_xyz789` |

## Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `ACMECLOUD_API_URL` | API base URL | `https://api.acmecloud.example` |
| `ACMECLOUD_TIMEOUT` | Request timeout (seconds) | `30` |
| `ACMECLOUD_RETRY_MAX` | Max retry attempts | `3` |
| `ACMECLOUD_LOG_LEVEL` | Logging verbosity | `info` |

## Setting Variables

### Local Development (.env file)

```bash
ACMECLOUD_API_KEY=sk_test_your_key_here
ACMECLOUD_PROJECT_ID=proj_dev_001
ACMECLOUD_LOG_LEVEL=debug
```

Never commit `.env` files to git. Add `.env` to `.gitignore`.

### CI/CD (GitHub Actions)

```yaml
env:
  ACMECLOUD_API_KEY: ${{ secrets.ACMECLOUD_API_KEY }}
  ACMECLOUD_PROJECT_ID: proj_ci_001
```

### Docker

```dockerfile
ENV ACMECLOUD_API_KEY=""
# Pass at runtime: docker run -e ACMECLOUD_API_KEY=sk_...
```

## Validating Configuration

```bash
acmecloud config validate
```

Returns configuration status without making API calls. Use `acmecloud config test` to verify API connectivity.

## Common Errors

- **"API key not set"**: Export `ACMECLOUD_API_KEY` before running CLI
- **"Invalid project ID"**: Check project exists in dashboard
- **"Connection refused"**: Verify `ACMECLOUD_API_URL` if using self-hosted Enterprise
