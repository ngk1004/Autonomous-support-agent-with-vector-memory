# Live Demo Checklist

Use this checklist **the day before** and **30 minutes before** your demo.

## Day Before

- [ ] Run `./scripts/setup.sh` and wait for Ollama model pull to complete
- [ ] Configure all n8n credentials (see [credentials-setup.md](credentials-setup.md))
- [ ] Execute **01 - KB Ingestion** workflow
- [ ] Run `./scripts/verify-stack.sh` — all checks green
- [ ] Connect **Gmail OAuth2** (see [gmail-setup.md](gmail-setup.md))
- [ ] Activate **02 - Support Agent** workflow
- [ ] Link **03 - Error Handler** as error workflow in Support Agent settings
- [ ] Run all 3 demo presets from `demo/index.html`
- [ ] Confirm emails arrive in inbox (not spam)
- [ ] Run `./scripts/prewarm-demo.sh`

## 30 Minutes Before

- [ ] `docker compose --profile cpu ps` — all services up
- [ ] `./scripts/verify-stack.sh` — quick health check
- [ ] `./scripts/prewarm-demo.sh` — warm Ollama models
- [ ] Open n8n Executions tab in browser
- [ ] Open Gmail inbox
- [ ] Open `demo/index.html` via `./scripts/serve-demo.sh` (avoids file:// CORS issues)
- [ ] Test one technical inquiry end-to-end

## During Demo (5 min)

| Time | Action |
|------|--------|
| 0:00 | Show architecture diagram (README) |
| 0:30 | Open demo form, explain webhook trigger |
| 1:00 | Click **Technical Support** preset → Submit |
| 2:00 | Switch to n8n Executions — show AI Agent + Qdrant tool call |
| 2:30 | Show Gmail response with sources footer |
| 3:00 | Click **Billing** preset → show different branch + billing RAG |
| 3:30 | Query Postgres: `SELECT intent, status, processing_ms FROM support_interactions ORDER BY created_at DESC LIMIT 5;` |
| 4:30 | Mention production hardening (auth, escalation, error workflow) |

## Fallback Plans

| Problem | Fallback |
|---------|----------|
| Ollama slow | Use pre-warmed models; show n8n execution graph while waiting |
| Gmail fails | Show webhook JSON response + Postgres row (`status: failed`) |
| RAG empty | Re-run ingestion workflow; show Qdrant dashboard |
| Intent misclassified | Explain keyword fallback + confidence threshold escalation |

## After Demo

- [ ] Deactivate workflow if on shared machine
- [ ] Revoke Gmail test token if no longer needed
