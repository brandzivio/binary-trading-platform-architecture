-- Reference sketch (PostgreSQL). Not a complete or production schema.
-- Rows in trades and ledger_entries are never updated after settlement; corrections are new ledger entries.

CREATE TABLE ledger_entries (
  id              BIGSERIAL PRIMARY KEY,
  user_id         BIGINT NOT NULL,
  kind            TEXT NOT NULL CHECK (kind IN ('deposit','withdrawal','stake_hold','stake_release','payout','correction')),
  amount          NUMERIC(18,2) NOT NULL,
  balance_before  NUMERIC(18,2) NOT NULL,
  balance_after   NUMERIC(18,2) NOT NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE trades (
  id                  BIGSERIAL PRIMARY KEY,
  user_id             BIGINT NOT NULL,
  asset               TEXT NOT NULL,
  direction           TEXT NOT NULL CHECK (direction IN ('above','below')),
  stake               NUMERIC(18,2) NOT NULL,
  payout_percent      NUMERIC(6,2) NOT NULL,         -- fixed at entry
  accepted_at         TIMESTAMPTZ NOT NULL,
  expiry_at           TIMESTAMPTZ NOT NULL,
  entry_price         NUMERIC(18,6) NOT NULL,
  entry_tick_at       TIMESTAMPTZ NOT NULL,
  entry_feed_source   TEXT NOT NULL,
  stake_ledger_id     BIGINT NOT NULL REFERENCES ledger_entries(id),
  expiry_price        NUMERIC(18,6),
  expiry_tick_at      TIMESTAMPTZ,
  expiry_feed_source  TEXT,
  result              TEXT CHECK (result IN ('win','loss','void')),
  payout_amount       NUMERIC(18,2),
  settlement_ledger_id BIGINT REFERENCES ledger_entries(id)
);

CREATE TABLE asset_pauses (
  id            BIGSERIAL PRIMARY KEY,
  asset         TEXT NOT NULL,
  reason        TEXT NOT NULL,                       -- e.g. no valid tick within the allowed gap
  paused_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  resolved_at   TIMESTAMPTZ,
  rule_applied  TEXT                                  -- documented rule for open trades
);
