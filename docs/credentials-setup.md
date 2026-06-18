# n8n Credentials Setup

After starting the stack, configure these credentials in n8n (http://localhost:5678).

## 1. Ollama Local

| Field | Value |
|-------|-------|
| Type | Ollama |
| Name | `Ollama Local` |
| Base URL | `http://ollama:11434` |

**Mac native Ollama:** use `http://host.docker.internal:11434`

## 2. Ollama OpenAI Compatible (Embeddings)

| Field | Value |
|-------|-------|
| Type | OpenAI |
| Name | `Ollama OpenAI Compatible` |
| API Key | `ollama` (any non-empty string) |
| Base URL | `http://ollama:11434/v1` |

Used for `nomic-embed-text` embeddings with **dimensions: 768**.

> Do NOT use the native Embeddings Ollama node — it has a known bug with Qdrant.

## 3. Qdrant Local

| Field | Value |
|-------|-------|
| Type | Qdrant |
| Name | `Qdrant Local` |
| URL | `http://qdrant:6333` |
| API Key | (leave empty for local) |

## 4. Support Agent Postgres

| Field | Value |
|-------|-------|
| Type | Postgres |
| Name | `Support Agent Postgres` |
| Host | `postgres` |
| Port | `5432` |
| Database | `support_agent` |
| User | `support_agent` |
| Password | From your `.env` `POSTGRES_PASSWORD` |
| SSL | Off |

## 5. Gmail OAuth2

See [gmail-setup.md](gmail-setup.md).

---

## Assign Credentials to Workflows

### 01 - KB Ingestion

| Node | Credential |
|------|------------|
| Qdrant Insert | Qdrant Local |
| Embeddings OpenAI (Ollama) | Ollama OpenAI Compatible |

### 02 - Support Agent

| Node | Credential |
|------|------------|
| Ollama Chat (Intent) | Ollama Local |
| Ollama Chat (Billing) | Ollama Local |
| Ollama Chat (Agent) | Ollama Local |
| Ollama Chat (Feature) | Ollama Local |
| Qdrant Billing RAG | Qdrant Local |
| Qdrant RAG Tool | Qdrant Local |
| Embeddings (Billing) | Ollama OpenAI Compatible |
| Embeddings (Agent) | Ollama OpenAI Compatible |
| Gmail Send | Gmail OAuth2 |
| Log to Postgres | Support Agent Postgres |

### 03 - Error Handler

| Node | Credential |
|------|------------|
| Log Error to Postgres | Support Agent Postgres |

---

## Link Error Workflow

1. Open **02 - Support Agent**
2. Workflow menu (⋯) → **Settings**
3. **Error Workflow** → select **03 - Error Handler**
4. Save

## Activate Workflows

1. **02 - Support Agent** — toggle **Active** (required for webhook)
2. **03 - Error Handler** — toggle **Active** (required for error catching)

**01 - KB Ingestion** stays inactive (manual trigger only).

## Verify

```bash
./scripts/verify-stack.sh
```

Then submit a test inquiry from `demo/index.html`.
