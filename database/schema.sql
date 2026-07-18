-- SewaBukti structured data model (Turso / libSQL, SQLite dialect).
-- See requirements §13. Applied by server-side Edge Functions only; the
-- Flutter client never connects to Turso directly (§8.1).
--
-- Conventions:
--   * ids are application-generated UUID strings (TEXT).
--   * money is stored as INTEGER sen (1 RM = 100 sen) to avoid float rounding.
--   * timestamps are ISO-8601 UTC TEXT set by the server.
--   * the external Google account is identified by the stable `sub` claim,
--     never by email (FR-AUTH-08).

PRAGMA foreign_keys = ON;

-- 13.1 users -----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
  id                 TEXT PRIMARY KEY,
  google_subject_id  TEXT NOT NULL UNIQUE,            -- Google `sub`; account key
  email              TEXT NOT NULL,
  full_name          TEXT,
  preferred_language TEXT NOT NULL DEFAULT 'en'
                       CHECK (preferred_language IN ('en', 'ms', 'zh-Hans')),
  theme_mode         TEXT NOT NULL DEFAULT 'light'
                       CHECK (theme_mode IN ('light', 'dark')),
  created_at         TEXT NOT NULL,
  updated_at         TEXT NOT NULL,
  deleted_at         TEXT
);

-- Retention purge scan (§23.3): find soft-deleted users past the grace window.
CREATE INDEX IF NOT EXISTS idx_users_deleted ON users(deleted_at)
  WHERE deleted_at IS NOT NULL;

-- 13.2 cases -----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS cases (
  id                    TEXT PRIMARY KEY,
  user_id               TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status                TEXT NOT NULL DEFAULT 'draft'
                          CHECK (status IN (
                            'draft', 'active', 'demand_sent',
                            'preparing_claim', 'closed', 'archived')),

  -- Property
  property_line1        TEXT,
  property_line2        TEXT,
  property_city         TEXT,
  property_postcode     TEXT,
  property_state        TEXT,

  -- Tenancy timeline
  tenancy_start_date    TEXT,
  tenancy_end_date      TEXT,
  vacated_date          TEXT,
  keys_returned_date    TEXT,
  refund_deadline_date  TEXT,
  monthly_rent_sen      INTEGER,

  -- Claimant (tenant)
  claimant_full_name    TEXT,
  claimant_id_number    TEXT,                          -- optional, masked in UI
  claimant_email        TEXT,
  claimant_phone        TEXT,
  claimant_address      TEXT,

  -- Other party
  other_party_type      TEXT CHECK (other_party_type IN
                            ('landlord', 'agent', 'management', 'uncertain')),
  other_party_is_company INTEGER NOT NULL DEFAULT 0,   -- boolean 0/1
  other_party_name      TEXT,
  other_party_company_no TEXT,
  other_party_email     TEXT,
  other_party_phone     TEXT,
  other_party_address   TEXT,
  deposit_received_by   TEXT,
  deposit_promised_by   TEXT,

  -- Deposit components and outcome (sen)
  security_deposit_sen  INTEGER NOT NULL DEFAULT 0,
  utility_deposit_sen   INTEGER NOT NULL DEFAULT 0,
  access_deposit_sen    INTEGER NOT NULL DEFAULT 0,
  other_deposit_sen     INTEGER NOT NULL DEFAULT 0,
  amount_refunded_sen   INTEGER NOT NULL DEFAULT 0,
  deductions_accepted_sen INTEGER NOT NULL DEFAULT 0,
  deductions_disputed_sen INTEGER NOT NULL DEFAULT 0,
  -- Calculated server-side and stored for the record (FR-CASE-06).
  amount_claimed_sen    INTEGER NOT NULL DEFAULT 0,

  demand_deadline_date  TEXT,                          -- selected by tenant

  created_at            TEXT NOT NULL,
  updated_at            TEXT NOT NULL,
  deleted_at            TEXT                          -- soft-delete marker (§23.3)
);

CREATE INDEX IF NOT EXISTS idx_cases_user ON cases(user_id);

-- Enforce at most one ACTIVE, non-deleted case per user (§12.2 active = 1).
-- Dropped and recreated so re-applying this schema updates the predicate to
-- exclude soft-deleted cases on an existing database.
DROP INDEX IF EXISTS uq_cases_one_active_per_user;
CREATE UNIQUE INDEX uq_cases_one_active_per_user
  ON cases(user_id) WHERE status = 'active' AND deleted_at IS NULL;

-- Retention purge scan (§23.3): find soft-deleted cases past the grace window.
CREATE INDEX IF NOT EXISTS idx_cases_deleted ON cases(deleted_at)
  WHERE deleted_at IS NOT NULL;

-- 13.3 evidence_files --------------------------------------------------------
CREATE TABLE IF NOT EXISTS evidence_files (
  id                TEXT PRIMARY KEY,
  case_id           TEXT NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
  user_id           TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  category          TEXT NOT NULL,
  title             TEXT,
  description       TEXT,
  document_date     TEXT,                              -- original document/event date
  original_filename TEXT NOT NULL,
  storage_path      TEXT NOT NULL,                     -- {user}/{case}/{uuid}.{ext}
  mime_type         TEXT NOT NULL,
  size_bytes        INTEGER NOT NULL,
  sha256_hash       TEXT,                              -- where practical (FR-EVD-08)
  uploaded_at       TEXT NOT NULL,
  deleted_at        TEXT
);

CREATE INDEX IF NOT EXISTS idx_evidence_case ON evidence_files(case_id);
CREATE INDEX IF NOT EXISTS idx_evidence_user ON evidence_files(user_id);

-- Retention purge scan (§23.3): find soft-deleted evidence past the grace
-- window (evidence is soft-deleted when its storage object removal failed).
CREATE INDEX IF NOT EXISTS idx_evidence_deleted ON evidence_files(deleted_at)
  WHERE deleted_at IS NOT NULL;

-- 13.4 timeline_events -------------------------------------------------------
CREATE TABLE IF NOT EXISTS timeline_events (
  id          TEXT PRIMARY KEY,
  case_id     TEXT NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
  user_id     TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  event_date  TEXT NOT NULL,
  event_time  TEXT,
  title       TEXT NOT NULL,
  description TEXT,
  sort_order  INTEGER NOT NULL DEFAULT 0,              -- override for ties (FR-CHR-04)
  created_at  TEXT NOT NULL,
  updated_at  TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_timeline_case ON timeline_events(case_id);

-- 13.5 timeline_evidence (join) ----------------------------------------------
CREATE TABLE IF NOT EXISTS timeline_evidence (
  timeline_event_id TEXT NOT NULL REFERENCES timeline_events(id) ON DELETE CASCADE,
  evidence_file_id  TEXT NOT NULL REFERENCES evidence_files(id) ON DELETE CASCADE,
  PRIMARY KEY (timeline_event_id, evidence_file_id)
);

-- 13.6 demand_letters --------------------------------------------------------
CREATE TABLE IF NOT EXISTS demand_letters (
  id                  TEXT PRIMARY KEY,
  case_id             TEXT NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
  user_id             TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  language            TEXT NOT NULL CHECK (language IN ('en', 'ms', 'zh-Hans')),
  version             INTEGER NOT NULL DEFAULT 1,
  letter_content      TEXT NOT NULL,
  generated_at        TEXT NOT NULL,
  sent_at             TEXT,
  recipient_email     TEXT,
  provider_message_id TEXT,
  delivery_status     TEXT NOT NULL DEFAULT 'not_sent'
                        CHECK (delivery_status IN
                          ('not_sent', 'queued', 'sent', 'delivered', 'failed'))
);

CREATE INDEX IF NOT EXISTS idx_demand_case ON demand_letters(case_id);

-- 13.7 audit_events ----------------------------------------------------------
-- Non-sensitive metadata only. Never store access tokens, API keys, full
-- document contents, or unnecessary identity numbers (§13.7, NFR-SEC-10).
CREATE TABLE IF NOT EXISTS audit_events (
  id          TEXT PRIMARY KEY,
  user_id     TEXT REFERENCES users(id) ON DELETE SET NULL,
  case_id     TEXT,
  action      TEXT NOT NULL,
  entity_type TEXT,
  entity_id   TEXT,
  metadata    TEXT,                                    -- JSON, non-sensitive
  created_at  TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_audit_user ON audit_events(user_id);
