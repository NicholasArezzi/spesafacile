-- Tabella per il controllo anti-duplicato degli scontrini
-- Salva l'hash SHA-256 di ogni immagine scontrino inviata da un utente.
-- Se lo stesso hash viene inviato di nuovo, nessun punto viene assegnato.
-- Rate limit: max 5 righe per utente al giorno (controllato lato client e verificabile lato DB).

CREATE TABLE IF NOT EXISTS receipt_hashes (
  id          BIGSERIAL PRIMARY KEY,
  user_id     UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  hash        CHAR(64)    NOT NULL,   -- SHA-256 hex (256 bit = 64 char)
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indice per la query di controllo duplicati (user_id + hash)
CREATE UNIQUE INDEX IF NOT EXISTS receipt_hashes_user_hash_idx
  ON receipt_hashes (user_id, hash);

-- Indice per la query di rate-limit giornaliero (user_id + created_at)
CREATE INDEX IF NOT EXISTS receipt_hashes_user_date_idx
  ON receipt_hashes (user_id, created_at);

-- Row Level Security: ogni utente può leggere e inserire solo le proprie righe
ALTER TABLE receipt_hashes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Utente vede solo i propri hash"
  ON receipt_hashes FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Utente inserisce solo i propri hash"
  ON receipt_hashes FOR INSERT
  WITH CHECK (auth.uid() = user_id);
