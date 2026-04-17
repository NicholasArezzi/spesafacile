-- Profilo utente con statistiche e città per la classifica
CREATE TABLE IF NOT EXISTS user_profiles (
  user_id      UUID        PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nome         TEXT        NOT NULL DEFAULT '',
  punti        INT         NOT NULL DEFAULT 0 CHECK (punti >= 0),
  scontrini    INT         NOT NULL DEFAULT 0 CHECK (scontrini >= 0),
  risparmio    NUMERIC(10,2) NOT NULL DEFAULT 0,
  liste        INT         NOT NULL DEFAULT 0 CHECK (liste >= 0),
  ricette      INT         NOT NULL DEFAULT 0 CHECK (ricette >= 0),
  citta        TEXT        NOT NULL DEFAULT '',
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS user_profiles_punti_idx
  ON user_profiles (punti DESC);

CREATE INDEX IF NOT EXISTS user_profiles_citta_punti_idx
  ON user_profiles (citta, punti DESC);

ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Tutti possono leggere i profili (per la classifica)
CREATE POLICY "user_profiles_select_all"
  ON user_profiles FOR SELECT
  USING (true);

-- Ogni utente scrive solo il proprio profilo
CREATE POLICY "user_profiles_insert_own"
  ON user_profiles FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "user_profiles_update_own"
  ON user_profiles FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "user_profiles_delete_own"
  ON user_profiles FOR DELETE
  USING (auth.uid() = user_id);
