-- Abbassa il limite massimo del prezzo singolo prodotto da 500 a 200 euro.
-- 500€ era irragionevole per un singolo articolo (semmai un intero carrello).
-- Il client già limita a 200€, allineiamo il DB per difesa in profondità.

ALTER TABLE price_reports
  DROP CONSTRAINT IF EXISTS price_reports_price_check;

ALTER TABLE price_reports
  ADD CONSTRAINT price_reports_price_check
  CHECK (price > 0 AND price < 200);
