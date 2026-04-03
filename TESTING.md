# Checklist Test Manuale — SpesaFacile

Eseguire **tutti** i test in questo file prima di ogni commit su `main`.
Spunta ogni voce, se qualcosa non funziona blocca il commit e apri un issue.

---

## 1. Autenticazione

### 1.1 Registrazione
- [ ] Compila nome, email valida, password ≥ 6 caratteri → clicca "Crea account"
- [ ] Compare toast "Controlla la tua email" e si apre la schermata email-verifica
- [ ] Registrazione con password con **spazi** (es. `"test "`): deve registrare correttamente e il login successivo con la stessa password deve funzionare
- [ ] Registrazione con email già esistente → compare messaggio di errore appropriato
- [ ] Registrazione senza accettare Privacy Policy → toast di errore, nessuna chiamata a Supabase

### 1.2 Login
- [ ] Login con credenziali corrette → schermata Home
- [ ] Login con password sbagliata → toast "Credenziali errate"
- [ ] Login con email non confermata → toast + redirect a email-verifica
- [ ] Login senza Supabase disponibile (`_supabase = null`) → toast "Servizio non disponibile"

### 1.3 Accesso ospite
- [ ] "Entra come ospite" → schermata Home con nome "Ospite"
- [ ] Badge, punti e risparmio mostrano 0 (nessun +1 artificiale)

### 1.4 Logout
- [ ] Logout → redirect login, localStorage pulito
- [ ] Dopo logout, navigare indietro con browser non deve mostrare dati dell'utente precedente

### 1.5 Reset password
- [ ] Inserisci email valida → toast "Email inviata"
- [ ] Inserisci email vuota → toast "Inserisci la tua email"

### 1.6 Reinvio email verifica
- [ ] Nella schermata email-verifica, clicca "Reinvia" → toast "Email inviata di nuovo!"
- [ ] Doppio click rapido → non invia due volte (rate limit Supabase)

---

## 2. Home

- [ ] Il nome utente viene mostrato correttamente
- [ ] I 4 contatori (punti, scontrini, liste, risparmio) mostrano i valori reali da `userData`
- [ ] Badge count = numero esatto di badge guadagnati (0 per utente nuovo, non 1)
- [ ] Le 4 card offerte preview si caricano (no errori JS in console)
- [ ] Cliccando una card offerta → naviga alla schermata Offerte
- [ ] La città dell'utente appare nel titolo "Convenienza oggi — [Città]" (se rilevata)

---

## 3. Lista della spesa

- [ ] Scrivere prodotti nel notepad → contatore "N prodotti scritti" si aggiorna
- [ ] Premere "Analizza Lista" con notepad vuoto → toast di errore
- [ ] Premere "Analizza Lista" con prodotti → naviga a Confronta
- [ ] Lista con quantità ("2 pasta", "500 g farina") → quantità riconosciute correttamente
- [ ] Secondo click su "Analizza Lista" con stessa lista → `userData.liste` NON si incrementa
- [ ] Secondo click con lista diversa → `userData.liste` SI incrementa

---

## 4. Confronta prezzi

- [ ] La classifica store mostra i totali ordinati dal più economico
- [ ] Il miglior store ha il banner "MIGLIOR PREZZO"
- [ ] Cliccando sul banner miglior store → naviga alla Mappa con toast del nome store
- [ ] Risparmio banner mostra differenza max−min corretta (non Infinity, non NaN)
- [ ] Tab "Prodotti" mostra ogni prodotto con prezzi per store
- [ ] Con prodotti non presenti in DB → viene mostrato "prezzo stimato" (non crash)

---

## 5. Scontrino

### 5.1 Inserimento manuale
- [ ] Clicca "Inserisci manualmente" → si apre il form scontrino
- [ ] Cerca prodotto (≥ 2 caratteri) → autocomplete appare
- [ ] Seleziona prodotto dall'autocomplete → aggiunto alla lista, input si svuota
- [ ] Prodotto già nella lista → qty aumenta di 1 (non aggiunto due volte)
- [ ] Pulsante ✕ rimuove il prodotto
- [ ] Conferma senza store selezionato → toast "Seleziona il supermercato!"
- [ ] Conferma senza totale → toast "Inserisci il totale speso!"
- [ ] Conferma valida (manuale) → scontrino registrato, 0 punti (nessuna foto), toast corretto

### 5.2 Foto + OCR
- [ ] Cliccando fotocamera si apre picker file
- [ ] Dopo selezione foto → spinner "Analisi OCR in corso"
- [ ] OCR completato → form pre-compilato con store, totale, prodotti riconosciuti
- [ ] Se OCR fallisce → fallback Tesseract locale, poi form vuoto
- [ ] Conferma con foto + totale OCR valido + utente registrato → punti assegnati
- [ ] Stesso scontrino inviato due volte → secondo invio ha 0 punti + toast "Scontrino già inserito"
- [ ] Più di 5 scontrini con punti in un giorno → toast "Limite giornaliero raggiunto"

---

## 6. Mappa

- [ ] Navigando alla mappa → spinner di caricamento, poi mappa Leaflet
- [ ] Marker utente (pallino verde) appare
- [ ] Marker supermercati (quadrati colorati) appaiono entro 3 km
- [ ] Popup supermercato mostra nome e link "Portami qui →"
- [ ] Bottone GPS manuale → richiede permesso, aggiorna posizione
- [ ] GPS negato → toast con istruzioni
- [ ] Navigare via dalla mappa e tornare → mappa non si re-inizializza da zero (usa `_mapInitialized`)

---

## 7. Ricette (Ispirami)

- [ ] Griglia ricette si carica da `recipes.json`
- [ ] Filtro categoria funziona (Tutte, Primi, Secondi…)
- [ ] Filtro difficoltà funziona (Facile/Media/Difficile)
- [ ] Ricerca per nome filtra in tempo reale
- [ ] Cliccando ricetta → modal aperto con ingredienti
- [ ] Cambio persone +/- → quantità ingredienti si ricalcolano
- [ ] Tab Ingredienti / Preparazione → switching funziona
- [ ] "Aggiungi alla lista" con nessun ingrediente selezionato → aggiunge tutti
- [ ] "Aggiungi alla lista" con ingredienti selezionati → aggiunge solo quelli
- [ ] Dopo "Aggiungi lista" → `userData.ricette` incrementa di 1

---

## 8. Casa (prodotti per la casa)

- [ ] Griglia prodotti si carica da `casa.json`
- [ ] Filtro categoria (Tutti, Pulizia, Igiene, Cucina, Bucato) funziona
- [ ] Ricerca per nome filtra
- [ ] Cliccare prodotto → aggiunto al notepad con **un solo toast** (non due)
- [ ] Toast mostrato: "[Nome] aggiunto!" (non mostrare due toast sovrapposti)

---

## 9. Offerte

- [ ] 12 offerte generate e mostrate (numero da `APP_CONFIG.OFFERS_COUNT`)
- [ ] Filtro "Cibo" / "Casa" funziona
- [ ] Prezzi barrati (prezzoNorm) sempre > prezzo offerta (prezzoOff)
- [ ] Sconto % coerente: `prezzoOff ≈ prezzoNorm × (1 - sconto/100)`
- [ ] Stesse offerte a parità di data (deterministiche)
- [ ] Offerte cambiano il giorno dopo
- [ ] Bottone "Acquista su X" appare solo se affiliato configurato in `config.js`

---

## 10. Classifica

- [ ] Utente ospite → podio mostra solo se stesso + banner registrazione
- [ ] Utente registrato → carica classifica da Supabase filtrata per città
- [ ] L'utente corrente è evidenziato in verde con "(tu)"
- [ ] Se utente non è in classifica ma ha punti → viene aggiunto in fondo e ordinato
- [ ] Chip città: se città nota mostra "Milano 🏙️", altrimenti "Italia 🇮🇹"

---

## 11. Profilo

- [ ] Nome, data iscrizione, città mostrati correttamente
- [ ] Statistiche (risparmio, punti, scontrini) aggiornate
- [ ] Badge sbloccati solo quando condizione soddisfatta
- [ ] Progress bar obiettivi aggiornate con valori reali
- [ ] "Elimina account" chiede conferma, poi esegue RPC Supabase e fa logout
- [ ] "Eliminazione account" su account ospite → toast "Nessun account registrato"

---

## 12. PWA / Offline

- [ ] Service Worker registrato (controllare DevTools → Application → Service Workers)
- [ ] Ricaricare con rete disattivata → app si carica da cache
- [ ] `products.json`, `recipes.json`, `casa.json` si aggiornano con strategia network-first (rete prima, poi cache)

---

## 13. Regressioni critiche da controllare SEMPRE

Questi sono i bug già fixati più volte. Controllarli ad ogni commit:

- [ ] **Password spazi**: registrazione con `"test "` → login con `"test "` funziona
- [ ] **Infinity nel banner risparmio**: lista con 1 prodotto non trovato in DB → nessun `Infinity` mostrato
- [ ] **Classifica città**: chip e subtitle mostrano la città dell'utente, non "Milano" fisso
- [ ] **Nominatim**: rilevazione città non parte due volte in parallelo (flag `_nominatimPending`)
- [ ] **OCR duplicati**: stesso scontrino → 0 punti al secondo invio
- [ ] **Badge count home**: utente nuovo → mostra 0 badge (non 1)
- [ ] **Toast Casa**: click su prodotto Casa → 1 solo toast (non 2 sovrapposti)
- [ ] **Onclick negozio**: il click su store nella classifica non genera errori in console

---

## Come usare questa checklist

1. Prima di ogni `git commit` su `main`, apri questo file
2. Esegui manualmente i test rilevanti per le modifiche fatte
3. Esegui **sempre** la sezione 13 (regressioni critiche)
4. Se un test fallisce: **non committare**, correggi prima
5. Aggiungi nuovi test ogni volta che scopri e risolvi un bug (prevenzione regressione)
