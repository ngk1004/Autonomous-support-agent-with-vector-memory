---
title: Payment Failures and Card Updates
category: billing
tags: [payments, credit-card, failed-payment, billing]
---

# Payment Failures and Card Updates

If your payment fails, AcmeCloud retries automatically and notifies you by email.

## Retry Schedule

| Attempt | Timing |
|---------|--------|
| 1 | Immediately |
| 2 | 3 days later |
| 3 | 5 days after attempt 2 |
| 4 | 7 days after attempt 3 |

After four failed attempts, your account moves to **Past Due** status. API access continues for 7 days, then read-only mode until payment succeeds.

## Update Your Payment Method

1. Go to **Settings → Billing → Payment Methods**.
2. Click **Add Payment Method** or **Update Card**.
3. Enter new card details. We use Stripe for PCI-compliant processing.
4. Click **Set as Default** if replacing an expired card.

Updating your card does not automatically retry a failed invoice—you may need to click **Pay Now** on the open invoice.

## Common Failure Reasons

- **Insufficient funds**: Contact your bank or use a different card.
- **Expired card**: Update before the next billing date.
- **3D Secure / SCA declined**: Complete the bank verification popup when prompted.
- **International block**: Some banks block recurring SaaS charges; whitelist `acmecloud.example`.

## Past Due Accounts

Accounts past due for more than 30 days may have data scheduled for deletion per our Terms of Service. Contact billing@acmecloud.example before day 30 to arrange a payment plan.
