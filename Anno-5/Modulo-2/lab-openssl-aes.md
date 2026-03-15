# 🔬 Lab — Cifratura simmetrica AES con OpenSSL

![Materia](https://img.shields.io/badge/materia-Networking-3DE8A0?style=flat-square)
![Anno](https://img.shields.io/badge/anno-5-3DE8A0?style=flat-square)
![Modulo](https://img.shields.io/badge/modulo-2-3DE8A0?style=flat-square)
![Livello](https://img.shields.io/badge/livello-intermedio-FFAA3D?style=flat-square)
![OS](https://img.shields.io/badge/OS-Windows%20%7C%20Linux%20%7C%20macOS-4A9EFF?style=flat-square)

> Laboratorio pratico su cifratura simmetrica AES — Anno 5, Modulo 2  
> 🌐 Teoria collegata: [profgiagnotti.it — L06 Crittografia simmetrica: DES, 3DES, AES](https://profgiagnotti.it/corsi/networking/)

---

## 🎯 Obiettivi

Al termine di questo laboratorio sarai in grado di:

- ✅ Usare **OpenSSL** da riga di comando per cifrare e decifrare file
- ✅ Applicare **AES-256-CBC** e confrontarlo con **AES-128-CBC**
- ✅ Comprendere il ruolo della **chiave** e dell'**IV** (Initialization Vector)
- ✅ Verificare l'**effetto valanga**: una piccola modifica al testo produce un crittogramma completamente diverso
- ✅ Confrontare le dimensioni e i tempi di cifratura tra AES-128 e AES-256
- ✅ Cifrare e decifrare usando **chiave esadecimale esplicita** invece di password

---

## 🛠️ Software necessario

| Software | Funzione | Note |
|---|---|---|
| **OpenSSL** | Toolkit crittografico | Preinstallato su Linux/macOS. Su Windows: vedi Step 1 |
| **Terminale / Prompt** | Esecuzione comandi | PowerShell su Windows, Bash su Linux/macOS |

---

## 📋 Fase 1 — Installazione e verifica OpenSSL

### Step 1.1 — Verifica se OpenSSL è già installato

```bash
openssl version
```

Output atteso:
```
OpenSSL 3.x.x  (o versione simile)
```

### Step 1.2 — Installazione (se non presente)

**Windows:**
```
Scarica l'installer da: https://slproweb.com/products/Win32OpenSSL.html
Scegli: Win64 OpenSSL v3.x.x Light
Dopo l'installazione, aggiungi il percorso bin alle variabili PATH
Riavvia il terminale e verifica: openssl version
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update && sudo apt install openssl
```

**macOS:**
```bash
brew install openssl
echo 'export PATH="/opt/homebrew/opt/openssl/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Step 1.3 — Elenca gli algoritmi disponibili

```bash
openssl enc -list
```

Cerca nella lista: `aes-128-cbc`, `aes-192-cbc`, `aes-256-cbc`, `aes-256-gcm`.

---

## 📋 Fase 2 — Prima cifratura AES-256-CBC

### Step 2.1 — Crea il file di testo da cifrare

```bash
echo "Questo è un messaggio segreto di test per il laboratorio AES." > messaggio.txt
cat messaggio.txt
```

### Step 2.2 — Cifra con AES-256-CBC

```bash
openssl enc -aes-256-cbc -salt -pbkdf2 -in messaggio.txt -out messaggio.enc
```

Il sistema chiede una password:
```
enter AES-256-CBC encryption password: [inserisci una password, es. Lab2024!]
Verifying - enter AES-256-CBC encryption password: [reinserisci]
```

**Spiegazione dei parametri:**

| Parametro | Significato |
|---|---|
| `enc` | Modalità cifratura/decifratura |
| `-aes-256-cbc` | Algoritmo: AES con chiave 256 bit, modalità CBC |
| `-salt` | Aggiunge un salt casuale — rende ogni cifratura diversa anche con la stessa password |
| `-pbkdf2` | Deriva la chiave dalla password con PBKDF2 (più sicuro di `-md md5`) |
| `-in messaggio.txt` | File di input |
| `-out messaggio.enc` | File di output cifrato |

### Step 2.3 — Visualizza il file cifrato

```bash
# Mostra il file cifrato in formato esadecimale
xxd messaggio.enc | head -20

# Oppure prova a leggerlo come testo — vedrai caratteri incomprensibili
cat messaggio.enc
```

Noterai che il file cifrato non rivela nulla del contenuto originale.

### Step 2.4 — Decifra il file

```bash
openssl enc -aes-256-cbc -d -pbkdf2 -in messaggio.enc -out messaggio_decifrato.txt
```

Il parametro `-d` indica la decifratura. Inserisci la stessa password usata prima.

```bash
cat messaggio_decifrato.txt
```

Verifica che il contenuto coincida con `messaggio.txt`.

**📝 Domanda 1:** Il file `messaggio.enc` è più grande, uguale o più piccolo di `messaggio.txt`? Perché? (suggerimento: pensa al padding AES e all'header `Salted__`)

---

## 📋 Fase 3 — Effetto valanga

Questo esperimento dimostra una proprietà fondamentale di AES: una minima variazione nell'input produce un output completamente diverso.

### Step 3.1 — Crea due file quasi identici

```bash
echo "Il numero segreto è: 1234" > testo_A.txt
echo "Il numero segreto è: 1235" > testo_B.txt
```

La differenza è **un solo carattere**: `4` vs `5`.

### Step 3.2 — Cifra entrambi con la stessa password e lo stesso IV

Per confrontare correttamente usiamo una chiave e un IV espliciti (così il salt non introduce variabilità):

```bash
openssl enc -aes-256-cbc \
  -K 0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF \
  -iv 0123456789ABCDEF0123456789ABCDEF \
  -in testo_A.txt -out cifrato_A.bin -nosalt

openssl enc -aes-256-cbc \
  -K 0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF \
  -iv 0123456789ABCDEF0123456789ABCDEF \
  -in testo_B.txt -out cifrato_B.bin -nosalt
```

> **Nota:** `-K` accetta la chiave in esadecimale (256 bit = 64 caratteri hex). `-iv` accetta l'IV in esadecimale (128 bit = 32 caratteri hex).

### Step 3.3 — Confronta i due crittogrammi

```bash
xxd cifrato_A.bin
xxd cifrato_B.bin
```

Oppure usa il diff esadecimale:
```bash
diff <(xxd cifrato_A.bin) <(xxd cifrato_B.bin)
```

**Osservazione attesa:** nonostante i testi differiscano di un solo carattere, i due crittogrammi sono completamente diversi — nessun byte in comune.

**📝 Domanda 2:** Questo è l'**effetto valanga** (avalanche effect). A quale principio di Shannon corrisponde? Come protegge da un attacco statistico?

---

## 📋 Fase 4 — AES-128 vs AES-256: dimensione e tempo

### Step 4.1 — Crea un file di test di grandi dimensioni

```bash
# Genera 10 MB di dati casuali
dd if=/dev/urandom of=file_grande.bin bs=1M count=10

# Verifica dimensione
ls -lh file_grande.bin
```

**Windows (PowerShell):**
```powershell
$bytes = New-Object byte[] (10 * 1024 * 1024)
[System.Random]::new().NextBytes($bytes)
[System.IO.File]::WriteAllBytes("file_grande.bin", $bytes)
```

### Step 4.2 — Misura il tempo di cifratura AES-128 vs AES-256

**Linux/macOS:**
```bash
# AES-128-CBC
time openssl enc -aes-128-cbc -salt -pbkdf2 \
  -in file_grande.bin -out cifrato_128.bin -pass pass:TestLab2024

# AES-256-CBC
time openssl enc -aes-256-cbc -salt -pbkdf2 \
  -in file_grande.bin -out cifrato_256.bin -pass pass:TestLab2024
```

**Windows (PowerShell):**
```powershell
Measure-Command { openssl enc -aes-128-cbc -salt -pbkdf2 -in file_grande.bin -out cifrato_128.bin -pass pass:TestLab2024 }
Measure-Command { openssl enc -aes-256-cbc -salt -pbkdf2 -in file_grande.bin -out cifrato_256.bin -pass pass:TestLab2024 }
```

### Step 4.3 — Confronta i risultati

Compila questa tabella con i tuoi risultati:

| Parametro | AES-128-CBC | AES-256-CBC |
|---|---|---|
| Dimensione chiave | 128 bit | 256 bit |
| Round AES | 10 | 14 |
| Tempo cifratura (10 MB) | ___ ms | ___ ms |
| Dimensione file cifrato | ___ MB | ___ MB |

### Step 4.4 — Benchmark di OpenSSL

OpenSSL ha uno strumento di benchmark integrato:
```bash
openssl speed aes-128-cbc aes-256-cbc
```

Output esempio:
```
Doing aes-128-cbc for 3s on 16 size blocks...
Doing aes-256-cbc for 3s on 16 size blocks...
...
             16 bytes     64 bytes    256 bytes   1024 bytes   8192 bytes
aes-128-cbc 1234567.89k  2345678.90k ...
aes-256-cbc  987654.32k  1876543.21k ...
```

**📝 Domanda 3:** AES-256 è più lento di AES-128. In quale contesto sceglieresti AES-256 nonostante il costo computazionale aggiuntivo?

---

## 📋 Fase 5 — Modalità CBC e ruolo dell'IV

La modalità **CBC** (Cipher Block Chaining) concatena i blocchi: ogni blocco viene XOR-ato con il crittogramma del blocco precedente prima di essere cifrato. Il primo blocco viene XOR-ato con l'**IV** (Initialization Vector).

### Step 5.1 — Stessa chiave, IV diverso → crittogramma diverso

```bash
# Cifratura con IV = 00000...0
openssl enc -aes-256-cbc \
  -K 0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF \
  -iv 00000000000000000000000000000000 \
  -in messaggio.txt -out cifrato_iv_zero.bin -nosalt

# Cifratura con IV = FFFFF...F
openssl enc -aes-256-cbc \
  -K 0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF \
  -iv FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF \
  -in messaggio.txt -out cifrato_iv_fff.bin -nosalt
```

```bash
# Confronta i due output
xxd cifrato_iv_zero.bin
xxd cifrato_iv_fff.bin
```

I due crittogrammi sono completamente diversi pur avendo stesso testo e stessa chiave.

### Step 5.2 — Pericolo del riuso dell'IV

Questo esperimento dimostra perché riusare lo stesso IV con la stessa chiave è pericoloso:

```bash
echo "Testo uno aaaaaaa" > testo1.txt
echo "Testo due bbbbbbb" > testo2.txt

# Stessa chiave, stesso IV per entrambi — SBAGLIATO in produzione!
openssl enc -aes-256-cbc \
  -K AABBCCDDEEFF00112233445566778899AABBCCDDEEFF00112233445566778899 \
  -iv AABBCCDDEEFF00112233445566778899 \
  -in testo1.txt -out enc1.bin -nosalt

openssl enc -aes-256-cbc \
  -K AABBCCDDEEFF00112233445566778899AABBCCDDEEFF00112233445566778899 \
  -iv AABBCCDDEEFF00112233445566778899 \
  -in testo2.txt -out enc2.bin -nosalt

# XOR dei due crittogrammi — rivela informazioni sui plaintext!
python3 -c "
a = open('enc1.bin','rb').read()
b = open('enc2.bin','rb').read()
xor = bytes(x^y for x,y in zip(a,b))
print('XOR dei crittogrammi:', xor.hex())
print('XOR dei plaintext:   ', bytes(x^y for x,y in zip(open('testo1.txt','rb').read(), open('testo2.txt','rb').read())).hex())
"
```

**📝 Domanda 4:** Perché in TLS/HTTPS viene generato un IV casuale nuovo per ogni messaggio? Cosa succede se si riusa sempre lo stesso IV?

---

## 📋 Fase 6 — Cifratura di un file reale e verifica dell'integrità

In questo esercizio cifriamo un file reale (immagine o PDF) e verifichiamo che la decifratura restituisca esattamente il file originale.

### Step 6.1 — Prepara un file da cifrare

Usa qualsiasi file: un'immagine `.jpg`, un `.pdf`, un `.docx`.
```bash
# Oppure scarica un file di test
curl -o test.jpg https://www.w3schools.com/css/img_5terre.jpg
ls -lh test.jpg
```

### Step 6.2 — Calcola l'hash SHA-256 dell'originale

```bash
# Linux/macOS
sha256sum test.jpg

# Windows PowerShell
Get-FileHash test.jpg -Algorithm SHA256
```

Annota il digest. Es: `a3f8c2...`

### Step 6.3 — Cifra il file

```bash
openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 \
  -in test.jpg -out test.jpg.enc \
  -pass pass:PasswordSicura!2024
```

Il parametro `-iter 100000` aumenta le iterazioni PBKDF2 rendendo più difficile un attacco brute force sulla password.

### Step 6.4 — Decifra e verifica l'integrità

```bash
openssl enc -aes-256-cbc -d -pbkdf2 -iter 100000 \
  -in test.jpg.enc -out test_decifrato.jpg \
  -pass pass:PasswordSicura!2024

# Verifica integrità
sha256sum test.jpg
sha256sum test_decifrato.jpg
```

I due digest SHA-256 devono essere **identici** — questa è la verifica dell'integrità crittografica.

**📝 Domanda 5:** Cosa succederebbe all'hash SHA-256 di `test_decifrato.jpg` se durante la trasmissione di `test.jpg.enc` un singolo byte fosse stato modificato (accidentalmente o da un attaccante)?

---

## 📋 Fase 7 — Modalità GCM: autenticazione integrata

AES-GCM (Galois/Counter Mode) è una modalità **authenticated encryption**: cifra i dati **e** garantisce la loro integrità in una sola operazione, senza bisogno di un hash separato.

```bash
# Cifratura AES-256-GCM
openssl enc -aes-256-gcm \
  -K 0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF \
  -iv 0123456789ABCDEF01234567 \
  -in messaggio.txt -out cifrato_gcm.bin -nosalt

# Decifratura AES-256-GCM
openssl enc -aes-256-gcm -d \
  -K 0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF \
  -iv 0123456789ABCDEF01234567 \
  -in cifrato_gcm.bin -out decifrato_gcm.txt -nosalt

cat decifrato_gcm.txt
```

> **Nota:** L'IV di GCM è 96 bit (24 caratteri hex) invece di 128 bit di CBC.

**📝 Domanda 6:** In quali contesti è preferibile AES-GCM rispetto a AES-CBC? (suggerimento: pensa a TLS 1.3 e alla gestione dell'integrità)

---

## 📋 Fase 8 — Riepilogo comandi e tabella confronto

### Comandi essenziali

```bash
# Cifratura standard (consigliata)
openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 -in INPUT -out OUTPUT.enc

# Decifratura standard
openssl enc -aes-256-cbc -d -pbkdf2 -iter 100000 -in INPUT.enc -out OUTPUT

# Cifratura con chiave hex esplicita (no password)
openssl enc -aes-256-cbc -K [64 caratteri hex] -iv [32 caratteri hex] -in INPUT -out OUTPUT -nosalt

# Generare chiave casuale 256 bit (hex)
openssl rand -hex 32

# Generare IV casuale 128 bit (hex)
openssl rand -hex 16

# Benchmark
openssl speed aes-128-cbc aes-256-cbc aes-256-gcm

# Visualizza file binario in hex
xxd file.bin | head -20
```

### Tabella riepilogativa — quando usare quale variante AES

| Variante | Chiave | Round | Uso consigliato |
|---|---|---|---|
| AES-128-CBC | 128 bit | 10 | Uso generale, buone performance |
| AES-256-CBC | 256 bit | 14 | Dati sensibili, requisiti normativi |
| AES-256-GCM | 256 bit | 14 | TLS 1.3, autenticazione integrata |
| AES-256-CTR | 256 bit | 14 | Streaming, cifratura parallela |

---

## 📋 Domande di verifica finali

1. Hai cifrato lo stesso messaggio due volte con la stessa password ma `-salt`. I due file `.enc` sono identici? Perché?

2. Cosa contiene esattamente il file `.enc` generato con `-salt`? (suggerimento: esegui `xxd messaggio.enc | head -2` e osserva i primi 8 byte)

3. Un collega ti dice: "Per sicurezza, uso sempre la stessa chiave AES-256 e lo stesso IV per tutti i file che cifro". Spiega perché questa pratica è pericolosa.

4. Qual è la differenza concettuale tra **cifratura** (confidenzialità) e **hashing** (integrità)? Perché AES-GCM li combina entrambi?

5. In produzione, come si gestisce il problema della distribuzione sicura della chiave AES condivisa? (collegamento alla L07 — RSA e sistemi ibridi)

---

## 📚 Risorse

- 📄 [NIST FIPS 197 — Advanced Encryption Standard](https://csrc.nist.gov/publications/detail/fips/197/final)
- 🛠️ [OpenSSL enc — documentazione ufficiale](https://www.openssl.org/docs/man3.0/man1/openssl-enc.html)
- 🛠️ [OpenSSL speed — benchmark](https://www.openssl.org/docs/man3.0/man1/openssl-speed.html)
- 🔬 [CrypTool Online — AES step-by-step](https://www.cryptool.org/en/cto/aes-step-by-step)

---

## 🔗 Risorse correlate

- 🌐 **Sito:** [profgiagnotti.it](https://profgiagnotti.it)
- ▶️ **YouTube:** [youtube.com/@profgiagnotti](https://youtube.com/@profgiagnotti)
- 💬 **Discord:** [Unisciti alla community](https://discord.gg/profgiagnotti)

---

*Materiale a scopo educativo · Licenza MIT · Prof. Giagnotti*
