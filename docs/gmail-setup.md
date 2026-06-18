# Gmail OAuth Setup for n8n

The Support Agent workflow sends customer responses via the **Gmail** node. Gmail requires interactive OAuth setup in the n8n UI.

## Prerequisites

- Google account with Gmail
- Access to [Google Cloud Console](https://console.cloud.google.com/)

## Step 1: Create a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click **Select a project** → **New Project**
3. Name it (e.g., `n8n-support-agent-demo`)
4. Click **Create**

## Step 2: Enable Gmail API

1. In your project, go to **APIs & Services** → **Library**
2. Search for **Gmail API**
3. Click **Enable**

## Step 3: Configure OAuth Consent Screen

1. Go to **APIs & Services** → **OAuth consent screen**
2. Choose **External** (unless you have Google Workspace)
3. Fill in required fields:
   - App name: `n8n Support Agent`
   - User support email: your email
   - Developer contact: your email
4. Click **Save and Continue**
5. **Scopes**: Add `https://www.googleapis.com/auth/gmail.send`
6. **Test users**: Add your Gmail address (required while app is in Testing mode)
7. Save

## Step 4: Create OAuth Credentials

1. Go to **APIs & Services** → **Credentials**
2. Click **Create Credentials** → **OAuth client ID**
3. Application type: **Web application**
4. Name: `n8n local`
5. **Authorized redirect URIs** — add exactly:
   ```
   http://localhost:5678/rest/oauth2-credential/callback
   ```
6. Click **Create**
7. Copy the **Client ID** and **Client Secret**

## Step 5: Connect in n8n

1. Open n8n at http://localhost:5678
2. Go to **Credentials** → **Add Credential**
3. Search for **Gmail OAuth2 API**
4. Paste Client ID and Client Secret
5. Click **Sign in with Google** and authorize
6. Save as **Gmail OAuth2**

## Step 6: Link to Workflow

1. Open workflow **02 - Support Agent**
2. Click the **Gmail Send** node
3. Select your **Gmail OAuth2** credential
4. Save the workflow

## Step 7: Test

Send a test email from the Gmail node (Execute step) or submit a demo inquiry via `demo/index.html`.

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `redirect_uri_mismatch` | Redirect URI must match exactly: `http://localhost:5678/rest/oauth2-credential/callback` |
| `access_denied` | Add your email as a Test user in OAuth consent screen |
| Token expired | Re-authenticate in n8n Credentials → Gmail OAuth2 → Reconnect |
| Email not received | Check spam; verify `sendTo` is correct in workflow |
| `insufficient permissions` | Ensure `gmail.send` scope is added to consent screen |

## Production Notes

- Move OAuth app from **Testing** to **Published** for non-test-user access
- Use a dedicated sending address (e.g., `support@yourcompany.com`)
- Consider Gmail sending limits (500/day for free Gmail, higher for Workspace)
