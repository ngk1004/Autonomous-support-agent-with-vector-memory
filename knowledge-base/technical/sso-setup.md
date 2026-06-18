---
title: Single Sign-On (SSO) Setup
category: technical
tags: [sso, saml, okta, azure-ad, authentication]
---

# Single Sign-On (SSO) Setup

AcmeCloud supports SAML 2.0 SSO for Pro and Enterprise plans.

## Supported Identity Providers

- Okta
- Microsoft Entra ID (Azure AD)
- Google Workspace
- OneLogin
- Generic SAML 2.0

## Configuration Steps

### In AcmeCloud

1. **Settings → Security → Single Sign-On**
2. Click **Enable SAML SSO**
3. Copy the **ACS URL** and **Entity ID** for your IdP

### In Your IdP

1. Create a new SAML application.
2. Set ACS URL: `https://app.acmecloud.example/auth/saml/callback`
3. Set Entity ID: `https://app.acmecloud.example`
4. Map attributes:
   - `email` → `user.email`
   - `firstName` → `user.firstName`
   - `lastName` → `user.lastName`
5. Upload the IdP metadata XML to AcmeCloud.

### Test SSO

Use **Test Connection** in AcmeCloud before enforcing SSO org-wide.

## Enforce SSO

Once tested, enable **Require SSO for all users**. Local password login is disabled for non-break-glass accounts.

## Break-Glass Admin

Designate at least one break-glass admin with password login for IdP outages. Configure under **Settings → Security → Break-Glass Accounts**.

## Troubleshooting

- **"SAML assertion invalid"**: Clock skew—ensure IdP and SP clocks are synchronized (NTP).
- **"User not provisioned"**: Enable JIT provisioning or pre-create users in AcmeCloud.
- **Redirect loop**: Verify ACS URL matches exactly (no trailing slash mismatch).
