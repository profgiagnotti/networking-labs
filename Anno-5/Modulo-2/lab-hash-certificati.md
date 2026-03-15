# 🔬 Lab — Hash crittografici e certificati digitali con OpenSSL

![Materia](https://img.shields.io/badge/materia-Networking-3DE8A0?style=flat-square)
![Anno](https://img.shields.io/badge/anno-5-3DE8A0?style=flat-square)
![Modulo](https://img.shields.io/badge/modulo-2-3DE8A0?style=flat-square)
![Livello](https://img.shields.io/badge/livello-avanzato-FF5C5C?style=flat-square)
![OS](https://img.shields.io/badge/OS-Windows%20%7C%20Linux%20%7C%20macOS-4A9EFF?style=flat-square)

> Laboratorio pratico su hash, firma digitale e certificati X.509 — Anno 5, Modulo 2  
> 🌐 Teoria collegata: [profgiagnotti.it — L08 Autenticazione, hash, firma digitale, certificati](https://profgiagnotti.it/corsi/networking/)

---

## 🎯 Obiettivi

Al termine di questo laboratorio sarai in grado di:

- ✅ Calcolare digest SHA-256 e SHA-512 di file e testi e verificare l'**effetto valanga**
- ✅ Verificare l'**integrità** di un file scaricato tramite confronto SHA-256
- ✅ Creare una **firma digitale** su un documento e verificarla
- ✅ Generare un **certificato X.509 self-signed** e ispezionarne i campi
- ✅ Creare una mini **PKI locale** con una CA radice e un certificato firmato dalla CA
- ✅ Ispezionare il certificato TLS di un sito reale (es. profgiagnotti.it)

---

## 🛠️ Software necessario

| Software | Funzione | Note |
|---|---|---|
| **OpenSSL** | Tutto — hash, firma, certificati | Vedi Lab L06 per installazione |
| **Terminale** | Esecuzione comandi | PowerShell / Bash |

---

## 📋 Fase 1 — Hash crittografici: SHA-256 e SHA-512

### Step 1.1 — Calcola SHA-256 di un testo

```bash
# Linux/macOS
echo -n "Sicurezza Informatica" | openssl dgst -sha256
echo -n "sicurezza informatica" | openssl dgst -sha256

# Windows PowerShell
echo -n "Sicurezza Informatica" | openssl dgst -sha256
```

Output:
```
SHA2-256(stdin)= 3c4a...   (lettera maiuscola)
SHA2-256(stdin)= f9b2...   (lettera minuscola)
```

Nota: **una sola lettera cambia l'intero digest** — effetto valanga.

### Step 1.2 — Confronta SHA-256, SHA-512 e MD5

```bash
echo -n "Hello World" | openssl dgst -md5
echo -n "Hello World" | openssl dgst -sha1
echo -n "Hello World" | openssl dgst -sha256
echo -n "Hello World" | openssl dgst -sha512
```

Osserva la lunghezza crescente dei digest:

| Algoritmo | Lunghezza output | Caratteri hex |
|---|---|---|
| MD5 | 128 bit | 32 |
| SHA-1 | 160 bit | 40 |
| SHA-256 | 256 bit | 64 |
| SHA-512 | 512 bit | 128 |

### Step 1.3 — Hash di un file

```bash
# Crea un documento
echo "Contratto: Mario Rossi si impegna a consegnare il progetto entro il 30/06/2025." > contratto.txt

# Calcola il digest
openssl dgst -sha256 contratto.txt
openssl dgst -sha256 -hex contratto.txt

# Salva il digest in un file separato
openssl dgst -sha256 contratto.txt > contratto.sha256
cat contratto.sha256
```

### Step 1.4 — Verifica integrità dopo modifica

```bash
# Modifica minima del contratto — cambia una sola virgola
sed 's/30\/06\/2025/31\/06\/2025/' contratto.txt > contratto_modificato.txt

# Calcola il nuovo digest
openssl dgst -sha256 contratto_modificato.txt

# Confronta con il digest originale
diff <(openssl dgst -sha256 contratto.txt) <(openssl dgst -sha256 contratto_modificato.txt)
```

I due digest sono completamente diversi — qualsiasi modifica al documento è immediatamente rilevabile.

### Step 1.5 — Verifica hash di un file scaricato da Internet

Molti siti pubblicano l'hash SHA-256 dei file scaricabili per verificarne l'integrità.

```bash
# Scarica un file di test (es. dalla pagina download di OpenSSL)
curl -L -o testfile.tar.gz https://www.openssl.org/source/openssl-3.0.0.tar.gz 2>/dev/null || \
  echo "Download non disponibile — usa un file locale"

# Calcola il digest
openssl dgst -sha256 testfile.tar.gz

# Confronta con il digest pubblicato sul sito
# Se i digest coincidono → il file è integro e non alterato
```

**📝 Domanda 1:** Un sito pubblica l'hash SHA-256 di un file sulla stessa pagina da cui lo si scarica. Se un attaccante riesce a modificare sia il file che l'hash SHA-256 pubblicato, la verifica dell'integrità fallirà nel rilevare la manomissione? Come si risolve questo problema?

---

## 📋 Fase 2 — Firma digitale su un documento

La firma digitale combina **hash** (integrità) e **RSA** (autenticità).

### Step 2.1 — Setup: genera una coppia di chiavi

Se hai già le chiavi dal Lab L07, puoi riusarle. Altrimenti:

```bash
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out firma_privata.pem
openssl pkey -in firma_privata.pem -pubout -out firma_pubblica.pem
```

### Step 2.2 — Firma il documento

```bash
# Firma contratto.txt con SHA-256 + RSA
openssl dgst -sha256 -sign firma_privata.pem \
  -out contratto.sig contratto.txt

echo "Firma creata:"
ls -lh contratto.sig
xxd contratto.sig | head -5
```

Il file `contratto.sig` contiene la firma digitale — il digest SHA-256 del contratto cifrato con la chiave privata.

### Step 2.3 — Verifica la firma (chiunque con la chiave pubblica)

```bash
openssl dgst -sha256 -verify firma_pubblica.pem \
  -signature contratto.sig contratto.txt
```

Output atteso:
```
Verified OK
```

### Step 2.4 — Verifica fallisce dopo modifica del documento

```bash
# Modifica il contratto dopo la firma
echo "MODIFICA NON AUTORIZZATA" >> contratto.txt

# Tenta la verifica — deve fallire
openssl dgst -sha256 -verify firma_pubblica.pem \
  -signature contratto.sig contratto.txt
```

Output atteso:
```
Verification failure
```

Questo dimostra la proprietà di **integrità**: qualsiasi modifica al documento invalida la firma.

### Step 2.5 — Ripristina il documento e riverifica

```bash
# Ripristina il file originale (rimuovi l'ultima riga aggiunta)
head -n -1 contratto.txt > contratto_originale.txt
mv contratto_originale.txt contratto.txt

# Verifica di nuovo
openssl dgst -sha256 -verify firma_pubblica.pem \
  -signature contratto.sig contratto.txt
```

```
Verified OK
```

**📝 Domanda 2:** La firma digitale garantisce **autenticità** e **integrità** ma non **confidenzialità**. Chiunque possieda la chiave pubblica può leggere il documento firmato. Come modificheresti il processo per garantire anche la confidenzialità? Descrivi i passi.

---

## 📋 Fase 3 — Certificato X.509 self-signed

Un certificato X.509 associa una chiave pubblica a un'identità, firmato da una Certification Authority. In questo step creiamo un certificato firmato da noi stessi (self-signed).

### Step 3.1 — Genera chiave privata e certificato self-signed in un solo comando

```bash
openssl req -x509 -newkey rsa:2048 -keyout server_key.pem -out server_cert.pem \
  -sha256 -days 365 -nodes \
  -subj "/C=IT/ST=Lombardia/L=Milano/O=Prof Giagnotti Lab/CN=profgiagnotti.local"
```

**Spiegazione parametri:**

| Parametro | Significato |
|---|---|
| `req -x509` | Genera un certificato X.509 |
| `-newkey rsa:2048` | Genera anche una nuova chiave privata RSA-2048 |
| `-keyout server_key.pem` | File per la chiave privata |
| `-out server_cert.pem` | File per il certificato |
| `-sha256` | Algoritmo di firma SHA-256 |
| `-days 365` | Validità: 365 giorni |
| `-nodes` | Nessuna passphrase sulla chiave privata (no DES) |
| `-subj "..."` | Campi del certificato senza prompt interattivo |

### Step 3.2 — Ispeziona il certificato

```bash
openssl x509 -in server_cert.pem -text -noout
```

Identifica nella output:

```
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: ...         ← numero seriale univoco
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=IT, ST=Lombardia, ...    ← chi ha firmato (noi stessi)
        Validity
            Not Before: ...        ← inizio validità
            Not After:  ...        ← scadenza
        Subject: C=IT, ST=Lombardia, ...   ← a chi è intestato
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                RSA Public-Key: (2048 bit)
                Modulus: ...       ← la chiave pubblica n
                Exponent: 65537   ← e
    Signature Algorithm: sha256WithRSAEncryption
        ...                        ← firma della CA (noi stessi)
```

### Step 3.3 — Estrai informazioni specifiche

```bash
# Solo il Subject (intestatario)
openssl x509 -in server_cert.pem -subject -noout

# Solo l'Issuer (chi ha firmato)
openssl x509 -in server_cert.pem -issuer -noout

# Date di validità
openssl x509 -in server_cert.pem -dates -noout

# Fingerprint SHA-256 del certificato
openssl x509 -in server_cert.pem -fingerprint -sha256 -noout

# Solo la chiave pubblica
openssl x509 -in server_cert.pem -pubkey -noout
```

**📝 Domanda 3:** In un certificato self-signed, `Issuer` e `Subject` sono identici. Perché un browser mostra un avviso di sicurezza per i certificati self-signed ma non per quelli di un sito HTTPS normale?

---

## 📋 Fase 4 — Mini PKI locale: CA radice + certificato firmato

Questa è la struttura reale di Internet: una Root CA firma i certificati dei siti web.

### Step 4.1 — Crea la Root CA (Certification Authority)

```bash
# Genera la chiave privata della CA
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 \
  -aes-256-cbc -pass pass:CAPassword!Sicura \
  -out ca_key.pem

# Genera il certificato self-signed della Root CA (valido 10 anni)
openssl req -x509 -new -key ca_key.pem \
  -passin pass:CAPassword!Sicura \
  -sha256 -days 3650 \
  -out ca_cert.pem \
  -subj "/C=IT/ST=Lombardia/L=Milano/O=ProGiagnotti Root CA/CN=ProGiagnotti Root CA"

echo "Root CA creata:"
openssl x509 -in ca_cert.pem -subject -issuer -dates -noout
```

### Step 4.2 — Crea la richiesta di certificato per il server (CSR)

Un CSR (Certificate Signing Request) è la richiesta che un server invia alla CA per ottenere il certificato.

```bash
# Genera la chiave privata del server
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 \
  -out server2_key.pem

# Genera il CSR
openssl req -new -key server2_key.pem \
  -out server2_csr.pem \
  -subj "/C=IT/ST=Lombardia/L=Milano/O=Scuola ITIS/CN=itis.example.it"

echo "CSR generato:"
openssl req -in server2_csr.pem -text -noout | head -20
```

### Step 4.3 — La CA firma il CSR e rilascia il certificato

```bash
# Crea file di configurazione per le estensioni
cat > ext_server.cnf << EOF
[v3_req]
subjectAltName = DNS:itis.example.it, DNS:www.itis.example.it, IP:192.168.1.100
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
EOF

# La CA firma il CSR — rilascia certificato valido 1 anno
openssl x509 -req \
  -in server2_csr.pem \
  -CA ca_cert.pem -CAkey ca_key.pem \
  -passin pass:CAPassword!Sicura \
  -CAcreateserial \
  -out server2_cert.pem \
  -days 365 -sha256 \
  -extfile ext_server.cnf -extensions v3_req

echo "Certificato firmato dalla CA:"
openssl x509 -in server2_cert.pem -text -noout
```

### Step 4.4 — Verifica la catena di fiducia

```bash
# Verifica che il certificato del server sia firmato dalla nostra CA
openssl verify -CAfile ca_cert.pem server2_cert.pem
```

Output atteso:
```
server2_cert.pem: OK
```

```bash
# Visualizza Issuer e Subject — devono formare la catena corretta
echo "--- Certificato CA ---"
openssl x509 -in ca_cert.pem -subject -issuer -noout

echo "--- Certificato Server ---"
openssl x509 -in server2_cert.pem -subject -issuer -noout
```

L'Issuer del certificato server deve corrispondere al Subject della CA.

### Step 4.5 — Cosa succede con una CA sconosciuta

```bash
# Genera una CA diversa (non fidata)
openssl req -x509 -newkey rsa:2048 -keyout altra_ca_key.pem -out altra_ca_cert.pem \
  -sha256 -days 365 -nodes \
  -subj "/CN=CA non fidata"

# Tenta la verifica del certificato server con la CA sbagliata — deve fallire
openssl verify -CAfile altra_ca_cert.pem server2_cert.pem
```

Output:
```
server2_cert.pem: C = IT, ... error 20 at 0 depth lookup: unable to get local issuer certificate
```

Questo è esattamente l'errore che vedi nel browser quando visiti un sito con certificato non valido.

**📝 Domanda 4:** Descrivi la differenza tra un certificato **self-signed** e un certificato **firmato da una CA**. In quale caso useresti ciascuno?

---

## 📋 Fase 5 — Ispezione del certificato TLS di un sito reale

### Step 5.1 — Scarica e ispeziona il certificato di profgiagnotti.it

```bash
# Connessione SSL e download del certificato
openssl s_client -connect profgiagnotti.it:443 -showcerts </dev/null 2>/dev/null | \
  openssl x509 -text -noout
```

**Windows PowerShell:**
```powershell
$null | openssl s_client -connect profgiagnotti.it:443 -showcerts 2>$null | `
  openssl x509 -text -noout
```

### Step 5.2 — Estrai informazioni specifiche

```bash
# Subject e Issuer
openssl s_client -connect profgiagnotti.it:443 </dev/null 2>/dev/null | \
  openssl x509 -subject -issuer -dates -noout

# Fingerprint del certificato
openssl s_client -connect profgiagnotti.it:443 </dev/null 2>/dev/null | \
  openssl x509 -fingerprint -sha256 -noout

# Subject Alternative Names (domini coperti dal certificato)
openssl s_client -connect profgiagnotti.it:443 </dev/null 2>/dev/null | \
  openssl x509 -text -noout | grep -A2 "Subject Alternative Name"
```

### Step 5.3 — Ispeziona altri siti e confronta

```bash
# Elenco di siti da confrontare
for SITE in google.com github.com amazon.it; do
  echo "=== $SITE ==="
  openssl s_client -connect $SITE:443 </dev/null 2>/dev/null | \
    openssl x509 -subject -issuer -dates -noout
  echo ""
done
```

**📝 Domanda 5:** Analizza il certificato di almeno due siti diversi e compila questa tabella:

| Campo | Sito 1 | Sito 2 |
|---|---|---|
| Subject CN | | |
| Issuer (CA) | | |
| Algoritmo firma | | |
| Validità (giorni) | | |
| SAN (domini coperti) | | |

---

## 📋 Fase 6 — Verifica della catena di certificati TLS completa

```bash
# Mostra tutta la catena: certificato server + CA intermedie
openssl s_client -connect github.com:443 -showcerts </dev/null 2>/dev/null | \
  grep -E "subject|issuer"
```

Vedrai tipicamente tre livelli:
```
subject=CN = github.com
issuer=C = US, O = DigiCert Inc, CN = DigiCert TLS RSA SHA256 2020 CA1

subject=C = US, O = DigiCert Inc, CN = DigiCert TLS RSA SHA256 2020 CA1
issuer=C = US, O = DigiCert Inc, OU = www.digicert.com, CN = DigiCert Global Root CA

(Root CA — preinstallata nel browser)
```

Questa è esattamente la **catena di fiducia** studiata in teoria:
```
Root CA (DigiCert Global Root CA)
    └── Intermediate CA (DigiCert TLS RSA SHA256 2020 CA1)
            └── Certificato sito (github.com)
```

---

## 📋 Fase 7 — Riepilogo comandi e tabella dei file prodotti

### Comandi essenziali

```bash
# ── HASH ───────────────────────────────────────────────────────────────────
openssl dgst -sha256 file.txt              # digest SHA-256
openssl dgst -sha512 file.txt              # digest SHA-512
sha256sum file.txt                         # alternativa Linux
Get-FileHash file.txt -Algorithm SHA256    # Windows PowerShell

# ── FIRMA DIGITALE ─────────────────────────────────────────────────────────
openssl dgst -sha256 -sign privkey.pem -out doc.sig doc.txt       # firma
openssl dgst -sha256 -verify pubkey.pem -signature doc.sig doc.txt # verifica

# ── CERTIFICATI ────────────────────────────────────────────────────────────
# Self-signed
openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem \
  -sha256 -days 365 -nodes -subj "/CN=example.com"

# Genera CSR
openssl req -new -key key.pem -out csr.pem -subj "/CN=example.com"

# CA firma CSR
openssl x509 -req -in csr.pem -CA ca_cert.pem -CAkey ca_key.pem \
  -CAcreateserial -out cert.pem -days 365 -sha256

# Ispezione certificato
openssl x509 -in cert.pem -text -noout
openssl x509 -in cert.pem -subject -issuer -dates -noout
openssl x509 -in cert.pem -fingerprint -sha256 -noout

# Verifica catena
openssl verify -CAfile ca_cert.pem server_cert.pem

# Certificato da sito remoto
openssl s_client -connect example.com:443 </dev/null 2>/dev/null | \
  openssl x509 -text -noout
```

### File prodotti in questo laboratorio

| File | Contenuto |
|---|---|
| `contratto.txt` | Documento da firmare |
| `contratto.sha256` | Digest SHA-256 del documento |
| `firma_privata.pem` | Chiave privata RSA per firma |
| `firma_pubblica.pem` | Chiave pubblica RSA per verifica |
| `contratto.sig` | Firma digitale del contratto |
| `server_cert.pem` | Certificato X.509 self-signed |
| `server_key.pem` | Chiave privata del server |
| `ca_key.pem` | Chiave privata Root CA |
| `ca_cert.pem` | Certificato Root CA |
| `server2_csr.pem` | Richiesta di certificato (CSR) |
| `server2_cert.pem` | Certificato firmato dalla CA |

---

## 📋 Domande di verifica finali

1. Qual è la differenza concettuale tra **hash** e **firma digitale**? Cosa aggiunge la firma digitale rispetto al semplice hash?

2. Hai verificato che la firma digitale fallisce dopo una modifica al documento. Se invece di modificare il documento modificassi la **firma** (file `.sig`), cosa succederebbe alla verifica? Perché?

3. Nel mondo reale, le Root CA dei browser (DigiCert, Let's Encrypt, ecc.) hanno certificati self-signed — eppure il browser li accetta. Come mai? Dove vengono memorizzati questi certificati nel sistema operativo?

4. **Let's Encrypt** rilascia certificati TLS gratuiti automaticamente. Come fa a verificare che tu sia davvero il proprietario del dominio per cui richiedi il certificato? (ricerca: ACME protocol, challenge DNS/HTTP)

5. Qual è la differenza tra **revoca del certificato** (CRL/OCSP) e **scadenza**? Quando è necessario revocare un certificato prima della sua scadenza naturale?

---

## 📚 Risorse

- 📄 [NIST FIPS 180-4 — Secure Hash Standard](https://csrc.nist.gov/publications/detail/fips/180/4/final)
- 📄 [RFC 5280 — X.509 Certificate and CRL Profile](https://www.rfc-editor.org/rfc/rfc5280)
- 🌐 [Let's Encrypt — How it works](https://letsencrypt.org/how-it-works/)
- 🛠️ [OpenSSL x509 — documentazione](https://www.openssl.org/docs/man3.0/man1/openssl-x509.html)
- 🔬 [SSL Labs — test certificato sito web](https://www.ssllabs.com/ssltest/)

---

## 🔗 Risorse correlate

- 🌐 **Sito:** [profgiagnotti.it](https://profgiagnotti.it)
- ▶️ **YouTube:** [youtube.com/@profgiagnotti](https://youtube.com/@profgiagnotti)
- 💬 **Discord:** [Unisciti alla community](https://discord.gg/profgiagnotti)

---

*Materiale a scopo educativo · Licenza MIT · Prof. Giagnotti*
