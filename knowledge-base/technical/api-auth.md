---
title: API Authentication and API Keys
category: technical
tags: [api, authentication, api-key, 401, bearer-token]
---

# API Authentication and API Keys

AcmeCloud API uses Bearer token authentication. All requests must include a valid API key in the `Authorization` header.

## Creating an API Key

1. Go to **Settings → Developers → API Keys**.
2. Click **Create Key**.
3. Choose scope: **Read**, **Write**, or **Admin**.
4. Copy the key immediately—it is shown only once.

Store keys in environment variables or a secrets manager. Never commit keys to version control.

## Using Your API Key

```http
GET https://api.acmecloud.example/v1/projects
Authorization: Bearer sk_live_xxxxxxxxxxxx
Content-Type: application/json
```

## Common 401 Unauthorized Errors

| Error Message | Cause | Fix |
|---------------|-------|-----|
| `invalid_api_key` | Key revoked or typo | Regenerate key in dashboard |
| `expired_api_key` | Key past expiration date | Create new key; old keys expire after set TTL |
| `missing_authorization` | No Bearer header | Add `Authorization: Bearer <key>` |
| `insufficient_scope` | Key lacks permission | Create key with Write or Admin scope |

## Key Rotation

We recommend rotating API keys every 90 days:

1. Create a new key with the same scopes.
2. Update your applications.
3. Revoke the old key from the dashboard.

## Rate Limits

- **Starter**: 100 requests/minute
- **Pro**: 1,000 requests/minute
- **Enterprise**: Custom limits

Exceeding limits returns `429 Too Many Requests` with a `Retry-After` header.

## IP Allowlisting (Enterprise)

Enterprise plans can restrict API keys to specific IP ranges under **Settings → Developers → IP Allowlist**.
