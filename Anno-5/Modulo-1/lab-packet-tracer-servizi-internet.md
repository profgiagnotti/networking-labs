# 🔬 Lab — Configurazione dei servizi Internet in Packet Tracer

![Materia](https://img.shields.io/badge/materia-Networking-3DE8A0?style=flat-square)
![Anno](https://img.shields.io/badge/anno-5-3DE8A0?style=flat-square)
![Modulo](https://img.shields.io/badge/modulo-1-3DE8A0?style=flat-square)
![Livello](https://img.shields.io/badge/livello-intermedio-FFAA3D?style=flat-square)
![Tool](https://img.shields.io/badge/tool-Cisco%20Packet%20Tracer-4A9EFF?style=flat-square)

> Laboratorio pratico su servizi applicativi Internet — Anno 5, Modulo 1  
> 🌐 Teoria collegata: [profgiagnotti.it — DNS, HTTP, FTP, SMTP/POP3](https://profgiagnotti.it/corsi/networking/)

---

## 🎯 Obiettivi

Al termine di questo laboratorio sarai in grado di:

- ✅ Costruire una topologia multi-rete con router, PC e server in Packet Tracer
- ✅ Configurare il **routing RIP** tra reti diverse
- ✅ Configurare un server **DHCP** su rete remota con `ip helper-address`
- ✅ Pubblicare una pagina web personalizzata tramite server **HTTP**
- ✅ Configurare il server **DNS** con record A e CNAME
- ✅ Scambiare file tra due utenti tramite server **FTP**
- ✅ Inviare e ricevere email tra due utenti tramite server **SMTP/POP3**

---

## 🛠️ Software necessario

| Software | Versione | Download |
|---|---|---|
| **Cisco Packet Tracer** | 8.x o superiore | [netacad.com](https://www.netacad.com/courses/packet-tracer) (account gratuito richiesto) |

---

## 🗺️ Scenario

Due uffici — rappresentati da **PC1** e **PC2** con i rispettivi router di frontiera (**Router O1** e **Router O2**) — sono connessi a un **Router Internet** centrale. A quest'ultimo sono collegati, su reti separate, cinque server che erogano i principali servizi Internet:

```
PC1 ─── Router O1 ─┐
                    ├─── Router Internet ─── Server DNS   (1.0.0.0/8)
PC2 ─── Router O2 ─┘         │          ─── Server DHCP  (2.0.0.0/8)
                              │          ─── Server HTTP  (3.0.0.0/8)
                              │          ─── Server FTP   (4.0.0.0/8)
                              └          ─── Server MAIL  (5.0.0.0/8)
```

---

## 📋 Piano di indirizzamento

| Dispositivo | Interfaccia | Indirizzo IP | Subnet Mask | Gateway |
|---|---|---|---|---|
| PC1 | Fa0 | 192.168.0.2 | 255.255.255.0 | 192.168.0.1 |
| PC2 | Fa0 | 192.168.1.2 | 255.255.255.0 | 192.168.1.1 |
| Server DNS | Fa0 | 1.0.0.2 | 255.0.0.0 | 1.0.0.1 |
| Server DHCP | Fa0 | 2.0.0.2 | 255.0.0.0 | 2.0.0.1 |
| Server HTTP | Fa0 | 3.0.0.2 | 255.0.0.0 | 3.0.0.1 |
| Server FTP | Fa0 | 4.0.0.2 | 255.0.0.0 | 4.0.0.1 |
| Server MAIL | Fa0 | 5.0.0.2 | 255.0.0.0 | 5.0.0.1 |
| Router O1 | verso PC1 | 192.168.0.1 | 255.255.255.0 | — |
| Router O1 | verso Internet | 50.50.50.1 | 255.0.0.0 | — |
| Router O2 | verso PC2 | 192.168.1.1 | 255.255.255.0 | — |
| Router O2 | verso Internet | 100.100.100.1 | 255.0.0.0 | — |
| Router Internet | verso Router O1 | 50.50.50.2 | 255.0.0.0 | — |
| Router Internet | verso Router O2 | 100.100.100.2 | 255.0.0.0 | — |
| Router Internet | verso Server DNS | 1.0.0.1 | 255.0.0.0 | — |
| Router Internet | verso Server DHCP | 2.0.0.1 | 255.0.0.0 | — |
| Router Internet | verso Server HTTP | 3.0.0.1 | 255.0.0.0 | — |
| Router Internet | verso Server FTP | 4.0.0.1 | 255.0.0.0 | — |
| Router Internet | verso Server MAIL | 5.0.0.1 | 255.0.0.0 | — |

> 📌 Ricordare di impostare `1.0.0.2` come **server DNS** in ciascun PC e in ciascun Server.

---

## 📋 Step 1 — Topologia e indirizzamento IP

### 1.1 — Costruisci la topologia in Packet Tracer

Inserisci nella workspace:
- 2 **PC** (Generic)
- 3 **Router** (es. Cisco 2911)
- 5 **Server** (Generic Server)
- Collega i dispositivi con i cavi appropriati:
  - Cavo **dritto** (straight-through) tra PC/Server e router
  - Cavo **seriale** o **dritto** tra router e router (dipende dalla versione PT)

### 1.2 — Configura gli indirizzi IP

Assegna gli indirizzi secondo il **piano di indirizzamento** della tabella precedente.

**PC1 e PC2** — per ora imposta manualmente (poi useremo DHCP):
```
Desktop → IP Configuration → Static
IP: 192.168.0.2 / SM: 255.255.255.0 / GW: 192.168.0.1 / DNS: 1.0.0.2
```

**Server** — clicca sul server → scheda **Config** → FastEthernet0:
```
IP: [vedi tabella] / SM: [vedi tabella] / GW: [vedi tabella]
```
Imposta anche il **DNS Server** a `1.0.0.2` in ogni server.

**Router** — CLI (Command Line Interface):
```
Router> enable
Router# configure terminal
Router(config)# interface fastethernet 0/0
Router(config-if)# ip address [IP] [SM]
Router(config-if)# no shutdown
Router(config-if)# exit
```

Ripeti per ogni interfaccia di ogni router.

### 1.3 — Configura il routing RIP

Su ogni router annuncia solo le **reti adiacenti** (reti direttamente connesse).

**Router O1:**
```
Router(config)# router rip
Router(config-router)# network 192.168.0.0
Router(config-router)# network 50.0.0.0
Router(config-router)# exit
```

**Router O2:**
```
Router(config)# router rip
Router(config-router)# network 192.168.1.0
Router(config-router)# network 100.0.0.0
Router(config-router)# exit
```

**Router Internet:**
```
Router(config)# router rip
Router(config-router)# network 50.0.0.0
Router(config-router)# network 100.0.0.0
Router(config-router)# network 1.0.0.0
Router(config-router)# network 2.0.0.0
Router(config-router)# network 3.0.0.0
Router(config-router)# network 4.0.0.0
Router(config-router)# network 5.0.0.0
Router(config-router)# exit
```

### 1.4 — Verifica la raggiungibilità

Dal PC1, apri **Desktop → Command Prompt** e testa la connettività:
```
ping 192.168.1.2    # PC2
ping 3.0.0.2        # Server HTTP
ping 4.0.0.2        # Server FTP
ping 5.0.0.2        # Server MAIL
```

Tutti i ping devono rispondere prima di procedere agli step successivi.

**📝 Domanda 1:** Perché è necessario configurare RIP su tutti e tre i router? Cosa succederebbe se non configurassimo il routing?

---

## 📋 Step 2 — Server DHCP

Il server DHCP si trova su una rete diversa dai PC. Per farlo funzionare occorrono due configurazioni: i **pool** sul server e il **relay** sui router.

### 2.1 — Configura i pool DHCP sul server

Clicca sul **Server DHCP** → **Services** → **DHCP**:

- Imposta il servizio su **ON**
- Crea il **Pool 1** per la rete di PC1:

| Campo | Valore |
|---|---|
| Pool Name | Rete_PC1 |
| Default Gateway | 192.168.0.1 |
| DNS Server | 1.0.0.2 |
| Start IP Address | 192.168.0.10 |
| Subnet Mask | 255.255.255.0 |
| Max Users | 50 |

- Clicca **Add** e poi crea il **Pool 2** per la rete di PC2:

| Campo | Valore |
|---|---|
| Pool Name | Rete_PC2 |
| Default Gateway | 192.168.1.1 |
| DNS Server | 1.0.0.2 |
| Start IP Address | 192.168.1.10 |
| Subnet Mask | 255.255.255.0 |
| Max Users | 50 |

- Clicca **Add**

### 2.2 — Configura il DHCP Relay sui router

Poiché il server DHCP è su una rete remota, i broadcast DHCP dei PC non lo raggiungono. Il comando `ip helper-address` instrucisce il router a inoltrarli come unicast verso il server DHCP.

**Su Router O1** — interfaccia verso PC1:
```
Router(config)# interface fastethernet 0/0
Router(config-if)# ip helper-address 2.0.0.2
Router(config-if)# exit
```

**Su Router O2** — interfaccia verso PC2:
```
Router(config)# interface fastethernet 0/0
Router(config-if)# ip helper-address 2.0.0.2
Router(config-if)# exit
```

### 2.3 — Attiva DHCP sui PC

Su ogni PC: **Desktop → IP Configuration → DHCP**

I PC dovrebbero ricevere automaticamente:
- Indirizzo IP dalla rete corretta
- Gateway del router di frontiera
- DNS Server `1.0.0.2`

**📝 Domanda 2:** Cos'è il comando `ip helper-address` e perché è necessario? Quale tipo di traffico viene inoltrato dal router al server DHCP?

---

## 📋 Step 3 — Server HTTP

### 3.1 — Configura il server HTTP

Clicca sul **Server HTTP** → **Services** → **HTTP**:
- Imposta il servizio su **ON**
- Clicca su `index.html` → **Edit**
- Modifica il contenuto della pagina, ad esempio:

```html
<!DOCTYPE html>
<html>
<head><title>Sistemi e Reti - Lab</title></head>
<body>
  <h1>Benvenuto nel server HTTP del laboratorio</h1>
  <p>Configurato con successo da Packet Tracer.</p>
</body>
</html>
```

- Clicca **Save**

### 3.2 — Testa il servizio HTTP

Da **PC1**: **Desktop → Web Browser**

Digita nella barra degli indirizzi: `3.0.0.2`

La pagina modificata deve apparire nel browser.

Ripeti il test da **PC2**.

**📝 Domanda 3:** Quale protocollo e quale porta vengono usati per la comunicazione tra browser e server HTTP? Prova a catturare il traffico in Packet Tracer (modalità simulazione) e identifica il pacchetto HTTP GET.

---

## 📋 Step 4 — Server DNS

### 4.1 — Configura il server DNS

Clicca sul **Server DNS** → **Services** → **DNS**:
- Imposta il servizio su **ON**
- Aggiungi i seguenti record:

**Record A — Server HTTP:**

| Campo | Valore |
|---|---|
| Name | www.sistemi.it |
| Type | A Record |
| Address | 3.0.0.2 |

Clicca **Add**.

**Record CNAME — alias per HTTP:**

| Campo | Valore |
|---|---|
| Name | sistemi |
| Type | CNAME |
| Host Name | www.sistemi.it |

Clicca **Add**.

**Record A — Server FTP:**

| Campo | Valore |
|---|---|
| Name | www.myftp.it |
| Type | A Record |
| Address | 4.0.0.2 |

Clicca **Add**.

**Record A — Server MAIL:**

| Campo | Valore |
|---|---|
| Name | www.mail.it |
| Type | A Record |
| Address | 5.0.0.2 |

Clicca **Add**.

**Record CNAME — alias per MAIL:**

| Campo | Valore |
|---|---|
| Name | mail.it |
| Type | CNAME |
| Host Name | www.mail.it |

Clicca **Add**.

### 4.2 — Testa la risoluzione DNS

Da **PC1**: **Desktop → Web Browser**

- Digita `www.sistemi.it` → deve aprire la pagina del server HTTP
- Digita `sistemi` → deve funzionare tramite l'alias CNAME

Da **PC2**: ripeti gli stessi test.

**📝 Domanda 4:** Qual è la differenza tra un record DNS di tipo **A** e un record di tipo **CNAME**? Fai un esempio reale di utilizzo del CNAME.

---

## 📋 Step 5 — Server FTP

### 5.1 — Configura il server FTP

Clicca sul **Server FTP** → **Services** → **FTP**:
- Imposta il servizio su **ON**
- Aggiungi due utenti con tutti i permessi attivi (Read, Write, Delete, Rename, List):

| Username | Password | Permessi |
|---|---|---|
| alice | alice123 | ✅ Read ✅ Write ✅ Delete ✅ Rename ✅ List |
| bob | bob123 | ✅ Read ✅ Write ✅ Delete ✅ Rename ✅ List |

Clicca **+** dopo aver inserito ogni utente.

### 5.2 — Testa la connessione FTP via IP

Da **PC1**: **Desktop → Command Prompt**

```
ftp 4.0.0.2
```

Inserisci username e password. Il prompt cambia in `ftp>`.

Comandi FTP utili:

| Comando | Funzione |
|---|---|
| `dir` | Elenca i file presenti sul server |
| `put nomefile.txt` | Carica un file dal PC al server |
| `get nomefile.txt` | Scarica un file dal server al PC |
| `quit` | Chiude la connessione FTP |

### 5.3 — Testa la connessione FTP via nome DNS

```
ftp www.myftp.it
```

Inserisci username e password di alice.

### 5.4 — Scambio file tra Alice e Bob

**Alice crea un file:**

1. Vai su **PC1** → **Desktop → Text Editor**
2. Scrivi: `Ciao, sono Alice. Questo è il mio file.`
3. **File → Save** — salva come `AliceFile.txt`
4. Verifica dal **Command Prompt**:
   ```
   dir
   ```
   Dovresti vedere `AliceFile.txt` nella lista.

**Alice carica il file sul server FTP:**

```
ftp www.myftp.it
[username: alice / password: alice123]
ftp> put AliceFile.txt
ftp> dir
ftp> quit
```

Verifica che `AliceFile.txt` compaia nella lista del server.

**Bob scarica il file dal server FTP:**

Da **PC2** → **Desktop → Command Prompt**:

```
ftp www.myftp.it
[username: bob / password: bob123]
ftp> dir
ftp> get AliceFile.txt
ftp> quit
dir
```

**Bob legge il file:**

**Desktop → Text Editor → File → Open → AliceFile.txt → OK**

**📝 Domanda 5:** FTP trasmette credenziali e file **in chiaro**. Con Wireshark (o la modalità simulazione di Packet Tracer) potresti vedere username e password nel traffico. Quale alternativa sicura esiste e su quale porta opera?

---

## 📋 Step 6 — Server MAIL (SMTP + POP3)

### 6.1 — Configura il server Mail

Clicca sul **Server MAIL** → **Services** → **Email**:
- Attiva **SMTP** su **ON**
- Attiva **POP3** su **ON**
- Nel campo **Domain Name** scrivi: `mail.it` → clicca **SET**
- Aggiungi i due account utente:

| User | Password |
|---|---|
| alice | alice123 |
| bob | bob123 |

Clicca **+** per aggiungere ogni utente.

### 6.2 — Configura i client di posta sui PC

**PC1 (Alice)** — **Desktop → Email → Configure Mail**:

| Campo | Valore |
|---|---|
| Your Name | Alice |
| Email Address | alice@mail.it |
| Incoming Mail Server | mail.it |
| Outgoing Mail Server | mail.it |
| User Name | alice |
| Password | alice123 |

Clicca **Save**.

**PC2 (Bob)** — **Desktop → Email → Configure Mail**:

| Campo | Valore |
|---|---|
| Your Name | Bob |
| Email Address | bob@mail.it |
| Incoming Mail Server | mail.it |
| Outgoing Mail Server | mail.it |
| User Name | bob |
| Password | bob123 |

Clicca **Save**.

### 6.3 — Invia una email da Alice a Bob

Da **PC1** → **Desktop → Email**:
1. Clicca **Compose**
2. Compila i campi:
   - **To:** `bob@mail.it`
   - **Subject:** `Saluti da Alice`
   - **Body:** `Ciao Bob, ti mando questa email di test. Alice`
3. Clicca **Send**

Se il servizio funziona, Packet Tracer mostrerà un avviso di invio riuscito nella barra inferiore.

### 6.4 — Bob riceve e risponde

Da **PC2** → **Desktop → Email**:
1. Clicca **Receive**
2. Clicca sul messaggio ricevuto per leggerlo
3. Clicca **Reply**
4. Scrivi una risposta e clicca **Send**

Da **PC1** → **Desktop → Email → Receive**: visualizza la risposta di Bob.

**📝 Domanda 6:** In questo laboratorio abbiamo usato un unico server per SMTP e POP3. In un'infrastruttura reale (es. Gmail) questi ruoli sono spesso separati su macchine diverse. Qual è la differenza tra **SMTP** e **POP3**? Quando useresti **IMAP** al posto di POP3?

---

## 📋 Step 7 — Verifica finale completa

Esegui tutti i test seguenti e registra i risultati nella tabella:

| Test | Da | Verso | Metodo | Risultato |
|---|---|---|---|---|
| Ping | PC1 | PC2 | `ping 192.168.1.x` | ✅ / ❌ |
| Ping | PC1 | Server HTTP | `ping 3.0.0.2` | ✅ / ❌ |
| HTTP via IP | PC1 | Server HTTP | Browser `3.0.0.2` | ✅ / ❌ |
| HTTP via nome | PC2 | Server HTTP | Browser `www.sistemi.it` | ✅ / ❌ |
| HTTP via alias | PC1 | Server HTTP | Browser `sistemi` | ✅ / ❌ |
| FTP via IP | PC1 | Server FTP | `ftp 4.0.0.2` | ✅ / ❌ |
| FTP via nome | PC2 | Server FTP | `ftp www.myftp.it` | ✅ / ❌ |
| Upload file | PC1 | Server FTP | `ftp> put AliceFile.txt` | ✅ / ❌ |
| Download file | PC2 | Server FTP | `ftp> get AliceFile.txt` | ✅ / ❌ |
| Email Alice→Bob | PC1 | PC2 | Email → Compose → Send | ✅ / ❌ |
| Email Bob→Alice | PC2 | PC1 | Reply → Send | ✅ / ❌ |

---

## 📋 Domande di verifica finali

1. Il comando `ip helper-address` è fondamentale per il funzionamento di DHCP su reti diverse. Spiega il flusso completo di un messaggio DHCP DISCOVER dal PC fino al server e ritorno.

2. Nel piano di indirizzamento abbiamo usato reti di classe A (`1.0.0.0/8`, `2.0.0.0/8`, ecc.) per i server. In un'infrastruttura reale queste reti sarebbero pubbliche o private? Cosa cambierebbe usando `10.0.x.0/24`?

3. Descrivi la sequenza di operazioni che avviene quando PC1 naviga su `www.sistemi.it`:
   - Quale protocollo viene usato per primo?
   - Quale server viene contattato per primo?
   - Come arriva la risposta al browser?

4. FTP usa due connessioni TCP separate (porta 21 per il controllo, porta 20 o dinamica per i dati). In Packet Tracer, quando esegui `put AliceFile.txt`, quante connessioni TCP sono attive contemporaneamente?

5. Nella configurazione del server Mail abbiamo usato `mail.it` come **Domain Name**. Perché le email hanno il formato `utente@dominio` e non `utente@IP`? Quale record DNS permette questa associazione?

---

## 📌 Riepilogo comandi CLI router

```
! Configurazione interfaccia
enable
configure terminal
interface fastethernet 0/0
ip address [IP] [SUBNET_MASK]
no shutdown
exit

! DHCP Relay
interface fastethernet 0/0
ip helper-address 2.0.0.2
exit

! Routing RIP
router rip
network [rete_adiacente_1]
network [rete_adiacente_2]
exit

! Verifica
show ip route
show ip interface brief
ping [IP_destinazione]
```

## 📌 Riepilogo comandi FTP da prompt

```
ftp [IP o nome]       # Connessione al server FTP
dir                   # Lista file sul server
put nomefile.txt      # Upload: PC → Server
get nomefile.txt      # Download: Server → PC
quit                  # Disconnessione
dir                   # Lista file locali (dopo quit)
```

---

## 📚 Risorse

- 📄 [Cisco Packet Tracer — Guida utente](https://www.netacad.com/courses/packet-tracer)
- 🌐 Teoria DNS → Lezione L07 — DNS: struttura, risoluzione, record
- 🌐 Teoria HTTP → Lezione L03 — Il protocollo HTTP
- 🌐 Teoria FTP → Lezione L10 — FTP, RTP e riepilogo protocolli
- 🌐 Teoria Email → Lezione L09 — Posta elettronica: SMTP, POP3, IMAP, MIME

---

## 🔗 Risorse correlate

- 🌐 **Sito:** [profgiagnotti.it](https://profgiagnotti.it)
- ▶️ **YouTube:** [youtube.com/@profgiagnotti](https://youtube.com/@profgiagnotti)
- 💬 **Discord:** [Unisciti alla community](https://discord.gg/profgiagnotti)

---

*Materiale a scopo educativo · Licenza MIT · Prof. Giagnotti*
