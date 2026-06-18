---
title: Slack Integration Status
category: product
tags: [slack, integration, notifications, roadmap]
---

# Slack Integration Status

Slack integration is one of the most requested AcmeCloud features.

## Current Status

**Under Consideration** for Q3 release. Not yet available in production.

## Planned Capabilities

When shipped, Slack integration will include:

- Deployment notifications to channels
- `/acmecloud` slash command for status checks
- Alert routing for failed deployments and billing events
- Optional: approve production deploys from Slack (Enterprise)

## Workaround Today

Until native Slack support ships:

1. **Webhooks**: Send AcmeCloud webhook events to a Slack incoming webhook URL
2. **Zapier/n8n**: Use our webhook events to trigger Slack messages
3. **API polling**: Poll deployment status and post via Slack API

Example webhook → Slack flow is documented in our Integration Guides.

## Get Notified

Vote and subscribe to updates:

- Feedback portal: https://feedback.acmecloud.example/slack
- Enable **Product Updates** in notification preferences

## Beta Access

When beta opens, opt in via **Settings → Labs → Slack Integration (Beta)**. Beta slots are limited and assigned by signup order.
