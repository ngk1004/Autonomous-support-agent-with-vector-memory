---
title: API Rate Limits and Quotas
category: technical
tags: [api, rate-limits, quotas, throttling, 429]
---

# API Rate Limits and Quotas

AcmeCloud enforces rate limits and monthly quotas to ensure platform stability.

## Per-Minute Rate Limits

| Plan | Requests/min | Burst |
|------|--------------|-------|
| Starter | 100 | 150 |
| Pro | 1,000 | 1,500 |
| Enterprise | Custom | Custom |

When exceeded, API returns:

```json
{
  "error": "rate_limit_exceeded",
  "retry_after": 42
}
```

HTTP status: `429 Too Many Requests`

## Monthly API Quota

Each plan includes a monthly API call quota:

- **Starter**: 50,000 calls/month
- **Pro**: 500,000 calls/month
- **Enterprise**: Unlimited (fair use)

Quota resets on your billing anniversary date.

## Checking Usage

- Dashboard: **Settings → Usage → API**
- API: `GET /v1/usage/current`

Response includes `calls_used`, `calls_limit`, and `reset_at`.

## Handling Rate Limits in Code

```python
import time
import requests

response = requests.get(url, headers=headers)
if response.status_code == 429:
    retry_after = int(response.headers.get("Retry-After", 60))
    time.sleep(retry_after)
    # retry request
```

Implement exponential backoff for production applications.

## Increasing Limits

- Upgrade plan for higher limits.
- Enterprise: contact sales@acmecloud.example for custom rate limits and dedicated capacity.
