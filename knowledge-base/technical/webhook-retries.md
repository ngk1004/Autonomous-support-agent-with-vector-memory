---
title: Webhook Retries and Delivery
category: technical
tags: [webhooks, retries, events, delivery, integrations]
---

# Webhook Retries and Delivery

AcmeCloud sends event notifications to your configured webhook endpoints.

## Event Types

- `project.created`, `project.updated`, `project.deleted`
- `deployment.succeeded`, `deployment.failed`
- `invoice.paid`, `invoice.failed`
- `user.invited`, `user.removed`

## Webhook Payload

```json
{
  "id": "evt_abc123",
  "type": "deployment.succeeded",
  "created_at": "2025-06-01T12:00:00Z",
  "data": { "project_id": "proj_xyz", "deployment_id": "dep_456" }
}
```

## Signature Verification

Verify webhooks using the `X-AcmeCloud-Signature` header:

```
HMAC-SHA256(webhook_secret, raw_request_body)
```

Reject requests with invalid signatures to prevent spoofing.

## Retry Policy

If your endpoint returns a non-2xx status or times out (30s), we retry:

| Attempt | Delay |
|---------|-------|
| 1 | Immediate |
| 2 | 5 minutes |
| 3 | 30 minutes |
| 4 | 2 hours |
| 5 | 8 hours |
| 6 | 24 hours |

After 6 failures, the webhook is **disabled** and you receive an email alert.

## Best Practices

- Return `200 OK` quickly; process asynchronously.
- Use idempotency: deduplicate by `event.id`.
- Log all received events for debugging.
- Use HTTPS endpoints only (TLS 1.2+).

## Re-enable Disabled Webhooks

1. Fix your endpoint.
2. **Settings → Developers → Webhooks**
3. Click **Re-enable** on the disabled endpoint.
4. Use **Send Test Event** to verify.

## Manual Replay

Enterprise customers can replay events from the last 30 days via the dashboard or `POST /v1/webhooks/{id}/replay`.
