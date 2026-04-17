-- Tabella per raccolta crowdsourced prezzi da scontrini fotografati
CREATE TABLE IF NOT EXISTS price_reports (
  id           BIGSERIAL PRIMARY KEY,
  store_name   TEXT        NOT NULL,
  product_key  TEXT        NOT NULL,
  price        NUMERIC(10,2) NOT NULL CHECK (price > 0 AND price < 500),
  unit         TEXT        NOT NULL DEFAULT '',
  city         TEXT        NOT NULL DEFAULT '',
  user_id      UUID        REFERENCES auth.users(id) ON DELETE SET NULL,
  is_anonymous BOOLEAN     NOT NULL DEFAULT true,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indice per la funzione avg_prices (raggruppamento per negozio+prodotto)
CREATE INDEX IF NOT EXISTS price_reports_store_product_idx
  ON price_reports (store_name, product_key);

-- Indice per query per utente
CREATE INDEX IF NOT EXISTS price_reports_user_idx
  ON price_reports (user_id, created_at DESC);

-- Indice per query per città
CREATE INDEX IF NOT EXISTS price_reports_city_idx
  ON price_reports (city, store_name);

ALTER TABLE price_reports ENABLE ROW LEVEL SECURITY;

-- Chiunque può leggere i prezzi (dati pubblici aggregati)
CREATE POLICY "price_reports_select_all"
  ON price_reports FOR SELECT
  USING (true);

-- Solo utenti autenticati inseriscono (ospiti passano user_id=null)
CREATE POLICY "price_reports_insert"
  ON price_reports FOR INSERT
  WITH CHECK (
    (auth.uid() IS NULL AND is_anonymous = true) OR
    (auth.uid() = user_id)
  );
