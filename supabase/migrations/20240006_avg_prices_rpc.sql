-- Funzione RPC per calcolare i prezzi medi crowdsourced degli ultimi 30 giorni.
-- Restituisce solo prodotti con almeno 2 segnalazioni (per affidabilità).
-- Esclude outlier oltre 3x la mediana per store+prodotto.

CREATE OR REPLACE FUNCTION avg_prices()
RETURNS TABLE(store_name TEXT, product_key TEXT, avg_price NUMERIC)
LANGUAGE SQL
STABLE
AS $$
  WITH base AS (
    SELECT
      pr.store_name,
      pr.product_key,
      pr.price,
      PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY pr.price)
        OVER (PARTITION BY pr.store_name, pr.product_key) AS mediana
    FROM price_reports pr
    WHERE pr.created_at >= NOW() - INTERVAL '30 days'
      AND pr.price > 0
  ),
  filtered AS (
    SELECT store_name, product_key, price
    FROM base
    WHERE price <= mediana * 3   -- esclude outlier grossolani
      AND price >= mediana / 3
  )
  SELECT
    store_name,
    product_key,
    ROUND(AVG(price)::NUMERIC, 2) AS avg_price
  FROM filtered
  GROUP BY store_name, product_key
  HAVING COUNT(*) >= 2           -- almeno 2 segnalazioni
  ORDER BY store_name, product_key;
$$;
