-- Funzione RPC per la cancellazione completa dei dati utente (GDPR Art. 17).
-- Viene chiamata dal client tramite _supabase.rpc('delete_user').
-- Il SECURITY DEFINER permette di cancellare anche auth.users (normalmente RLS-protetto).

CREATE OR REPLACE FUNCTION delete_user()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  uid UUID := auth.uid();
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Utente non autenticato';
  END IF;

  -- Cancella tutti i dati dell'utente in ordine (foreign key safe).
  DELETE FROM user_profiles   WHERE user_id = uid;
  DELETE FROM receipt_hashes  WHERE user_id = uid;
  -- user_receipts esiste solo se la migrazione 20240002 è applicata
  BEGIN
    EXECUTE 'DELETE FROM user_receipts WHERE user_id = $1' USING uid;
  EXCEPTION WHEN undefined_table THEN
    NULL;
  END;
  -- price_reports: anonimizza (ON DELETE SET NULL è già definito, ma esplicito è meglio)
  UPDATE price_reports SET user_id = NULL WHERE user_id = uid;

  -- Infine cancella l'account auth
  DELETE FROM auth.users WHERE id = uid;
END;
$$;

REVOKE ALL ON FUNCTION delete_user() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION delete_user() TO authenticated;
