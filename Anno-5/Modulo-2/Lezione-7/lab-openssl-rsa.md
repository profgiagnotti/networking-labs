# 🔬 Lab — Crittografia asimmetrica RSA con OpenSSL

![Materia](https://img.shields.io/badge/materia-Networking-3DE8A0?style=flat-square)
![Anno](https://img.shields.io/badge/anno-5-3DE8A0?style=flat-square)
![Modulo](https://img.shields.io/badge/modulo-2-3DE8A0?style=flat-square)
![Livello](https://img.shields.io/badge/livello-avanzato-FF5C5C?style=flat-square)
![OS](https://img.shields.io/badge/OS-Windows%20%7C%20Linux%20%7C%20macOS-4A9EFF?style=flat-square)

> Laboratorio pratico su crittografia asimmetrica RSA — Anno 5, Modulo 2  
> 🌐 Teoria collegata: [profgiagnotti.it — L07 Crittografia asimmetrica, RSA e sistemi ibridi](https://profgiagnotti.it/corsi/networking/)

---

## 🎯 Obiettivi

Al termine di questo laboratorio sarai in grado di:

- ✅ Generare una coppia di chiavi RSA (2048 e 4096 bit) con OpenSSL
- ✅ Estrarre e ispezionare la chiave pubblica e i parametri interni (n, e, d)
- ✅ Cifrare un messaggio con la chiave pubblica e decifrarlo con la chiave privata
- ✅ Implementare lo schema ibrido RSA + AES che usa TLS nella realtà
- ✅ Confrontare le prestazioni RSA-2048 vs RSA-4096 vs AES-256
- ✅ Comprendere il ruolo del padding OAEP nella sicurezza RSA moderna

---

## 🛠️ Software necessario

| Software | Funzione | Note |
|---|---|---|
| **OpenSSL** | Toolkit crittografico | Vedi Lab L06 per installazione |
| **Terminale** | Esecuzione comandi | PowerShell / Bash |
| **Python 3** (opzionale) | Script di verifica matematica RSA | Preinstallato su Linux/macOS |

---

## 📋 Fase 1 — Generazione della coppia di chiavi RSA

### Step 1.1 — Genera una chiave privata RSA-2048

```bash
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out chiave_privata.pem
```

Il file `chiave_privata.pem` contiene sia la chiave privata che tutti i parametri RSA (n, e, d, p, q e altri valori ottimizzati con il Teorema Cinese del Resto).

Visualizza il contenuto grezzo:
```bash
cat chiave_privata.pem
```

Vedrai un blocco Base64 tra `-----BEGIN PRIVATE KEY-----` e `-----END PRIVATE KEY-----`.

### Step 1.2 — Genera anche una chiave RSA-4096

```bash
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 -out chiave_privata_4096.pem
```

> ⏳ La generazione RSA-4096 richiede qualche secondo in più: il sistema deve trovare due numeri primi molto grandi.

### Step 1.3 — Proteggi la chiave privata con passphrase

In produzione la chiave privata va sempre protetta con una passphrase:

```bash
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 \
  -aes-256-cbc -pass pass:PassphraseSegreta!2024 \
  -out chiave_privata_protetta.pem
```

Verifica che sia protetta:
```bash
# Questo fallirà senza la passphrase corretta
openssl pkey -in chiave_privata_protetta.pem -noout -text 2>/dev/null || \
  echo "Chiave protetta — richiede passphrase"

# Questo funzionerà con la passphrase
openssl pkey -in chiave_privata_protetta.pem -passin pass:PassphraseSegreta!2024 -noout -text 2>&1 | head -5
```

---

## 📋 Fase 2 — Ispezione dei parametri RSA

### Step 2.1 — Visualizza tutti i parametri della chiave

```bash
openssl pkey -in chiave_privata.pem -text -noout
```

Output (abbreviato):
```
Private-Key: (2048 bit)
modulus:          ← questo è n = p × q (2048 bit = 256 byte)
    00:c3:4a:f2:...
publicExponent: 65537 (0x10001)   ← questo è e
privateExponent:  ← questo è d (segreto!)
    ...
prime1:           ← questo è p
    ...
prime2:           ← questo è q
    ...
```

**Osservazioni chiave:**
- `publicExponent` è quasi sempre **65537** (0x10001) — valore standard scelto per efficienza
- `modulus` è il valore `n = p × q` — visibile a tutti, parte della chiave pubblica
- `privateExponent` è `d` — deve rimanere segreto

### Step 2.2 — Estrai la chiave pubblica

```bash
openssl pkey -in chiave_privata.pem -pubout -out chiave_pubblica.pem
cat chiave_pubblica.pem
```

La chiave pubblica contiene solo `n` e `e` — sicura da distribuire.

```bash
# Visualizza i parametri della chiave pubblica
openssl pkey -pubin -in chiave_pubblica.pem -text -noout
```

### Step 2.3 — Confronta le dimensioni

```bash
ls -lh chiave_privata.pem chiave_privata_4096.pem chiave_pubblica.pem
wc -c chiave_privata.pem chiave_privata_4096.pem chiave_pubblica.pem
```

**📝 Domanda 1:** La chiave privata RSA-2048 ha circa 1700 byte in formato PEM. Perché è molto più grande dei 256 byte (2048 bit) che compone `n`? Cosa contiene in più?

---

## 📋 Fase 3 — Cifratura e decifratura RSA

### Step 3.1 — Crea un messaggio da cifrare

```bash
echo "Chiave di sessione segreta: AES256-xyz-987" > segreto.txt
```

> ⚠️ **Limite importante di RSA:** non è possibile cifrare direttamente messaggi più grandi di `n`. Con RSA-2048 il limite pratico è circa **190 byte** con padding OAEP. Per messaggi più grandi si usa il sistema ibrido (Fase 5).

### Step 3.2 — Cifra con la chiave pubblica (padding OAEP)

```bash
openssl pkeyutl -encrypt \
  -pubin -inkey chiave_pubblica.pem \
  -pkeyopt rsa_padding_mode:oaep \
  -pkeyopt rsa_oaep_md:sha256 \
  -in segreto.txt \
  -out segreto.enc
```

Visualizza il risultato:
```bash
xxd segreto.enc | head -10
ls -lh segreto.enc
```

Il file cifrato ha sempre la stessa dimensione del modulo RSA (256 byte per RSA-2048) — indipendentemente dalla lunghezza del messaggio.

### Step 3.3 — Decifra con la chiave privata

```bash
openssl pkeyutl -decrypt \
  -inkey chiave_privata.pem \
  -pkeyopt rsa_padding_mode:oaep \
  -pkeyopt rsa_oaep_md:sha256 \
  -in segreto.enc \
  -out segreto_decifrato.txt

cat segreto_decifrato.txt
```

Verifica che il messaggio corrisponda all'originale.

### Step 3.4 — Verifica che la chiave sbagliata non funzioni

```bash
# Genera un'altra coppia di chiavi
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out altra_chiave.pem

# Tenta di decifrare con la chiave sbagliata — deve fallire
openssl pkeyutl -decrypt \
  -inkey altra_chiave.pem \
  -pkeyopt rsa_padding_mode:oaep \
  -in segreto.enc \
  -out /dev/null 2>&1 || echo "✓ Decifratura fallita — chiave errata, come atteso"
```

**📝 Domanda 2:** Il padding **OAEP** (Optimal Asymmetric Encryption Padding) è obbligatorio in RSA moderno. Cosa succede se si usa RSA senza padding (modalità `raw`)? Cerca l'attacco "RSA textbook" e descrivilo brevemente.

---

## 📋 Fase 4 — Verifica matematica RSA (opzionale — Python)

Questo script verifica i calcoli RSA visti nella teoria con i parametri dell'esempio didattico.

```bash
python3 << 'EOF'
# Parametri dell'esempio didattico della lezione
p = 11
q = 17
n = p * q                      # 187
phi_n = (p - 1) * (q - 1)      # 160
e = 7                          # esponente pubblico
d = 23                         # esponente privato: (d*e) mod phi(n) = 1

print(f"=== Parametri RSA (esempio didattico) ===")
print(f"p = {p}, q = {q}")
print(f"n = p × q = {n}")
print(f"φ(n) = (p-1)(q-1) = {phi_n}")
print(f"e = {e} (esponente pubblico)")
print(f"d = {d} (esponente privato)")
print(f"Verifica: (d × e) mod φ(n) = ({d} × {e}) mod {phi_n} = {(d*e) % phi_n}")
print()

# Cifratura del messaggio "CIAO" carattere per carattere
messaggio = "ciao"
print(f"=== Cifratura di '{messaggio}' ===")
cifrato = []
for char in messaggio:
    M = ord(char)
    C = pow(M, e, n)    # C = M^e mod n
    cifrato.append(C)
    print(f"  '{char}' → ASCII={M} → C = {M}^{e} mod {n} = {C}")

print()
print(f"=== Decifratura ===")
for i, C in enumerate(cifrato):
    M = pow(C, d, n)    # M = C^d mod n
    char = chr(M)
    print(f"  C={C} → M = {C}^{d} mod {n} = {M} → '{char}'")

print()
# Verifica con un messaggio numerico
M_test = 42
C_test = pow(M_test, e, n)
M_dec  = pow(C_test, d, n)
print(f"Test round-trip: M={M_test} → C={C_test} → M_decifrato={M_dec} {'✓' if M_dec == M_test else '✗'}")

# Mostra perché la fattorizzazione è il problema difficile
print()
print("=== Sicurezza RSA: fattorizzazione ===")
print(f"n = {n} — visibile a tutti")
print(f"Per trovare d, un attaccante deve fattorizzare n in p × q")
print(f"n = {n} = {p} × {q}")
print(f"Con n piccolo (187) è banale. Con n da 2048 bit (617 cifre decimali)")
print(f"la fattorizzazione è computazionalmente impraticabile.")
EOF
```

---

## 📋 Fase 5 — Sistema ibrido RSA + AES

Questo è il cuore del laboratorio: replica esattamente ciò che fa TLS quando visiti un sito HTTPS.

### Step 5.1 — Scenario

- **Alice** ha la sua coppia di chiavi RSA (già generate negli step precedenti)
- **Bob** vuole inviare un file segreto ad Alice
- Bob usa la chiave pubblica di Alice per trasmettere una chiave AES temporanea
- Bob cifra il file con AES usando quella chiave
- Alice decifra la chiave AES con la sua chiave privata RSA, poi decifra il file

### Step 5.2 — Bob: genera la chiave di sessione AES

```bash
# Bob genera una chiave AES-256 casuale (32 byte = 256 bit)
openssl rand -hex 32 > chiave_sessione.hex
cat chiave_sessione.hex

# Genera anche un IV casuale (16 byte = 128 bit)
openssl rand -hex 16 > iv_sessione.hex
cat iv_sessione.hex
```

### Step 5.3 — Bob: cifra il messaggio con AES

```bash
# Crea un messaggio da inviare ad Alice (può essere grande)
echo "Messaggio riservato per Alice — dati confidenziali del progetto X." > messaggio_bob.txt

# Leggi chiave e IV dai file
CHIAVE=$(cat chiave_sessione.hex)
IV=$(cat iv_sessione.hex)

# Cifra il messaggio con AES-256-CBC
openssl enc -aes-256-cbc -K $CHIAVE -iv $IV \
  -in messaggio_bob.txt -out messaggio_cifrato.bin -nosalt

echo "Messaggio cifrato con AES-256."
ls -lh messaggio_cifrato.bin
```

### Step 5.4 — Bob: cifra la chiave AES con la chiave pubblica di Alice (RSA)

```bash
# Bob cifra la chiave di sessione con la chiave pubblica di Alice
openssl pkeyutl -encrypt \
  -pubin -inkey chiave_pubblica.pem \
  -pkeyopt rsa_padding_mode:oaep \
  -pkeyopt rsa_oaep_md:sha256 \
  -in chiave_sessione.hex \
  -out chiave_sessione_cifrata.enc

echo "Chiave AES cifrata con RSA (chiave pubblica di Alice)."
ls -lh chiave_sessione_cifrata.enc
```

### Step 5.5 — Bob invia ad Alice: messaggio_cifrato.bin + chiave_sessione_cifrata.enc + iv_sessione.hex

> In TLS questi tre elementi vengono trasmessi durante l'handshake e nello stream cifrato.

### Step 5.6 — Alice: decifra la chiave AES con la sua chiave privata

```bash
# Alice recupera la chiave di sessione usando la sua chiave privata RSA
openssl pkeyutl -decrypt \
  -inkey chiave_privata.pem \
  -pkeyopt rsa_padding_mode:oaep \
  -pkeyopt rsa_oaep_md:sha256 \
  -in chiave_sessione_cifrata.enc \
  -out chiave_sessione_recuperata.hex

echo "Chiave AES recuperata da Alice:"
cat chiave_sessione_recuperata.hex

# Verifica che coincida con quella di Bob
diff chiave_sessione.hex chiave_sessione_recuperata.hex && \
  echo "✓ Chiavi identiche — scambio riuscito!" || \
  echo "✗ Errore — le chiavi non coincidono"
```

### Step 5.7 — Alice: decifra il messaggio con AES

```bash
CHIAVE_ALICE=$(cat chiave_sessione_recuperata.hex)
IV_ALICE=$(cat iv_sessione.hex)

openssl enc -aes-256-cbc -d \
  -K $CHIAVE_ALICE -iv $IV_ALICE \
  -in messaggio_cifrato.bin -out messaggio_decifrato.txt -nosalt

echo "Messaggio decifrato da Alice:"
cat messaggio_decifrato.txt
```

**📝 Domanda 3:** In questo schema, cosa succederebbe se un attaccante intercettasse `chiave_sessione_cifrata.enc` e `messaggio_cifrato.bin` durante la trasmissione? Potrebbe leggere il messaggio? Perché?

**📝 Domanda 4:** Perché Bob non ha cifrato direttamente il messaggio con RSA invece di usare AES? Prova a cifrare un file da 1 MB con RSA e osserva cosa succede.

---

## 📋 Fase 6 — Benchmark: RSA vs AES

### Step 6.1 — Benchmark integrato OpenSSL

```bash
openssl speed rsa2048 rsa4096 aes-256-cbc
```

Output esempio:
```
                  sign    verify    sign/s verify/s
rsa  2048 bits   0.0008s  0.0000s   1250.0  38500.0
rsa  4096 bits   0.0055s  0.0001s    181.8  10200.0

             16 bytes    256 bytes   8192 bytes
aes-256-cbc  897000.0k  925000.0k  930000.0k
```

### Step 6.2 — Confronto pratico: cifratura file da 1 MB

```bash
# Crea un file da 1 MB
dd if=/dev/urandom of=test_1mb.bin bs=1M count=1 2>/dev/null

# Tempo con AES-256
time openssl enc -aes-256-cbc -salt -pbkdf2 \
  -in test_1mb.bin -out /dev/null -pass pass:test

# Tempo con RSA-2048 — tenterà di cifrare ma fallirà per il limite dimensione
time openssl pkeyutl -encrypt -pubin -inkey chiave_pubblica.pem \
  -pkeyopt rsa_padding_mode:oaep \
  -in test_1mb.bin -out /dev/null 2>&1 | head -3
```

RSA fallirà con `data too large for key size` — questo dimostra perché il sistema ibrido è necessario.

**📝 Domanda 5:** Completa la tabella con i risultati del tuo sistema:

| Algoritmo | Operazione | Tempo (10 MB) | Note |
|---|---|---|---|
| AES-256-CBC | Cifratura | ___ ms | Hardware accelerato |
| RSA-2048 | Cifratura | N/A | Limite ~190 byte |
| RSA-2048 | Sign (1 KB) | ___ ms | |
| RSA-4096 | Sign (1 KB) | ___ ms | |

---

## 📋 Fase 7 — Export e import chiavi in formato DER

Il formato **PEM** è Base64 testuale. Il formato **DER** è binario — usato da Java, Android, sistemi embedded.

```bash
# Converti chiave privata PEM → DER
openssl pkey -in chiave_privata.pem -out chiave_privata.der -outform DER

# Converti chiave pubblica PEM → DER
openssl pkey -pubin -in chiave_pubblica.pem -out chiave_pubblica.der -outform DER

# Confronta dimensioni
ls -lh chiave_privata.pem chiave_privata.der

# Converti di nuovo DER → PEM per verifica
openssl pkey -in chiave_privata.der -inform DER -out chiave_privata_riconvertita.pem
diff chiave_privata.pem chiave_privata_riconvertita.pem && echo "✓ File identici"
```

---

## 📋 Riepilogo comandi

```bash
# Generazione chiavi
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out privkey.pem
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -aes-256-cbc -pass pass:PWD -out privkey_enc.pem

# Estrazione chiave pubblica
openssl pkey -in privkey.pem -pubout -out pubkey.pem

# Ispezione parametri
openssl pkey -in privkey.pem -text -noout
openssl pkey -pubin -in pubkey.pem -text -noout

# Cifratura RSA (con OAEP — obbligatorio in produzione)
openssl pkeyutl -encrypt -pubin -inkey pubkey.pem \
  -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_md:sha256 \
  -in plaintext.txt -out ciphertext.enc

# Decifratura RSA
openssl pkeyutl -decrypt -inkey privkey.pem \
  -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_md:sha256 \
  -in ciphertext.enc -out plaintext_dec.txt

# Generazione chiave casuale AES
openssl rand -hex 32   # 256 bit
openssl rand -hex 16   # 128 bit (IV)

# Benchmark
openssl speed rsa2048 rsa4096 aes-256-cbc
```

---

## 📋 Domande di verifica finali

1. Hai generato una chiave RSA-2048 e una RSA-4096. Quale operazione è più lenta: la **firma** (usa la chiave privata) o la **verifica** (usa la chiave pubblica)? Perché? (suggerimento: `openssl speed rsa2048`)

2. Nel sistema ibrido implementato, quanti dati vengono cifrati con RSA? Quanti con AES? Perché questo rapporto è ottimale?

3. Cosa contiene esattamente il file `chiave_privata.pem` oltre a `d` (esponente privato)? Perché RSA memorizza anche `p`, `q` e altri valori derivati?

4. Un attaccante intercetta la tua chiave pubblica mentre la distribuisci. Cosa può fare e cosa **non** può fare con essa?

5. Perché RSA-1024 non è più considerato sicuro? Qual è la raccomandazione NIST attuale per la lunghezza minima delle chiavi RSA?

---

## 📚 Risorse

- 📄 [RFC 8017 — PKCS #1: RSA Cryptography Specifications](https://www.rfc-editor.org/rfc/rfc8017)
- 🛠️ [OpenSSL pkey — documentazione](https://www.openssl.org/docs/man3.0/man1/openssl-pkey.html)
- 🛠️ [OpenSSL pkeyutl — documentazione](https://www.openssl.org/docs/man3.0/man1/openssl-pkeyutl.html)
- 📄 [NIST SP 800-57 — Raccomandazioni lunghezza chiavi](https://csrc.nist.gov/publications/detail/sp/800-57-part-1/rev-5/final)

---

## 🔗 Risorse correlate

- 🌐 **Sito:** [profgiagnotti.it](https://profgiagnotti.it)
- ▶️ **YouTube:** [youtube.com/@profgiagnotti](https://youtube.com/@profgiagnotti)
- 💬 **Discord:** [Unisciti alla community](https://discord.gg/profgiagnotti)

---

*Materiale a scopo educativo · Licenza MIT · Prof. Giagnotti*
