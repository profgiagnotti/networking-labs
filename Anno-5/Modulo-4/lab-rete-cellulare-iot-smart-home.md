# 🔬 Lab — Rete Cellulare con Smart Home IoT e controllo remoto

![Materia](https://img.shields.io/badge/materia-Networking-3DE8A0?style=flat-square)
![Anno](https://img.shields.io/badge/anno-5-3DE8A0?style=flat-square)
![Modulo](https://img.shields.io/badge/modulo-4-3DE8A0?style=flat-square)
![Livello](https://img.shields.io/badge/livello-avanzato-FF5C5C?style=flat-square)
![Tool](https://img.shields.io/badge/tool-Packet%20Tracer-1BA0D7?style=flat-square&logo=cisco)

> Laboratorio pratico su reti cellulari, IoT domestico e controllo remoto via IoT Manager — Anno 5, Modulo 4  
> 🌐 Teoria collegata: [profgiagnotti.it — L05 IoT wireless: LoRaWAN, MQTT e LPWAN](https://profgiagnotti.it/corsi/networking/)

---

## 🎯 Obiettivi

Al termine di questo laboratorio sarai in grado di:

- ✅ Costruire una topologia che simula una **rete cellulare** con Cell Tower e Central Office Server
- ✅ Configurare la connessione **WAN via Cloud** (simulazione Internet via cavo coassiale)
- ✅ Configurare un **Home Gateway** come punto di accesso per la rete domestica IoT
- ✅ Registrare e configurare **7 dispositivi IoT** (sensori e attuatori domestici) sul server IoT
- ✅ Controllare i dispositivi IoT **da remoto** tramite l'app **IoT Manager** dello smartphone
- ✅ Verificare che il percorso Smartphone → Rete Cellulare → WAN → Home Gateway → IoT funzioni end-to-end

---

## 🗺️ Topologia di rete

```
┌──────────────────────────────┐
│  SMART   172.16.1.0          │
│                              │
│  [Smartphone0]               │
│        │ wireless            │
│  [Cell Tower0] ─── Coax0     │
└────────────────┬─────────────┘
                 │ Coax0/0
┌────────────────┴──────────────────────┐
│  MOBILE   200.100.50.0                │
│                                       │
│  [Central Office Server0]             │
|        │                              |
|        │                              │
|        │                              │
│        │ Gig0/0                       │
│  [Router] ──────── Gig0/1 ────────────┼───┐
│        │ Gig0/2                       │   │
└────────┼──────────────────────────────┘   │
         │                                  |
         |Fa0/1                             │ Eth6
┌────────┴──────────────┐    ┌──────────────┴──────────────────────┐
│  ISP   10.0.0.0       │    │  WAN   200.100.51.0                 │
│                       │    │                                     │
│  [Switch 2960]        │    │[Cloud0] ─── Coax7 ─── [Cable Modem0]│
│   Fa0/2      Fa0/3    │    │                             │ 0/0   │
│    │            │     │    └─────────────────────────────┼───────┘
│ [DNS Server] [IoT Srv]│                                  │
└───────────────────────┘           ┌──────────────────────┴───────────────────┐
                                    │  HOME   192.168.25.0                     │
                                    │                                          │
                                    │  [Home Gateway0] ─── [Laptop0]           │
                                    │        │ (wireless)                      │
                                    │   ┌────┴─────────────────────┐           │
                                    │  IoT0  IoT1  IoT2  IoT3(1)   │           │
                                    │  IoT4  IoT5  IoT6            │           │
                                    │  (Motion, Light, Window,     │           │
                                    │   Webcam, Siren, Garage,     │           │
                                    │   Door)                      │           │
                                    └──────────────────────────────────────────┘
```

---

## 📋 Piano di indirizzamento

| Dispositivo | Interfaccia | Indirizzo IP | Subnet Mask | Gateway |
|---|---|---|---|---|
| Smartphone0 | Wireless | (DHCP) | 255.255.255.0 | 172.16.1.254 |
| Cell Tower0 | — | — | — | (configurato automaticamente) |
| Central Office Server0 | Coax0/0 | 172.16.0.1 | 255.255.255.0 | — |
| Central Office Server0 | Fa0/0 | (DHCP) | — | — |
| Router2 | Gig0/0 (→ CO Server) | 200.100.50.1 | 255.255.255.0 | — |
| Router2 | Gig0/1 (→ Cloud WAN) | 200.100.51.1 | 255.255.255.0 | — |
| Router2 | Gig0/2 (→ Switch ISP) | 10.0.0.1 | 255.0.0.0 | — |
| Cloud0 | Eth6 (→ Router) | (configurato automaticamente)  | — | — |
| Cloud0 | Coax7 (→ Cable Modem) | (interno Cloud) | — | — |
| Cable Modem0 | 0/0 (→ Home Gateway) | (bridge) | — | — |
| Home Gateway0 | (DHCP) | — | — | — |
| Home Gateway0 | LAN | 192.168.25.1 | 255.255.255.0 | — |
| Laptop0 | Wi-Fi | (DHCP) | — | — |
| DNS Server | Fa0 | 10.0.0.254 | 255.0.0.0 | 10.0.0.1 |
| IoT Server | Fa0 | 10.0.0.253 | 255.0.0.0 | 10.0.0.1 |
| Dispositivi IoT (IoT0–IoT6) | Wi-Fi | 192.168.25.x (DHCP) | 255.255.255.0 | 192.168.25.1 |

> 📌 **Nota sulla rete cellulare**: in Packet Tracer il Cell Tower gestisce automaticamente l'indirizzamento nella rete SMART. Il Central Office Server funge da gateway tra la rete cellulare e la rete IP tradizionale.

---

## 📋 Step 1 — Costruzione della topologia

### 1.1 — Dispositivi da inserire

| Dispositivo | Modello PT | Area | Quantità |
|---|---|---|---|
| Smartphone | Smartphone-PT | SMART | 1 |
| Cell Tower | CellTower (categoria Wireless) | SMART | 1 |
| Central Office Server | Central-Office-Server | MOBILE | 1 |
| Router | Router-PT o 4321 | MOBILE/ISP | 1 |
| Switch | 2960-24TT | ISP | 1 |
| Cloud | Cloud-PT | WAN | 1 |
| Cable Modem | Cable-Modem-PT | WAN | 1 |
| Home Gateway | Home-Gateway-PT (DLC10d) | HOME | 1 |
| Laptop | Laptop-PT | HOME | 1 |
| Server DNS | Server-PT | ISP | 1 |
| Server IoT | Server-PT | ISP | 1 |
| Motion Detector | IoT Motion Detector | HOME | 1 |
| Light (lampada) | IoT Light | HOME | 1 |
| Window (finestra) | IoT Window | HOME | 1 |
| Webcam | IoT Webcam | HOME | 1 |
| Siren (sirena) | IoT Siren | HOME | 1 |
| Garage Door | IoT Garage Door | HOME | 1 |
| Door (porta) | IoT Door | HOME | 1 |

> ⚠️ I dispositivi IoT si trovano nella categoria **End Devices → Smart Devices** (o **IoT**) di Packet Tracer. Assicurati di usare la versione PT che supporta l'IoT (7.x o superiore).

### 1.2 — Cablaggio fisico

#### Area SMART → MOBILE

| Da | Porta | A | Porta | Tipo cavo |
|---|---|---|---|---|
| Smartphone0 | Wireless | Cell Tower0 | — | Wireless (automatico) |
| Cell Tower0 | Coax0 | Central Office Server0 | Coax0/0 | Coassiale |

#### Area MOBILE → WAN e ISP

| Da | Porta | A | Porta | Tipo cavo |
|---|---|---|---|---|
| Central Office Server0 | Fa0/0 | Router2 | Fa0/0 | Dritto |
| Router2 | Gig0/1 | Cloud0 | Eth6 | Dritto |
| Router2 | Fa0/1 | Switch ISP | Fa0/1 | Dritto |

#### Area WAN → HOME

| Da | Porta | A | Porta | Tipo cavo |
|---|---|---|---|---|
| Cloud0 | Coax7 | Cable Modem0 | Coax | Coassiale |
| Cable Modem0 | 0/0 | Home Gateway0 | 0/0 | Dritto |

#### Area ISP — Server

| Da | Porta | A | Porta | Tipo cavo |
|---|---|---|---|---|
| Switch ISP | Fa0/2 | DNS Server | Fa0 | Dritto |
| Switch ISP | Fa0/3 | IoT Server | Fa0 | Dritto |

#### Area HOME — dispositivi Wi-Fi

Tutti i dispositivi nella HOME (Laptop, dispositivi IoT) si connettono **in modalità wireless** all'Home Gateway0. Non richiedono cavo fisico — la connessione avviene tramite la scheda di rete wireless di ogni dispositivo.

> 📌 **Configurazione Cloud**: il Cloud-PT in Packet Tracer richiede di configurare le connessioni nelle sue schede interne. Verrà dettagliato nello Step 4.

---
## 📋 Step 2 — Configurazione della rete MOBILE (Router e Central Office)

### 2.1 — Router — configurazione interfacce

```
Router> enable
Router# configure terminal
Router(config)# hostname Router

! Interfaccia verso il Central Office Server (rete cellulare)
Router(config)# interface GigabitEthernet0/0
Router(config-if)# ip address 200.100.50.1 255.255.255.0
Router(config-if)# no shutdown
Router(config-if)# exit

! Interfaccia verso il Cloud (WAN verso la HOME)
Router(config)# interface GigabitEthernet0/1
Router(config-if)# ip address 200.100.51.1 255.255.255.0
Router(config-if)# no shutdown
Router(config-if)# exit

! Interfaccia verso lo switch ISP (DNS e IoT Server)
Router(config)# interface GigabitEthernet0/2
Router(config-if)# ip address 10.0.0.1 255.0.0.0
Router(config-if)# no shutdown
Router(config-if)# exit

Router(config)# end
Router# write memory
```

### 2.2 — Router — DHCP

Impostiamo sul Router il servizio DHCP verso le reti MOBILE e WAN

```
! DHCP verso la rete Mobile
Router# configure terminal
Router(config)# interface GigabitEthernet0/2
Router(config-if)# ip dhcp pool MOBILE
Router(dhcp-config)# network 200.100.50.0 255.255.255.0
Router(dhcp-config)# default router 200.100.50.1
Router(dhcp-config)# dns-server 10.0.0.254
Router(dhcp-config)# end

! DHCP verso la rete WAN
Router# configure terminal
Router(config)# interface GigabitEthernet0/1
Router(config-if)# ip dhcp pool WAN
Router(dhcp-config)# network 200.100.51.0 255.255.255.0
Router(dhcp-config)# default router 200.100.51.1
Router(dhcp-config)# dns-server 10.0.0.254
Router(dhcp-config)# end

Router# write memory
```

---

### 2.3 — Central Office Server0

Il Central Office Server è il cuore della rete cellulare — gestisce le connessioni degli smartphone tramite la Cell Tower e li instrada verso la rete IP.

Clicca su **Central Office Server0** → scheda **Config**:

**Interfaccia verso la Cell Tower (Coax0/0)**:
```
IP Address:  172.16.1.1
Subnet Mask: 255.255.255.0
```

**Interfaccia verso il Router (Backbone)**:
```
Attivare il DHCP e verificare l'acquisizione dei parametri
```

**Impostazioni DHCP per la rete cellulare SMART**:

Nella scheda **Services** → **DHCP**:
```

Start IP:        172.16.1.100
Subnet Mask:     255.255.255.0
Max Users:       50
DNS Server:      10.0.0.254
```

> 📌 Il Central Office Server assegna IP agli smartphone nella rete `172.16.1.0/24` attraverso la Cell Tower.


## 📋 Step 3 — Configurazione della Cell Tower

Clicca su **Settings** → flag on **Allow External Access**:

## 📋 Step 4 — Configurazione Smartphone

Clicca su **Wireless0** → Port status **OFF** (non flaggare)<br>
Clicca su **3G/4G Cell1** → Clicca su **DHCP Refresh**:<br>
Verifica che venga acquisito l'IP e la subnet mask ad esempio:<br>
```
Ip Address:  172.16.1.100
Subnet Mask: 255.255.255.0
```


## 📋 Step 5 — Configurazione dei Server ISP

### 3.1 — DNS Server (10.0.0.254)

Clicca su **DNS Server** → scheda **Config** → **FastEthernet0**:

```
IP Address:  10.0.0.254
Subnet Mask: 255.0.0.0
Gateway:     10.0.0.1
```

Scheda **Services** → **DNS** — Attiva il servizio e aggiungi i record:

| Name | Type | Address |
|---|---|---|
| iot.server.com | A | 10.0.0.3 |

> Il record DNS per il server IoT permette agli smartphone di trovare il server usando un nome invece di un IP.

### 3.2 — IoT Server (10.0.0.253)

Il **Server IoT** è il componente più importante di questo lab: gestisce la registrazione e il controllo remoto di tutti i dispositivi IoT della HOME.

Clicca su **IoT Server** → scheda **Config** → **FastEthernet0**:

```
IP Address:  10.0.0.253
Subnet Mask: 255.0.0.0
Gateway:     10.0.0.1
```

Scheda **Services** → **IoT**:

```
Status: ON (attiva il servizio)
```

> ⚠️ **le credenziali** Quando verranno configurati i dispositivi IoT vedremo in questa maschera usernme e password 

---

## 📋 Step 4 — Configurazione del Cloud e del Cable Modem

### 4.1 — Cloud-PT

Il Cloud simula la rete Internet che collega la rete cellulare (MOBILE) alla rete domestica (HOME). Va configurato internamente per instradare il traffico tra le due interfacce.

Clicca su **Cloud0** → scheda **Config**:

Nella sezione **DSL** o **Cable** aggiungi le connessioni:

| Interfaccia ingresso | Interfaccia uscita |
|---|---|
| Eth6 (da Router2) | Coax7 (verso Cable Modem) |

> 📌 In Packet Tracer il Cloud-PT funziona come un bridge/switch tra le interfacce configurate. Assicurati che Eth6 e Coax7 siano associate nella stessa "connection" interna del Cloud.

**Procedura**:
1. Apri Cloud0 → scheda **Config**
2. Seleziona **DSL** o **Cable** nel menu a sinistra
3. In **Provider Network**: collega `Coax7` ↔ `Eth6`
4. Clicca **Add**

### 4.2 — Cable Modem-PT

Il Cable Modem fa da bridge tra la rete coassiale del Cloud e la porta Ethernet dell'Home Gateway.

Clicca su **Cable Modem0** → scheda **Config**:

```
! Il Cable Modem non richiede IP — funziona in modalità bridge
! Verifica che le due interfacce siano attive:
! - Porta Coax (verso Cloud)
! - Porta 0/0 Ethernet (verso Home Gateway)
```

---

## 📋 Step 5 — Configurazione dell'Home Gateway

L'**Home Gateway** (modello DLC10d in PT) svolge tre funzioni: router verso Internet, access point Wi-Fi per i dispositivi domestici, e server DHCP per la rete HOME.

Clicca su **Home Gateway0** → scheda **Config**:

### 5.1 — Interfaccia Internet (WAN)

```
Connection Type: DHCP  (riceve IP dal Cable Modem/Cloud)
oppure statico:
IP Address:  192.168.25.1
Subnet Mask: 255.255.255.0
```

> ⚠️ In alcuni scenari PT l'Home Gateway riceve l'IP WAN automaticamente via DHCP dal Cloud. In altri va configurato manualmente. Verifica cosa funziona nella tua versione.

### 5.2 — Interfaccia LAN (rete domestica)

Scheda **Config** → **LAN**:

```
IP Address:  192.168.25.254
Subnet Mask: 255.255.255.0
```

### 5.3 — DHCP per la rete HOME

Scheda **Config** → **DHCP**:

```
Status:          ON
Start IP:        192.168.25.10
Maximum Users:   50
DNS Server:      10.0.0.2
```

### 5.4 — Rete Wi-Fi domestica

Scheda **Config** → **Wireless**:

```
SSID:     HomeNetwork
Security: WPA2-PSK
Password: HomePass2024
```

> 📌 Tutti i dispositivi IoT e il Laptop useranno questo SSID per connettersi alla rete domestica.

### 5.5 — Route verso Internet

L'Home Gateway deve sapere come raggiungere la rete cellulare (per il ritorno dei pacchetti) e la rete ISP:

Scheda **Config** → **Routing** → aggiungi route statiche:

```
Network:     10.0.0.0
Mask:        255.0.0.0
Next Hop:    192.168.25.1  (o l'IP WAN ricevuto)

Network:     200.100.51.0
Mask:        255.255.255.0
Next Hop:    192.168.25.1
```

---

## 📋 Step 6 — Configurazione del Laptop

Il Laptop nella HOME può essere usato per verificare la connessione e per accedere all'interfaccia di gestione dell'Home Gateway.

Clicca su **Laptop0** → scheda **Config** → **Wireless0**:

```
SSID:     HomeNetwork
Security: WPA2-PSK
Password: HomePass2024
```

Seleziona **DHCP** per l'indirizzo IP — il Laptop riceverà un IP nel range `192.168.25.10 – 192.168.25.59`.

---

## 📋 Step 7 — Configurazione dei dispositivi IoT

Ogni dispositivo IoT deve essere connesso alla rete Wi-Fi dell'Home Gateway e poi registrato sul Server IoT remoto. Ripeti questa procedura per ciascuno dei 7 dispositivi.

### 7.1 — Connessione alla rete Wi-Fi

Per ogni dispositivo IoT (IoT0–IoT6):

1. Clicca sul dispositivo → scheda **Config**
2. Seleziona **Wireless0** (o l'interfaccia Wi-Fi disponibile)
3. Imposta:

```
SSID:     HomeNetwork
Auth:     WPA2-PSK
Password: HomePass2024
```

4. Seleziona **DHCP** per l'indirizzo IP
5. Verifica che il dispositivo riceva un IP nel range `192.168.25.10+`

### 7.2 — Registrazione sul Server IoT remoto

Dopo la connessione Wi-Fi, ogni dispositivo deve essere registrato sul Server IoT:

1. Clicca sul dispositivo IoT → scheda **Config**
2. Cerca la sezione **IoT Server** o **Remote Server**
3. Compila i campi:

```
Server Address: 10.0.0.3
Username:       admin
Password:       admin
```

4. Clicca **Connect** o **Register**

> ✅ Quando la registrazione ha successo, il dispositivo appare nella lista del Server IoT.

### 7.3 — Riepilogo dispositivi IoT da configurare

| Dispositivo | Nome PT | Tipo | Funzione |
|---|---|---|---|
| IoT0 | Motion Detector | Sensore | Rileva movimento nell'area |
| IoT1 | Light | Attuatore | Accende/spegne la luce |
| IoT2 | Window | Attuatore | Apre/chiude la finestra |
| IoT3(1) | Webcam | Sensore/Stream | Monitoraggio video |
| IoT4 | Siren | Attuatore | Attiva allarme sonoro |
| IoT5 | Garage Door | Attuatore | Apre/chiude il garage |
| IoT6 | Door | Attuatore | Controlla la porta d'ingresso |

---

## 📋 Step 8 — Configurazione dello Smartphone

Lo smartphone si connette via rete cellulare e deve poter raggiungere il Server IoT per controllare i dispositivi HOME da remoto.

### 8.1 — Connessione alla rete cellulare

Clicca su **Smartphone0** → scheda **Config** → **Wireless (Cellular)**:

```
! Lo smartphone si connette automaticamente alla Cell Tower
! Verifica che il segnale cellulare sia visibile (barre di segnale)
```

Seleziona **DHCP** — lo smartphone riceverà un IP dalla rete cellulare nel range `172.16.1.x` tramite il Central Office Server.

### 8.2 — Verifica connettività

Clicca su **Smartphone0** → **Desktop** → **Command Prompt**:

```
! Verifica IP ricevuto
ipconfig

! Ping verso il Server IoT (percorso completo: cellulare → Router2 → IoT Server)
ping 10.0.0.3

! Ping verso il DNS Server
ping 10.0.0.2

! Ping verso l'Home Gateway
ping 192.168.25.254
```

Tutti i ping devono rispondere prima di procedere con l'IoT Manager.

### 8.3 — Configurazione IoT Manager

L'**IoT Manager** è l'app sullo smartphone che permette di visualizzare e controllare i dispositivi IoT registrati sul server remoto.

Clicca su **Smartphone0** → **Desktop** → **IoT Monitor** (o **IoT Manager**):

1. Nella schermata di login inserisci:

```
Server Address: 10.0.0.3
Username:       admin
Password:       admin
```

2. Clicca **Login** / **Connect**

3. Se la connessione ha successo, vedrai la lista di tutti i dispositivi IoT registrati (IoT0–IoT6)

4. Per ogni dispositivo puoi:
   - Visualizzare lo **stato attuale** (acceso/spento, aperto/chiuso, rilevato/non rilevato)
   - **Azionare** gli attuatori (accendere la luce, aprire il garage, attivare la sirena...)
   - Monitorare i **sensori** in tempo reale (motion detector, webcam)

---

## 📋 Step 9 — Verifica completa end-to-end

### Test 1 — Ping dal Router2 verso tutti i segmenti

```
Router2# ping 10.0.0.2
! Risposta attesa: !!!!! (5 successi)

Router2# ping 10.0.0.3
! Risposta attesa: !!!!!

Router2# ping 192.168.25.254
! Risposta attesa: !!!!!

Router2# ping 200.100.50.1
! Risposta attesa: !!!!!
```

### Test 2 — Ping dallo Smartphone verso Internet

Smartphone → Desktop → Command Prompt:

```
ping 10.0.0.3
! Il percorso completo: Smartphone → Cell Tower → CO Server → Router2 → IoT Server

ping 192.168.25.254
! Raggiunge l'Home Gateway della rete domestica
```

### Test 3 — Controllo IoT Manager

1. Apri **IoT Manager** sullo smartphone
2. Accedi con `admin / admin` su `10.0.0.3`
3. Nella lista dispositivi, clicca su **Light (IoT1)**
4. Premi il pulsante **ON**
5. Verifica che la lampada nell'area HOME cambi stato visivamente in Packet Tracer
6. Ripeti per tutti gli altri attuatori (Window, Garage Door, Siren, Door)

### Test 4 — Navigazione web dal Laptop

Laptop → Desktop → Web Browser:

```
http://10.0.0.3
! Dovrebbe aprire l'interfaccia web del Server IoT

http://10.0.0.2
! Interfaccia del DNS Server
```

---

## 🔍 Troubleshooting — Problemi comuni

| Problema | Causa probabile | Soluzione |
|---|---|---|
| Smartphone non riceve IP | Cell Tower non configurata o CO Server non attivo | Verifica la connessione Coax tra Cell Tower e CO Server; controlla il pool DHCP nel CO Server |
| Ping da Smartphone verso `10.0.0.3` fallisce | Route mancante in Router2 | Verifica `show ip route` su Router2 — devono esserci route verso `10.0.0.0` e `192.168.25.0` |
| IoT Manager non si connette al server | IoT Server non raggiungibile o credenziali errate | Verifica ping verso `10.0.0.3`; controlla username/password nel servizio IoT del server |
| I dispositivi IoT non compaiono nell'IoT Manager | Registrazione incompleta o IP IoT Server sbagliato | Rientra in ogni dispositivo IoT e riverifica la sezione "Remote Server" con `10.0.0.3` |
| Cloud non instrada il traffico | Connessione Eth6 ↔ Coax7 non configurata nel Cloud | Apri Cloud0 → Config → Cable/DSL → verifica che le due interfacce siano associate |
| Home Gateway non distribuisce IP | Servizio DHCP non attivo o range errato | Scheda Config del Gateway → DHCP → verifica Status ON e range `192.168.25.10` |
| Dispositivi IoT non si connettono al Wi-Fi | SSID o password errati | Verifica che SSID e password corrispondano esattamente a quelli dell'Home Gateway |
| Ping verso `192.168.25.x` fallisce da Router2 | Route verso HOME mancante | `ip route 192.168.25.0 255.255.255.0 200.100.51.2` su Router2 |

---

## 💡 Comandi di verifica utili

### Sul Router2

```
! Verifica routing table completa
show ip route

! Output atteso — devono comparire:
! S    172.16.1.0/24 [1/0] via 200.100.50.1
! C    200.100.50.0/24 is directly connected, FastEthernet0/0
! C    200.100.51.0/24 is directly connected, GigabitEthernet0/1
! C    10.0.0.0/8 is directly connected, FastEthernet0/1
! S    192.168.25.0/24 [1/0] via 200.100.51.2

! Verifica interfacce attive (tutte devono essere up/up)
show ip interface brief

! Test raggiungibilità IoT Server
ping 10.0.0.3

! Test raggiungibilità Home Gateway
ping 192.168.25.254
```

### Sul Server IoT (scheda Services)

- Verifica che il servizio IoT sia **ON**
- Controlla la lista dei **dispositivi registrati** — devono comparire tutti e 7 gli IoT
- Verifica le credenziali impostate (username/password)

---

## 📐 Schema riepilogativo — Flusso di configurazione

```
1. Topologia fisica
   └─ Posiziona tutti i dispositivi e crea le connessioni fisiche/wireless

2. Central Office Server (CO)
   └─ IP: 200.100.50.1
   └─ DHCP per rete cellulare SMART (172.16.1.0/24)

3. Router2
   └─ Fa0/0 → 200.100.50.2 (verso CO Server)
   └─ Gig0/1 → 200.100.51.1 (verso Cloud/WAN)
   └─ Fa0/1 → 10.0.0.1 (verso Switch ISP)
   └─ Route statiche verso HOME e SMART

4. Cloud-PT
   └─ Associa Eth6 ↔ Coax7 internamente

5. Home Gateway
   └─ WAN: IP ricevuto o statico
   └─ LAN: 192.168.25.254
   └─ DHCP: pool 192.168.25.10+
   └─ Wi-Fi: SSID HomeNetwork / WPA2

6. DNS Server (10.0.0.2)
   └─ Record A: iot.server.com → 10.0.0.3

7. IoT Server (10.0.0.3)
   └─ Attiva servizio IoT
   └─ Credenziali: admin / admin

8. Dispositivi IoT (x7)
   └─ Connetti a Wi-Fi HomeNetwork
   └─ Registra su Server IoT: 10.0.0.3 / admin / admin

9. Smartphone
   └─ Connessione cellulare automatica via Cell Tower
   └─ Verifica DHCP (172.16.1.x)
   └─ Desktop → IoT Manager → 10.0.0.3 / admin / admin

10. Verifica
    └─ Ping end-to-end: Smartphone → IoT Server → Home Gateway
    └─ IoT Manager: controlla ogni dispositivo da remoto
```

---

## 🧠 Concetti chiave — perché funziona così

### Rete cellulare in Packet Tracer

La triade **Smartphone → Cell Tower → Central Office Server** simula il percorso reale di un dato nella rete 4G/5G:
- Lo **smartphone** si connette alla stazione radio base (Cell Tower)
- La **Cell Tower** trasporta il segnale radio verso la centrale
- Il **Central Office Server** traduce il segnale in traffico IP instradabile su Internet

### Ruolo del Cloud-PT

Il **Cloud-PT** di Packet Tracer simula la rete Internet: accetta connessioni da tecnologie diverse (Ethernet, Coax, DSL) e le fa comunicare come se fossero sulla stessa rete globale.

### IoT Server vs Home Gateway

- L'**Home Gateway** controlla localmente i dispositivi IoT nella rete domestica
- Il **Server IoT** (remoto, nella rete ISP) mantiene un registro centralizzato di tutti i dispositivi e permette l'accesso **da qualsiasi rete** — anche dalla rete cellulare dello smartphone

Questo è esattamente il modello delle piattaforme cloud IoT reali (AWS IoT, Azure IoT Hub, Google Cloud IoT): i dispositivi si registrano su un server remoto e possono essere controllati da ovunque nel mondo.

---

## 📚 Riferimenti

- 📖 [Cisco Packet Tracer — IoT Labs Guide](https://www.netacad.com/courses/packet-tracer)
- 📖 [MQTT Protocol — Standard IoT Messaging](https://mqtt.org/)
- 🌐 [Teoria L05 — IoT wireless: LoRaWAN, MQTT e LPWAN](https://profgiagnotti.it/corsi/networking/)
- 🌐 [Teoria L06 — WMAN/WWAN: reti cellulari e 5G](https://profgiagnotti.it/corsi/networking/)
