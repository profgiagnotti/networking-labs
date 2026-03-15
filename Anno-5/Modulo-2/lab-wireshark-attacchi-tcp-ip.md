# 🔬 Lab — Analisi del traffico di rete e attacchi TCP/IP con Wireshark

![Materia](https://img.shields.io/badge/materia-Networking-3DE8A0?style=flat-square)
![Anno](https://img.shields.io/badge/anno-5-3DE8A0?style=flat-square)
![Modulo](https://img.shields.io/badge/modulo-2-3DE8A0?style=flat-square)
![Livello](https://img.shields.io/badge/livello-intermedio-FFAA3D?style=flat-square)
![OS](https://img.shields.io/badge/OS-Windows%20%7C%20Linux-4A9EFF?style=flat-square)

> Laboratorio pratico su analisi del traffico e rilevamento di attacchi TCP/IP — Anno 5, Modulo 2  
> 🌐 Teoria collegata: [profgiagnotti.it — L02 Minacce, vulnerabilità e attacchi](https://profgiagnotti.it/corsi/networking/)

---

## 🎯 Obiettivi

Al termine di questo laboratorio sarai in grado di:

- ✅ Catturare e analizzare traffico di rete con Wireshark
- ✅ Riconoscere il three-way handshake TCP nei log di rete
- ✅ Identificare le tracce di un attacco **SYN Flood** analizzando i pacchetti
- ✅ Osservare le caratteristiche di un attacco **Man in the Middle (ARP Poisoning)**
- ✅ Applicare filtri Wireshark per isolare traffico specifico
- ✅ Collegare le osservazioni pratiche ai principi della CIA Triad

---

## 🛠️ Software necessario

| Software | Funzione | Download |
|---|---|---|
| **Wireshark** | Analizzatore di pacchetti di rete | [wireshark.org](https://www.wireshark.org/download.html) |
| **nmap** | Port scanner per simulare ricognizione attiva | [nmap.org](https://nmap.org/download.html) |
| **hping3** | Tool per generare pacchetti TCP/IP personalizzati (solo Linux) | preinstallato su Kali Linux |
| **Kali Linux** (opzionale) | VM con tutti gli strumenti di sicurezza preinstallati | [kali.org](https://www.kali.org/get-kali/) |

> ⚠️ **Nota legale**: tutti gli esercizi vanno eseguiti **esclusivamente su reti locali di laboratorio o macchine virtuali di proprietà**. Eseguire scansioni o attacchi su reti non autorizzate è reato penale in Italia (art. 615-ter c.p.).

---

## 📋 Fase 1 — Installazione e configurazione di Wireshark

### Step 1.1 — Installazione

**Windows:**
1. Scarica il programma di installazione da [wireshark.org](https://www.wireshark.org/download.html)
2. Durante l'installazione, accetta l'installazione di **Npcap** (driver necessario per la cattura)
3. Avvia Wireshark — vedrai l'elenco delle interfacce di rete disponibili

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install wireshark
sudo usermod -aG wireshark $USER
# Esci e rientra per applicare il gruppo
```

**Kali Linux:** Wireshark è già preinstallato.

---

### Step 1.2 — Prima cattura

1. Apri Wireshark
2. Seleziona l'interfaccia attiva (quella con traffico visibile nella preview)
3. Clicca sull'icona **Start capturing** (squalo blu in alto a sinistra)
4. Apri un browser e naviga su `http://neverssl.com` (sito HTTP non cifrato, utile per i test)
5. Torna su Wireshark e clicca **Stop** (quadrato rosso)

Vedrai centinaia di pacchetti catturati. Non preoccuparti — impareremo a filtrarli.

---

### Step 1.3 — Filtri Wireshark fondamentali

I filtri si inseriscono nella barra verde in alto. Premi Invio per applicare.

| Filtro | Cosa mostra |
|---|---|
| `tcp` | Solo traffico TCP |
| `udp` | Solo traffico UDP |
| `http` | Solo richieste e risposte HTTP |
| `dns` | Solo query DNS |
| `ip.addr == 192.168.1.1` | Traffico da/verso un IP specifico |
| `ip.src == 192.168.1.1` | Solo traffico proveniente da quell'IP |
| `tcp.port == 80` | Traffico sulla porta 80 |
| `tcp.flags.syn == 1` | Solo pacchetti con flag SYN attivo |
| `tcp.flags.syn == 1 && tcp.flags.ack == 0` | Solo SYN puri (non SYN-ACK) |
| `arp` | Solo pacchetti ARP |

---

## 📋 Fase 2 — Analisi del Three-Way Handshake TCP

Il three-way handshake è la base del protocollo TCP e la premessa per capire gli attacchi SYN Flood.

### Step 2.1 — Cattura di una connessione TCP

1. Avvia la cattura su Wireshark
2. Apri il terminale e digita:
   ```
   curl http://neverssl.com
   ```
3. Ferma la cattura
4. Applica il filtro: `tcp && ip.addr == [IP_di_neverssl.com]`

   Per trovare l'IP: `nslookup neverssl.com`

### Step 2.2 — Identifica il three-way handshake

Cerca i tre pacchetti iniziali della connessione:

```
Client → Server:  SYN              [SEQ=x, ACK=0]
Server → Client:  SYN, ACK         [SEQ=y, ACK=x+1]
Client → Server:  ACK              [SEQ=x+1, ACK=y+1]
--- connessione stabilita ---
Client → Server:  HTTP GET /
Server → Client:  HTTP 200 OK + body
Client → Server:  FIN, ACK         (chiusura connessione)
```

### Step 2.3 — Analisi dei flag TCP

Clicca su un pacchetto SYN e espandi la sezione **Transmission Control Protocol** nel pannello centrale. Noterai:

| Flag | SYN | SYN-ACK | ACK |
|---|---|---|---|
| SYN | ✅ 1 | ✅ 1 | ❌ 0 |
| ACK | ❌ 0 | ✅ 1 | ✅ 1 |
| FIN | ❌ 0 | ❌ 0 | ❌ 0 |

**📝 Domanda 1:** Nel pacchetto SYN iniziale, l'ISN (Initial Sequence Number) è casuale o fisso? Perché è importante che sia casuale?

---

## 📋 Fase 3 — Simulazione e analisi SYN Flood

> ⚠️ Questo esercizio va eseguito **solo su macchine virtuali locali** o in ambiente di laboratorio isolato.

### Step 3.1 — Setup ambiente (con macchine virtuali)

La configurazione consigliata è:
- **VM 1 — Vittima**: Windows 10 o Ubuntu Server (IP: es. `192.168.56.101`)
- **VM 2 — Attaccante**: Kali Linux (IP: es. `192.168.56.102`)
- Entrambe in modalità **Host-only network** su VirtualBox/VMware

### Step 3.2 — Avvia la cattura sulla VM Vittima

Sulla VM Vittima, avvia Wireshark sull'interfaccia di rete interna.

### Step 3.3 — Genera il SYN Flood dalla VM Attaccante

Sulla VM Kali, installa hping3 se non presente:
```bash
sudo apt install hping3
```

Lancia l'attacco SYN Flood simulato:
```bash
sudo hping3 -S --flood -p 80 192.168.56.101
# -S   → imposta il flag SYN
# --flood → invia pacchetti il più velocemente possibile
# -p 80 → verso la porta 80
```

Per aggiungere IP spoofing (IP sorgente casuale):
```bash
sudo hping3 -S --flood --rand-source -p 80 192.168.56.101
# --rand-source → IP sorgente randomizzato ad ogni pacchetto
```

Ferma l'attacco dopo **10-15 secondi** con `Ctrl+C`.

### Step 3.4 — Analisi su Wireshark

Sulla VM Vittima, ferma la cattura e applica il filtro:
```
tcp.flags.syn == 1 && tcp.flags.ack == 0
```

Dovresti osservare:

1. **Volume anomalo di SYN** — centinaia o migliaia in pochi secondi
2. **IP sorgenti diversi ad ogni pacchetto** — segno evidente di spoofing
3. **Nessun ACK** di completamento — le connessioni rimangono half-open
4. **SYN-ACK senza risposta** — il server risponde ma non riceve mai l'ACK finale

### Step 3.5 — Verifica il consumo di risorse

Sulla VM Vittima:
```bash
# Linux — mostra connessioni in stato SYN_RECV (half-open)
ss -ant | grep SYN_RECV | wc -l

# Windows — mostra connessioni TCP attive
netstat -an | findstr SYN_RECEIVED
```

Un numero elevato di `SYN_RECV` indica che il buffer delle connessioni half-open si sta esaurendo.

**📝 Domanda 2:** Quale principio della CIA Triad viene violato da un attacco SYN Flood? Motiva la risposta.

**📝 Domanda 3:** Cosa sono i **SYN cookies** e come mitigano questo attacco? (ricerca autonoma)

---

## 📋 Fase 4 — Analisi ARP e tracce di ARP Poisoning

L'**ARP Poisoning** (o ARP Spoofing) è la tecnica alla base degli attacchi Man in the Middle su reti locali. Consiste nell'inviare false risposte ARP per associare il proprio MAC address all'IP di un'altra macchina.

### Step 4.1 — Cattura traffico ARP normale

1. Avvia Wireshark con filtro `arp`
2. Apri il terminale e digita:
   ```bash
   # Linux
   arp -n
   
   # Windows
   arp -a
   ```
   Questo genera richieste ARP nella rete locale.

### Step 4.2 — Analisi dei pacchetti ARP

Nella cattura vedrai due tipi di pacchetti:

```
ARP Request:  "Who has 192.168.1.1? Tell 192.168.1.100"
ARP Reply:    "192.168.1.1 is at AA:BB:CC:DD:EE:FF"
```

Espandi un pacchetto ARP nel pannello centrale e identifica:
- **Opcode**: 1 = Request, 2 = Reply
- **Sender MAC** e **Sender IP**
- **Target MAC** e **Target IP**

### Step 4.3 — Simulazione ARP Poisoning (VM Kali)

> ⚠️ Solo in ambiente di laboratorio isolato con VM di proprietà.

Dalla VM Kali, usa `arpspoof` (pacchetto `dsniff`):
```bash
sudo apt install dsniff

# Abilita IP forwarding per non bloccare il traffico
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward

# Avvelena la cache ARP della vittima
# (dici alla vittima che il gateway è il tuo MAC)
sudo arpspoof -i eth0 -t 192.168.56.101 192.168.56.1

# In un secondo terminale, avvelena il gateway
# (dici al gateway che la vittima è il tuo MAC)
sudo arpspoof -i eth0 -t 192.168.56.1 192.168.56.101
```

### Step 4.4 — Analisi su Wireshark della VM Vittima

Applica il filtro `arp` e cerca:

1. **Gratuitous ARP** — risposte ARP non richieste (opcode=2 senza precedente request)
2. **Duplicati MAC** — lo stesso MAC associato a IP diversi
3. **Cambio MAC repentino** — un IP che prima aveva MAC-A ora ha MAC-B

**Indicatore chiave di ARP Poisoning:**
```
192.168.56.1 → MAC: AA:BB:CC:DD:EE:FF   (prima)
192.168.56.1 → MAC: 00:11:22:33:44:55   (dopo ARP poison — MAC dell'attaccante!)
```

Applica poi il filtro `http` sulla VM Kali — se la vittima naviga in HTTP, vedrai il suo traffico passare attraverso di te.

**📝 Domanda 4:** Quali principi della CIA Triad vengono violati dall'ARP Poisoning? In che modo HTTPS mitiga questo attacco?

---

## 📋 Fase 5 — Port Scanning con nmap e analisi della ricognizione

La fase di **Ricognizione** della Cyber Kill Chain lascia tracce rilevabili. Analizziamole.

### Step 5.1 — Esegui una scansione nmap (VM Attaccante → VM Vittima)

```bash
# Scansione TCP SYN (stealth scan)
sudo nmap -sS 192.168.56.101

# Scansione con rilevamento versione servizi
sudo nmap -sV 192.168.56.101

# Scansione OS fingerprinting
sudo nmap -O 192.168.56.101
```

### Step 5.2 — Analisi su Wireshark della VM Vittima

Applica il filtro:
```
ip.src == 192.168.56.102 && tcp
```

Osserva il pattern tipico di una scansione SYN:
```
Attaccante → Vittima: SYN porta 21
Vittima → Attaccante: RST/ACK (porta chiusa) OPPURE SYN/ACK (porta aperta)
Attaccante → Vittima: SYN porta 22
Vittima → Attaccante: SYN/ACK (porta aperta!) ← SSH attivo
Attaccante → Vittima: RST (non completa il handshake — stealth)
...
```

Usa il filtro `tcp.flags.syn==1 && tcp.flags.ack==0` per isolare tutti i SYN dell'attaccante e contarli — vedrai scansioni su decine o centinaia di porte in pochi secondi.

**📝 Domanda 5:** In quale fase della Cyber Kill Chain si colloca questa attività? Quali strumenti difensivi potresti attivare per rilevare o bloccare questa ricognizione?

---

## 📋 Fase 6 — Cattura di credenziali in chiaro (HTTP)

Questo esercizio dimostra perché HTTP non va mai usato per trasmettere dati sensibili.

### Step 6.1 — Setup server HTTP locale

Sulla VM Vittima, crea un form di login HTML minimale:
```bash
# Linux — avvia un server HTTP sulla porta 8080
python3 -m http.server 8080
```

Crea un file `login.html` nella cartella corrente:
```html
<!DOCTYPE html>
<html>
<body>
  <form method="POST" action="/login">
    <input type="text"     name="username" placeholder="Username">
    <input type="password" name="password" placeholder="Password">
    <button type="submit">Accedi</button>
  </form>
</body>
</html>
```

### Step 6.2 — Cattura le credenziali con Wireshark

1. Avvia la cattura su Wireshark con filtro `http`
2. Dalla VM Attaccante, naviga su `http://192.168.56.101:8080/login.html`
3. Inserisci username: `studente` e password: `supersecret123`
4. Invia il form
5. Torna su Wireshark e cerca pacchetti `POST /login`

Clicca sul pacchetto POST → nella sezione **HTML Form URL Encoded** vedrai in chiaro:
```
username=studente&password=supersecret123
```

**📝 Domanda 6:** Cosa cambierebbe se il form usasse HTTPS invece di HTTP? Quale campo del pacchetto sarebbe diverso?

---

## 📋 Fase 7 — Domande di verifica e report

Al termine del laboratorio, prepara un **report** (1-2 pagine) che risponde a tutte le domande segnalate con 📝, più le seguenti domande generali:

1. Per ogni attacco analizzato (SYN Flood, ARP Poisoning, Port Scan), indica:
   - Fase della **Cyber Kill Chain** in cui si colloca
   - Principio CIA violato
   - Una contromisura tecnica specifica

2. Qual è la differenza tra un **attacco DoS** e un **attacco DDoS**? Perché il DDoS è molto più difficile da mitigare?

3. Nel laboratorio hai analizzato credenziali HTTP in chiaro. Descrivi la differenza tecnica tra HTTP e HTTPS in termini di cosa è visibile a un attaccante che cattura il traffico.

4. In quale modo una **Botnet** amplificherà i problemi osservati nel SYN Flood simulato con una sola macchina?

---

## 📌 Riepilogo comandi utili

```bash
# Wireshark da riga di comando (tshark)
tshark -i eth0 -f "tcp port 80" -w cattura.pcap

# Leggi file pcap salvato
tshark -r cattura.pcap

# Filtra SYN flood in un pcap salvato
tshark -r cattura.pcap -Y "tcp.flags.syn==1 && tcp.flags.ack==0"

# Conta i pacchetti SYN
tshark -r cattura.pcap -Y "tcp.flags.syn==1" | wc -l

# Mostra IP sorgenti unici in un pcap
tshark -r cattura.pcap -T fields -e ip.src | sort | uniq -c | sort -rn

# nmap — scansione rapida
sudo nmap -sS -F 192.168.56.101

# Verifica ARP cache
arp -n                    # Linux
arp -a                    # Windows
```

---

## 📚 Risorse

- 📁 [Documentazione ufficiale Wireshark](https://www.wireshark.org/docs/wsug_html_chunked/)
- 🎯 [MITRE ATT&CK — Technique T1498 Network Denial of Service](https://attack.mitre.org/techniques/T1498/)
- 🎯 [MITRE ATT&CK — Technique T1557 Adversary-in-the-Middle](https://attack.mitre.org/techniques/T1557/)
- 📄 [RFC 793 — Transmission Control Protocol](https://www.rfc-editor.org/rfc/rfc793)
- 🔬 [Sample PCAP files per esercitarsi](https://www.malware-traffic-analysis.net/training-exercises.html)

---

## 🔗 Risorse correlate

- 🌐 **Sito:** [profgiagnotti.it](https://profgiagnotti.it)
- ▶️ **YouTube:** [youtube.com/@profgiagnotti](https://youtube.com/@profgiagnotti)
- 💬 **Discord:** [Unisciti alla community](https://discord.gg/profgiagnotti)

---

*Materiale a scopo educativo — uso esclusivamente su sistemi autorizzati · Licenza MIT · Prof. Giagnotti*
