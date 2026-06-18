-- Support interactions audit log
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS support_interactions (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_name     TEXT,
  customer_email    TEXT NOT NULL,
  subject           TEXT,
  message           TEXT NOT NULL,
  intent            TEXT NOT NULL,
  intent_confidence NUMERIC(4,3),
  response_body     TEXT NOT NULL,
  response_html     TEXT,
  rag_sources       JSONB DEFAULT '[]',
  gmail_message_id  TEXT,
  status            TEXT NOT NULL DEFAULT 'sent',
  error_message     TEXT,
  processing_ms     INTEGER,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_interactions_intent ON support_interactions(intent);
CREATE INDEX IF NOT EXISTS idx_interactions_created ON support_interactions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_interactions_email ON support_interactions(customer_email);

COMMENT ON TABLE support_interactions IS 'Audit log for autonomous support agent interactions';
