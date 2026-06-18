---
title: Downloading Invoices and Receipts
category: billing
tags: [invoices, receipts, billing, pdf]
---

# Downloading Invoices and Receipts

All AcmeCloud invoices and receipts are available in your account dashboard.

## From the Dashboard

1. Navigate to **Settings → Billing → Invoices**.
2. Use the date filter to find the billing period.
3. Click **Download PDF** next to any invoice.

Invoices include: company legal name, billing address, line items, tax (if applicable), and payment status.

## Email Copies

Invoice emails are sent to the **Billing Contact** on file at the time of charge. To change the billing email:

1. **Settings → Organization → Contacts**
2. Set **Billing Contact** to the desired email.

Historical invoices are not re-sent when you change the contact; download them from the dashboard.

## For Accounting / PO Numbers

Enterprise customers can add a PO number to future invoices:

- **Settings → Billing → Invoice Details → Purchase Order Number**

PO numbers cannot be retroactively added to closed invoices. Contact billing@acmecloud.example for corrected invoices.

## API Access to Invoices

Enterprise plans include `GET /v1/billing/invoices` API access. See the Technical documentation for authentication requirements.
