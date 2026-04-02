# 🔬 Lab — Configurazione FTP con FileZilla Server e Client

![Materia](https://img.shields.io/badge/materia-Networking-3DE8A0?style=flat-square)
![Anno](https://img.shields.io/badge/anno-5-3DE8A0?style=flat-square)
![Modulo](https://img.shields.io/badge/modulo-1-3DE8A0?style=flat-square)
![Livello](https://img.shields.io/badge/livello-intermedio-FFAA3D?style=flat-square)
![OS](https://img.shields.io/badge/OS-Windows-4A9EFF?style=flat-square)

> Laboratorio pratico sul protocollo FTP — Anno 5, Modulo 1  
> 🌐 Teoria collegata: [profgiagnotti.it](https://profgiagnotti.it/corsi/networking/)

---

## 🎯 Obiettivi

Al termine di questo laboratorio sarai in grado di:

- ✅ Installare e configurare **FileZilla Server** su un PC Windows
- ✅ Creare utenti FTP con password e cartelle condivise
- ✅ Connetterti al server usando **FileZilla Client**
- ✅ Trasferire file tra client e server via protocollo FTP
- ✅ Testare l'upload di un file HTML verificandolo nel browser tramite XAMPP

---

## 🛠️ Software necessario

| Software | Funzione | Download |
|---|---|---|
| **XAMPP** | Server locale Apache (opzionale, per testare upload web) | [apachefriends.org](https://www.apachefriends.org/) |
| **FileZilla Server** | Trasforma il PC in un server FTP | [filezilla-project.org](https://filezilla-project.org/download.php?type=server) |
| **FileZilla Client** | Client per connettersi e trasferire file | [filezilla-project.org](https://filezilla-project.org/download.php) |

---

## 📋 Fase 1 — Installazione

### Step 1.1 — Installa XAMPP (opzionale)

1. Scarica e installa XAMPP
2. Avvia il pannello di controllo XAMPP
3. Clicca **Start** accanto ad **Apache**
4. Verifica che Apache sia in esecuzione navigando su `http://localhost`

> ⚠️ XAMPP è necessario solo se vuoi testare l'upload di file web nel **Test pratico finale**. Puoi saltare questo step e usare qualsiasi altra cartella come destinazione FTP.

---

### Step 1.2 — Installa e avvia FileZilla Server

1. Scarica e installa **FileZilla Server**
2. Durante l'installazione, lascia le opzioni predefinite
3. All'avvio, la console si connette automaticamente al server locale:
   - **Host:** `127.0.0.1`
   - **Porta:** `14147` (porta di amministrazione, non quella FTP)
   - **Password:** lascia vuoto (o imposta una se preferisci)
4. Clicca **Connect**

> 📌 La porta `14147` è la porta di **amministrazione** di FileZilla Server, usata solo per la console di gestione. La porta FTP vera e propria è la `21`.

---

### Step 1.3 — Installa FileZilla Client

1. Scarica e installa **FileZilla Client** sullo stesso PC o su un altro dispositivo della rete locale
2. Non è necessaria nessuna configurazione iniziale

---

## 📋 Fase 2 — Configurazione di FileZilla Server

### Step 2.1 — Crea un utente FTP

1. Nella console di FileZilla Server, vai su **Edit → Users**
2. Clicca **Add** per creare un nuovo utente
3. Inserisci il nome utente, ad esempio:
   ```
   studente
   ```
4. Spunta la casella **Password** e inserisci una password, ad esempio:
   ```
   FTP1234
   ```
5. Clicca **OK** per confermare

---

### Step 2.2 — Imposta la cartella condivisa

1. Con l'utente `studente` selezionato, vai nella sezione **Shared folders**
2. Clicca **Add** e seleziona la cartella da condividere

   Per testare con XAMPP usa:
   ```
   C:\xampp\htdocs\ftp
   ```
   > Se la cartella non esiste, creala prima tramite Esplora risorse.

   Per un test semplice senza XAMPP puoi usare qualsiasi cartella, ad esempio:
   ```
   C:\Users\TuoNome\Desktop\ftp-test
   ```

3. Imposta i permessi per l'utente:

   | Permesso | Attiva |
   |---|---|
   | `Read` — Lettura | ✅ |
   | `Write` — Scrittura | ✅ |
   | `Delete` — Cancellazione | ⬜ opzionale |
   | `Create` — Creazione cartelle | ✅ |

4. Clicca **OK** per salvare

---

### Step 2.3 — Verifica che il server sia avviato

- Controlla che nella barra di stato di FileZilla Server sia presente il messaggio:
  ```
  FileZilla Server version X.X.X ready
  ```
- Se il server non è attivo, clicca su **Server → Activate** o riavvia il servizio

---

## 📋 Fase 3 — Connessione con FileZilla Client

### Step 3.1 — Connettiti al server

1. Apri **FileZilla Client**
2. Compila la **barra di connessione rapida** in alto:

   | Campo | Valore |
   |---|---|
   | **Host** | `127.0.0.1` (stesso PC) oppure l'IP del server nella rete locale |
   | **Username** | `studente` |
   | **Password** | `FTP1234` |
   | **Porta** | `21` |

3. Clicca **Quickconnect**

---

### Step 3.2 — Verifica la connessione

Se la connessione ha successo, l'interfaccia si divide in due pannelli:

```
┌─────────────────────────┬─────────────────────────┐
│      LOCAL SITE         │      REMOTE SITE        │
│  File del PC client     │  File e cartelle del    │
│  (il tuo computer)      │  server FTP             │
└─────────────────────────┴─────────────────────────┘
```

Nel **log in alto** dovresti vedere:
```
Status:  Connecting to 127.0.0.1:21...
Status:  Connection established, waiting for welcome message...
Status:  Logged in
Status:  Directory listing of "/" successful
```

---

## 📋 Fase 4 — Trasferimento file

### Upload — dal client al server

1. Nel pannello **Local site** (sinistra), naviga fino al file che vuoi caricare
2. Trascina il file nel pannello **Remote site** (destra)
3. FileZilla apre automaticamente la connessione dati e trasferisce il file

### Download — dal server al client

1. Nel pannello **Remote site** (destra), seleziona il file da scaricare
2. Trascinalo nel pannello **Local site** (sinistra)

> 📌 FileZilla gestisce automaticamente la modalità **passiva** o **attiva** in base alla configurazione. La modalità passiva è quella consigliata perché compatibile con firewall e NAT.

---

## 📋 Fase 5 — Test pratico con XAMPP

Questo step verifica che un file caricato via FTP sia accessibile dal browser web.

1. Crea un file HTML sul tuo PC, ad esempio `test.html`, con questo contenuto:

   ```html
   <!DOCTYPE html>
   <html>
   <head><title>Test FTP</title></head>
   <body>
     <h1>Upload FTP riuscito!</h1>
     <p>Questo file è stato caricato tramite il protocollo FTP.</p>
   </body>
   </html>
   ```

2. Carica `test.html` via FileZilla Client nella cartella:
   ```
   C:\xampp\htdocs\ftp\
   ```

3. Apri il browser e naviga su:
   ```
   http://localhost/ftp/test.html
   ```

4. ✅ Se la pagina appare, l'upload via FTP è stato completato correttamente

---

## 🔍 Domande di verifica

Rispondi a queste domande per consolidare quanto appreso:

1. Qual è la differenza tra la porta `14147` e la porta `21` in questo laboratorio?
2. Perché la modalità passiva è preferita a quella attiva in presenza di un firewall?
3. Cosa succederebbe se rimuovessi il permesso `Write` dall'utente `studente`?
4. Come verificheresti con Wireshark che le credenziali FTP viaggiano in chiaro?
5. Qual è la differenza tra FTP e SFTP in termini di sicurezza?

---

## 📌 Riepilogo

| Elemento | Valore |
|---|---|
| Protocollo | FTP (File Transfer Protocol) |
| Porta controllo | `21` |
| Porta dati (passiva) | dinamica |
| Porta console FileZilla Server | `14147` |
| Utente di test | `studente` |
| Password di test | `FTP1234` |
| Cartella condivisa (XAMPP) | `C:\xampp\htdocs\ftp` |
| URL di verifica | `http://localhost/ftp/test.html` |

> ⚠️ **Sicurezza:** FTP trasmette credenziali e dati **in chiaro**. Non usarlo mai su reti pubbliche o in produzione. Usa sempre **FTPS** o **SFTP** per ambienti reali.

---

## 📚 Risorse

- 📁 [FileZilla — Documentazione ufficiale](https://filezilla-project.org/documentation.php)
- 🌐 [XAMPP — Apache Friends](https://www.apachefriends.org/)
- 📄 [RFC 959 — File Transfer Protocol](https://www.rfc-editor.org/rfc/rfc959)
- 🦊 [MDN — FTP overview](https://developer.mozilla.org/en-US/docs/Glossary/FTP)

---

## 🔗 Risorse correlate

- 🌐 **Sito:** [profgiagnotti.it](https://profgiagnotti.it)
- ▶️ **YouTube:** [youtube.com/@profgiagnotti](https://youtube.com/@profgiagnotti)
- 💬 **Discord:** [Unisciti alla community](https://discord.gg/profgiagnotti)

---

*Materiale a scopo educativo · Licenza MIT · Prof. Giagnotti*
