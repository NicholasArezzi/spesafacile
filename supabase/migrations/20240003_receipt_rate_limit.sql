-- Trigger server-side per limitare gli inserimenti in receipt_hashes a 5 al giorno per utente.
-- Impedisce bypass del rate-limit client-side.

CREATE OR REPLACE FUNCTION check_receipt_daily_limit()
RETURNS TRIGGER AS $$
DECLARE
  daily_count INT;
BEGIN
  SELECT COUNT(*) INTO daily_count
  FROM receipt_hashes
  WHERE user_id = NEW.user_id
    AND created_at >= date_trunc('day', now())
    AND created_at < date_trunc('day', now()) + interval '1 day';

  IF daily_count >= 5 THEN
    RAISE EXCEPTION 'Limite giornaliero raggiunto: massimo 5 scontrini al giorno'
      USING ERRCODE = 'P0001';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_receipt_daily_limit ON receipt_hashes;

CREATE TRIGGER trg_receipt_daily_limit
  BEFORE INSERT ON receipt_hashes
  FOR EACH ROW
  EXECUTE FUNCTION check_receipt_daily_limit();
