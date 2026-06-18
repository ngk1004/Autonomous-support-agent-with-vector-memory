.PHONY: setup up down logs verify prewarm demo serve ingest psql

setup:
	./scripts/setup.sh

up:
	docker compose --profile cpu up -d

down:
	docker compose --profile cpu down

logs:
	docker compose --profile cpu logs -f

verify:
	./scripts/verify-stack.sh

prewarm:
	./scripts/prewarm-demo.sh

demo:
	./scripts/serve-demo.sh

ingest:
	./scripts/trigger-ingestion.sh

psql:
	docker compose exec postgres psql -U support_agent -d support_agent
