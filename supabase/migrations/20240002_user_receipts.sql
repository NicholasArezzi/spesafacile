-- Storico scontrini per utente
-- Ogni riga = un scontrino confermato dall'utente
CREATE TABLE IF NOT EXISTS user_receipts (
  id              BIGSERIAL PRIMARY KEY,
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  store_name      TEXT NOT NULL DEFAULT '',
  total_amount    NUMERIC(10,2) NOT NULL DEFAULT 0,
  city            TEXT NOT NULL DEFAULT '',
  product_count   INT NOT NULL DEFAULT 0,
  punti_assegnati INT NOT NULL DEFAULT 0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indice per query rapide per utente (ordinate per data)
CREATE INDEX IF NOT EXISTS user_receipts_user_date_idx
  ON user_receipts (user_id, created_at DESC);

-- Row Level Security: ogni utente vede solo i propri scontrini
ALTER TABLE user_receipts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "user_receipts_select_own"
  ON user_receipts FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "user_receipts_insert_own"
  ON user_receipts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "user_receipts_delete_own"
  ON user_receipts FOR DELETE
  USING (auth.uid() = user_id);
