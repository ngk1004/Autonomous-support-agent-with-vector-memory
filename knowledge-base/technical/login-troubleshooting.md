---
title: Login Troubleshooting
category: technical
tags: [login, password, mfa, account-access, troubleshooting]
---

# Login Troubleshooting

If you cannot log in to AcmeCloud, follow these steps before contacting support.

## Forgot Password

1. Go to https://app.acmecloud.example/login
2. Click **Forgot Password**
3. Enter your account email
4. Check inbox and spam for reset link (expires in 1 hour)

Reset links are single-use. Request a new link if it expires.

## MFA / Two-Factor Authentication

### Lost Authenticator Device

1. Use a **backup code** at login (provided when MFA was enabled).
2. If no backup codes: contact your org admin to reset MFA.
3. Solo accounts: email security@acmecloud.example with government ID verification (24–48h).

### MFA Codes Not Working

- Ensure device clock is accurate (TOTP is time-sensitive).
- Try a backup code.
- Re-sync authenticator app if recently changed phones.

## SSO Users

If your organization uses SSO, use **Sign in with SSO** on the login page. Password reset does not apply to SSO accounts—contact your IT admin.

## Account Locked

After 10 failed login attempts, accounts lock for 30 minutes. Wait or contact support for immediate unlock.

## Browser Issues

- Clear cookies for `acmecloud.example`
- Disable ad blockers that may block auth cookies
- Try incognito/private mode
- Supported browsers: Chrome 90+, Firefox 90+, Safari 15+, Edge 90+

## Still Stuck?

Email support@acmecloud.example with:

- Account email
- Error message screenshot
- Whether you use SSO or password login
- Browser and OS version
