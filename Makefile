.PHONY: guide help setup setup-interactive up down logs verify prewarm demo prove serve ingest psql

guide:
	./scripts/guide.sh

help:
	./scripts/help.sh

setup:
	./scripts/setup.sh

setup-interactive:
	./scripts/interactive-setup.sh

up:
	docker compose --profile cpu up -d

down:
	docker compose --profile cpu down

logs:
	docker compose --profile cpu logs -f

verify:
	./scripts/verify-stack.sh

prove:
	./scripts/demo-proof.sh

prewarm:
	./scripts/prewarm-demo.sh

demo:
	./scripts/serve-demo.sh

serve:
	./scripts/serve-demo.sh

ingest:
	./scripts/trigger-ingestion.sh

psql:
	docker compose exec postgres psql -U support_agent -d support_agent
