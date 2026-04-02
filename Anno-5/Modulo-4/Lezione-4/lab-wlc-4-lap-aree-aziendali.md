# 🔬 Lab — Wireless LAN Controller con 4 LAP e aree funzionali aziendali

![Materia](https://img.shields.io/badge/materia-Networking-3DE8A0?style=flat-square)
![Anno](https://img.shields.io/badge/anno-5-3DE8A0?style=flat-square)
![Modulo](https://img.shields.io/badge/modulo-4-3DE8A0?style=flat-square)
![Livello](https://img.shields.io/badge/livello-avanzato-FF5C5C?style=flat-square)
![Tool](https://img.shields.io/badge/tool-Packet%20Tracer-1BA0D7?style=flat-square&logo=cisco)

> Laboratorio pratico su reti Wi-Fi Enterprise con WLC e Lightweight Access Point — Anno 5, Modulo 4  
> 🌐 Teoria collegata: [profgiagnotti.it — L04 WLAN Enterprise: 802.1X, EAP, RADIUS e WLC](https://profgiagnotti.it/corsi/networking/)

---

## 🎯 Obiettivi

Al termine di questo laboratorio sarai in grado di:

- ✅ Costruire una topologia enterprise con **WLC** (Wireless LAN Controller) e 4 **LAP-PT** (Lightweight Access Point)
- ✅ Configurare il WLC tramite interfaccia web (HTTPS) dal MGMT-PC
- ✅ Creare 4 **WLAN distinte** (SSID) per le 4 aree funzionali aziendali con WPA2-PSK
- ✅ Configurare un **pool DHCP** centralizzato per distribuire IP ai client wireless
- ✅ Associare ogni LAP al proprio **AP Group** per instradare i client sulla WLAN corretta
- ✅ Configurare il **routing RIP** tra router di frontiera e router Internet simulato
- ✅ Verificare la connettività end-to-end dagli smartphone al server DNS/HTTP su Internet

---

## 🗺️ Topologia di rete

```
                    ┌──────────────────────────────────────────────┐
                    │              INTERNET SIMULATO               │
                    │                                              │
                    │  [ISR331-Internet]  ─── [Switch-2960]        │
                    │   Gig0/0/0                Fa0/1              │
                    │  10.0.0.0/8            ┌──┴──┐               │
                    │                   Fa0/2│     │ Fa0/3         │
                    │              [PC-Esterna]  [Server DNS-HTTP] │
                    │              10.0.0.10      10.0.0.254       │
                    └──────────────┬───────────────────────────────┘
                                   │ Gig0/0/1 ↔ RIP
                                   │
                    ┌──────────────┴───────────────────────────────┐
                    │          RETE AZIENDALE 192.168.1.0/24       │
                    │                                              │
                    │  [ISR331-Frontiera]                          │
                    │   Fa8/1 ↓                                    │
                    │  [Switch-Concentratore 2960]                 │
                    │   Fa0  ─── [Server DHCP 192.168.1.254]       │
                    │   Gig1 ─── [WLC-2504]  ─── Gig2 ─── [MGMT-PC]│
                    │   Fa2/1     Fa3/1      Fa6/1       Fa7/1     │
                    │     │         |          |           |       │
                    │  LAP-AMM   LAP-TEC    LAP-MAG     LAP-SEG    │
                    └──────────────────────────────────────────────┘

Aree funzionali (SSID):
  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐
  │ Amministrazione│  │  Ufficio Tecn. │  │   Magazzino    │  │   Segreteria   │
  │ LAP-AMM        │  │  LAP-TEC       │  │  LAP-MAG       │  │  LAP-SEG       │
  │ 2x Smartphone  │  │  1x Smartphone │  │  1x Smartphone │  │  2x Smartphone │
  └────────────────┘  └────────────────┘  └────────────────┘  └────────────────┘
```

---

## 📋 Piano di indirizzamento

| Dispositivo | Interfaccia | Indirizzo IP | Subnet Mask | Gateway / Note |
|---|---|---|---|---|
| Server DHCP (aziendale) | Fa0 | 192.168.1.254 | 255.255.255.0 | 192.168.1.1 |
| WLC-2504 | Management | 192.168.1.10 | 255.255.255.0 | 192.168.1.1 |
| MGMT-PC | Fa0 | 192.168.1.20 | 255.255.255.0 | 192.168.1.1 |
| ISR331-Frontiera | Fa8/1 (→ Switch) | 192.168.1.1 | 255.255.255.0 | — |
| ISR331-Frontiera | Gig0/0/1 (→ Internet) | 20.100.50.1 | 255.0.0.0 | — |
| ISR331-Internet | Gig0/0/1 (→ Frontiera) | 20.100.50.2 | 255.0.0.0 | — |
| ISR331-Internet | Gig0/0/0 (→ Switch Internet) | 10.0.0.1 | 255.0.0.0 | — |
| Server DNS-HTTP | Fa0 | 10.0.0.254 | 255.0.0.0 | 10.0.0.1 |
| PC Rete Esterna | Fa0 | 10.0.0.10 | 255.0.0.0 | 10.0.0.1 |
| Smartphone (tutti) | Wi-Fi | (da DHCP WLC) | 255.255.255.0 | 192.168.1.1 |

> 📌 **DNS configurato su tutti i client**: `www.sito.it → 10.0.0.254` · `www.dhcp.it → 192.168.1.254` · `www.wlc.it → 192.168.1.10`

---

## 📋 SSID e credenziali Wi-Fi

| Area | SSID | Sicurezza | Passphrase |
|---|---|---|---|
| Amministrazione | Amministrazione | WPA2 Personal | Amministrazione |
| Ufficio Tecnico | Ufficio Tecnico | WPA2 Personal | *(a scelta)* |
| Magazzino | Magazzino | WPA2 Personal | *(a scelta)* |
| Segreteria | Segreteria | WPA2 Personal | *(a scelta)* |

---

## 📋 Step 1 — Costruzione della topologia

### 1.1 — Dispositivi da inserire nel workspace

Trascina i seguenti dispositivi sul workspace di Packet Tracer:

| Dispositivo | Modello PT | Quantità |
|---|---|---|
| Router frontiera | ISR 4321 o Router-PT | 1 |
| Router Internet simulato | ISR 4321 o Router-PT | 1 |
| Switch concentratore aziendale | 2960-24TT | 1 |
| Switch rete Internet | 2960-24TT | 1 |
| WLC — Wireless LAN Controller | WLC-2504 | 1 |
| LAP — Lightweight Access Point | LAP-PT | 4 |
| Server DHCP aziendale | Server-PT | 1 |
| Server DNS-HTTP (Internet) | Server-PT | 1 |
| MGMT-PC | PC-PT | 1 |
| PC Rete Esterna | PC-PT | 1 |
| Smartphone (aree Wi-Fi) | Smartphone-PT | 8 |

> ⚠️ **Attenzione ai LAP-PT**: dopo aver trascinato un LAP sul workspace, selezionalo e nella scheda **Config** inserisci il **Power Adapter** trascinandolo nello slot apposito (drag and drop dal pannello fisico). Senza alimentazione il LAP non si accende.

### 1.2 — Cablaggio fisico

#### Rete aziendale interna

| Da | Porta | A | Porta | Tipo cavo |
|---|---|---|---|---|
| Server DHCP | Fa0 | Switch-Concentratore | Fa0/1 | Dritto |
| Switch-Concentratore | Fa0/2 | ISR331-Frontiera | Fa8/1 | Dritto |
| ISR331-Frontiera | Gig0/0/1 | ISR331-Internet | Gig0/0/1 | Incrociato |
| Switch-Concentratore | Gig0/1 | WLC-2504 | Gig1 | Dritto |
| WLC-2504 | Gig2 | MGMT-PC | Fa0 | Dritto |
| WLC-2504 | (wireless) | LAP-AMM | Gig0 | — |
| WLC-2504 | (wireless) | LAP-TEC | Gig0 | — |
| WLC-2504 | (wireless) | LAP-MAG | Gig0 | — |
| WLC-2504 | (wireless) | LAP-SEG | Gig0 | — |

> 📌 I LAP-PT in Packet Tracer si collegano al WLC **logicamente via rete** — non con un cavo diretto. Ogni LAP deve raggiungere il WLC tramite IP (attraverso lo switch concentratore). Il protocollo usato è CAPWAP.

#### Rete Internet simulata

| Da | Porta | A | Porta | Tipo cavo |
|---|---|---|---|---|
| ISR331-Internet | Gig0/0/0 | Switch-Internet | Fa0/1 | Dritto |
| Switch-Internet | Fa0/2 | Server DNS-HTTP | Fa0 | Dritto |
| Switch-Internet | Fa0/3 | PC Rete Esterna | Fa0 | Dritto |

---

## 📋 Step 2 — Configurazione del Server DHCP aziendale

Il Server-PT che funge da DHCP distribuirà indirizzi a tutti i client della rete 192.168.1.0/24 — inclusi gli smartphone che si connettono via WLC.

### 2.1 — Indirizzo IP del server

Apri il Server-PT → scheda **Desktop** → **Ip Configuration**:

```
IP Address:       192.168.1.254
Subnet Mask:      255.255.255.0
Default Gateway:  192.168.1.1
DNS Server:       10.0.0.254
```

### 2.2 — Configurazione servizio DHCP

Nella scheda **Services** → **DHCP**:

```
Pool Name:       serverPool
Default Gateway: 192.168.1.1
DNS Server:      10.0.0.254
Start IP:        192.168.1.100
Subnet Mask:     255.255.255.0
Max Users:       50
```

> ⚠️ Segna anche l'indirizzo del WLC da escludere dal pool: il WLC userà `192.168.1.10` come Management IP — questo IP viene assegnato manualmente, non via DHCP.


---

## 📋 Step 3 — Configurazione del Server DNS-HTTP su Internet

Apri il Server-PT della rete Internet (10.0.0.254):

### Indirizzo IP

Scheda **Desktop** → **Ip Configuration**::

```
IP Address:       10.0.0.254
Subnet Mask:      255.0.0.0
Default Gateway:  10.0.0.1
DNS Server:       10.0.0.254
```

### Servizio HTTP

Scheda **Services** → **HTTP**: verifica che il servizio sia **ON**.  
Puoi personalizzare la pagina `index.html` con il contenuto che preferisci.

### 2.3 — Configurazione servizio DNS

Nella scheda **Services** → **DNS**, attiva il servizio e aggiungi i record A:

| Name | Type | Address |
|---|---|---|
| www.sito.it | A | 10.0.0.254 |
| www.dhcp.it | A | 192.168.1.254 |
| www.wlc.it | A | 192.168.1.10 |

### 2.3 — Configurazione iniziale WLC

Nella scheda **Config** → **Management**:

```
IP Address:       192.168.1.10
Subnet Mask:      255.255.255.0
Default Gateway:  192.168.1.1
DNS Server:       10.0.0.254
```

---

## 📋 Step 4 — Configurazione dei router

### 4.1 — ISR331-Frontiera

```
Router> enable
Router# configure terminal
Router(config)# hostname ISR331-Frontiera

! Interfaccia verso lo switch concentratore aziendale
ISR331-Frontiera(config)# interface FastEthernet8/1
ISR331-Frontiera(config-if)# ip address 192.168.1.1 255.255.255.0
! Questo gateway è anche il default gateway della rete aziendale
ISR331-Frontiera(config-if)# no shutdown
ISR331-Frontiera(config-if)# exit

! Interfaccia verso il router Internet (link WAN)
ISR331-Frontiera(config)# interface GigabitEthernet0/0/1
ISR331-Frontiera(config-if)# ip address 20.100.50.1 255.0.0.0
ISR331-Frontiera(config-if)# no shutdown
ISR331-Frontiera(config-if)# exit

! Configurazione RIP per raggiungere la rete 10.0.0.0/8 via Internet
ISR331-Frontiera(config)# router rip
ISR331-Frontiera(config-router)# version 2
ISR331-Frontiera(config-router)# network 192.168.1.0
ISR331-Frontiera(config-router)# network 20.0.0.0
! "no auto-summary" disattiva la summarizzazione automatica
ISR331-Frontiera(config-router)# no auto-summary
ISR331-Frontiera(config-router)# exit

! Configurazione DNS per la risoluzione nomi
ISR331-Frontiera(config)# ip domain-lookup
ISR331-Frontiera(config)# ip name-server 10.0.0.254

ISR331-Frontiera(config)# end
ISR331-Frontiera# write memory
```

### 4.2 — ISR331-Internet (simulazione Internet)

```
Router> enable
Router# configure terminal
Router(config)# hostname ISR331-Internet

! Interfaccia verso il router di frontiera (link WAN)
ISR331-Internet(config)# interface GigabitEthernet0/0/1
ISR331-Internet(config-if)# ip address 20.100.50.2 255.0.0.0
ISR331-Internet(config-if)# no shutdown
ISR331-Internet(config-if)# exit

! Interfaccia verso lo switch Internet (rete server/PC esterni)
ISR331-Internet(config)# interface GigabitEthernet0/0/0
ISR331-Internet(config-if)# ip address 10.0.0.1 255.0.0.0
ISR331-Internet(config-if)# no shutdown
ISR331-Internet(config-if)# exit

! RIP — annuncia entrambe le reti connesse
ISR331-Internet(config)# router rip
ISR331-Internet(config-router)# version 2
ISR331-Internet(config-router)# network 20.0.0.0
ISR331-Internet(config-router)# network 10.0.0.0
ISR331-Internet(config-router)# no auto-summary
ISR331-Internet(config-router)# exit

ISR331-Internet(config)# end
ISR331-Internet# write memory
```

> 📌 **Come funziona RIP qui**: il Router-Frontiera annuncia la rete `192.168.1.0` al Router-Internet. Il Router-Internet annuncia la rete `10.0.0.0`. In questo modo i client aziendali sanno come raggiungere Internet e viceversa.

---

## 📋 Step 5 — Accesso al WLC tramite browser

Il WLC si configura tramite **interfaccia web HTTPS** — non da CLI. Per accedervi:

### 5.1 — Prerequisiti

- Il MGMT-PC deve avere un indirizzo IP (`192.168.1.20/24`)
- Verifica la connettività: dal MGMT-PC apri il **Command Prompt** e digita:

```
ping 192.168.1.10
```

Se il ping non risponde, verifica i cavi e la configurazione DHCP del server.

### 5.2 — Apertura del pannello di controllo

Dal **MGMT-PC** → apri **Desktop** → **Web Browser**:

```
URL: https://192.168.1.10   (oppure www.wlc.it)
```

> ⚠️ Il protocollo è **https** (non http). Se la pagina non si apre, verifica che il WLC abbia ricevuto correttamente l'IP di management.

**Credenziali di accesso:**

```
Username: cisco
Password: Cisco@1234
```

*(o le credenziali di default del WLC-2504 in Packet Tracer)*

---

## 📋 Step 6 — Setup iniziale del WLC (wizard)

Al primo accesso il WLC presenta un **wizard di configurazione**. Completa i campi come segue:

### Scheda Setup Controller

| Campo | Valore |
|---|---|
| System Name | WLC-Aziendale |
| Management IP Address | **192.168.1.10** |
| Management Subnet Mask | 255.255.255.0 |
| Management Gateway | 192.168.1.254 |
| Management VLAN | 0 (nessuna VLAN) |

> ⚠️ **Il campo Management IP è critico**: assicurati di inserire `192.168.1.10`. Se lasci l'IP di default o inserisci un valore errato, perdi l'accesso al WLC e devi ricominciare.

Clicca **Next** per procedere alla schermata successiva.

### Scheda Network (WLAN iniziale)

Configura la **prima WLAN** (quella per l'Amministrazione):

| Campo | Valore |
|---|---|
| Network Name (SSID) | Amministrazione |
| Security | WPA2 Personal |
| Passphrase | Amministrazione |

Clicca **Next** → nella schermata successiva lascia tutti i parametri inalterati → clicca **Apply**.

> Il sistema chiederà un **riavvio**: conferma. Attendi il riavvio completo (circa 30 secondi in PT).

### Verifica dopo il riavvio

- Chiudi il browser
- Fai un **ping a 192.168.1.10** dal MGMT-PC per verificare che il WLC sia tornato online
- Riapri il browser e accedi nuovamente a `https://192.168.1.10`

---

## 📋 Step 7 — Creazione delle 4 WLAN

Ora che il WLC è configurato, aggiunge le altre 3 WLAN (Ufficio Tecnico, Magazzino, Segreteria).

Dalla dashboard del WLC → scheda **WLANs**:

Per ciascuna WLAN clicca **Add** (o il pulsante `+`) e compila:

### WLAN 2 — Ufficio Tecnico

| Campo | Valore |
|---|---|
| WLAN ID | 2 |
| Profile Name | UfficioTecnico |
| SSID | UfficioTecnico |

Nella scheda successiva (WLAN Edit) oppure cliccando sulla VLAN id configurare:

| Status | **Enable** ✅ |
| Security | **WPA2 PSK** |
| Passphrase | *(a tua scelta — es. "UfficioTecnico")* |

Clicca **Apply**.

### WLAN 3 — Magazzino

| Campo | Valore |
|---|---|
| WLAN ID | 3 |
| Profile Name | Magazzino |
| SSID | Magazzino |

Nella scheda successiva (WLAN Edit) oppure cliccando sulla VLAN id configurare:

| Status | **Enable** ✅ |
| Security | **WPA2 PSK** |
| Passphrase | *(a tua scelta — es. "Magazzino")* |

Clicca **Apply**.

### WLAN 4 — Segreteria

| Campo | Valore |
|---|---|
| WLAN ID | 4 |
| Profile Name | Segreteria |
| SSID | Segreteria |

Nella scheda successiva (WLAN Edit) oppure cliccando sulla VLAN id configurare:

| Status | **Enable** ✅ |
| Security | **WPA2 PSK** |
| Passphrase | *(a tua scelta — es. "Segreteria")* |

Clicca **Apply**.

> 📌 **Riepilogo WLAN create**: al termine avrai 4 WLAN attive — Amministrazione (ID 1), Ufficio Tecnico (ID 2), Magazzino (ID 3), Segreteria (ID 4).

---

## 📋 Step 8 — Creazione degli AP Group

Gli **AP Group** permettono di associare ogni LAP a una specifica WLAN. In questo modo ogni access point trasmette solo l'SSID della propria area funzionale.

Dalla dashboard WLC → scheda **WIRELESS** (o **Advanced**) → **AP Groups**:

Clicca **Add Group** per ogni area:

### Gruppo Amministrazione 

1. **Group Name**: Amministrazione
2. Clicca **Add**
3. Nella sezione **WLANs** del gruppo: clicca **Add** → seleziona **SSID: Amministrazione** → **ADD**
4. Nella sezione **APs**: clicca **Add** → seleziona **LAP-Amministrazione** → **ADD**
5. Clicca **Apply**

### Gruppo UfficioTecnico

1. **Group Name**: UfficioTecnico
2. WLAN assegnata: **Ufficio Tecnico**
3. AP assegnato: **LAP-UfficioTecnico**
4. Clicca **Apply**

### Gruppo Magazzino

1. **Group Name**: Magazzino
2. WLAN assegnata: **Magazzino**
3. AP assegnato: **LAP-Magazzino**
4. Clicca **Apply**

### Gruppo Segreteria

1. **Group Name**: Segreteria
2. WLAN assegnata: **Segreteria**
3. AP assegnato: **LAP-Segreteria**
4. Clicca **Apply**

> ⚠️ **Se gli AP non compaiono nell'elenco**: significa che i LAP non hanno ancora stabilito il tunnel CAPWAP con il WLC. Verifica che tutti i LAP abbiano il Power Adapter installato e che raggiungano il WLC via ping.

---

## 📋 Step 9 — Configurazione degli smartphone

Per ogni smartphone nelle aree funzionali:

Clicca sullo smartphone → **Desktop** → **PC Wireless**:

### Connessione alla WLAN corretta

1. Tab **Connect**: vedrai la lista degli SSID disponibili
2. Seleziona l'SSID dell'area di appartenenza (es. **Amministrazione** per gli smartphone nell'area AMM)
3. Clicca **Connect**
4. Inserisci la **Passphrase** configurata per quella WLAN
5. Clicca **Connect**

### Verifica indirizzo IP ricevuto

Dopo la connessione → scheda **IP Configuration**:
- Seleziona **DHCP**
- Lo smartphone dovrebbe ricevere un IP nel range `192.168.1.100 – 192.168.1.149`
- Gateway: `192.168.1.254`
- DNS: `10.0.0.254`

| Smartphone | Area | SSID da usare |
|---|---|---|
| Smartphone1(4), Smartphone1(4)(1) | Amministrazione | Amministrazione |
| Smartphone0 | Ufficio Tecnico | Ufficio Tecnico |
| Smartphone1 | Magazzino | Magazzino |
| Smartphone0(3), Smartphone1(3) | Segreteria | Segreteria |

---

## 📋 Step 10 — Verifica finale della connettività

### Test 1 — Ping dal MGMT-PC

Dal MGMT-PC → **Desktop** → **Command Prompt**:

```
! Verifica raggiungibilità WLC
ping 192.168.1.10

! Verifica raggiungibilità server DHCP
ping 192.168.1.254

! Verifica raggiungibilità router di frontiera
ping 192.168.1.1

! Verifica raggiungibilità server Internet (attraverso RIP)
ping 10.0.0.254
```

### Test 2 — Ping da uno smartphone

Dal **Smartphone** connesso a una WLAN → **Desktop** → **Command Prompt**:

```
! Verifica che lo smartphone abbia IP dalla DHCP
ipconfig

! Ping verso il gateway aziendale
ping 192.168.1.254

! Ping verso Internet (verifica routing RIP end-to-end)
ping 10.0.0.254

! Ping verso il server con risoluzione DNS
ping www.sito.it
```

### Test 3 — Navigazione web

Dal **MGMT-PC** → **Desktop** → **Web Browser**:

```
http://www.sito.it
http://10.0.0.254
```

La pagina del server HTTP deve caricarsi correttamente.

---

## 🔍 Troubleshooting — Problemi comuni

| Problema | Causa probabile | Soluzione |
|---|---|---|
| Il WLC non risponde a `https://192.168.1.10` | Power Adapter non inserito nel WLC | Scheda Physical del WLC → inserisci il modulo di alimentazione |
| I LAP non si associano al WLC | Power Adapter non inserito nel LAP | Scheda Physical del LAP → inserisci il Power Adapter con drag and drop |
| Gli smartphone non ricevono IP | Servizio DHCP non attivo o mal configurato | Verifica scheda Services → DHCP sul Server-PT (deve essere ON) |
| Ping verso `10.0.0.254` fallisce | RIP non configurato correttamente | Verifica `show ip route` su entrambi i router — devono vedersi le reti vicendevoli |
| Il browser non apre `www.sito.it` | DNS non raggiungibile o non configurato | Verifica IP DNS su MGMT-PC (`10.0.0.254`) e che il server DNS abbia il record A |
| AP Group vuoto (AP non compare) | Il LAP non ha ancora contattato il WLC | Attendi qualche secondo — il tunnel CAPWAP impiega tempo ad alzarsi |
| Smartphone si connette ma non naviga | Gateway non configurato o routing mancante | Verifica che il gateway dello smartphone sia `192.168.1.254` e che il router abbia la route verso `10.0.0.0` via RIP |

---

## 💡 Comandi di verifica utili

### Sul router di frontiera

```
! Verifica la routing table — devono comparire route RIP verso 10.0.0.0
show ip route

! Output atteso:
!  R    10.0.0.0/8 [120/1] via 20.100.50.2, ...
!  C    192.168.1.0/24 is directly connected, FastEthernet8/1
!  C    20.0.0.0/8 is directly connected, GigabitEthernet0/0/1

! Verifica interfacce attive
show ip interface brief

! Test ping verso Internet
ping 10.0.0.254
```

### Sul WLC (via browser)

Dalla dashboard WLC puoi verificare:
- **Monitor → Access Points**: lista dei LAP connessi con stato UP/DOWN
- **Monitor → Clients**: lista degli smartphone connessi con SSID e IP assegnato
- **WLANs**: stato delle 4 WLAN (deve essere **Enabled** per tutte)

---

## 📐 Schema riepilogativo — Flusso di configurazione

```
1. Topologia fisica
   └─ Posiziona dispositivi e cabla secondo il piano

2. Server DHCP (192.168.1.254)
   └─ Configura IP statico
   └─ Attiva pool DHCP (start: .100, gateway: .254, dns: 10.0.0.254)
   └─ Aggiungi record DNS

3. Router Frontiera
   └─ Configura interfacce (Fa8/1 → LAN, Gig0/0/1 → WAN)
   └─ Configura RIP v2 per le reti 192.168.1.0 e 20.0.0.0

4. Router Internet
   └─ Configura interfacce (Gig0/0/1 → WAN, Gig0/0/0 → DMZ-Internet)
   └─ Configura RIP v2 per le reti 20.0.0.0 e 10.0.0.0

5. WLC — Setup via browser (https://192.168.1.10)
   └─ Wizard: Management IP = 192.168.1.10, GW = 192.168.1.254
   └─ Prima WLAN: Amministrazione / WPA2 / Passphrase: Amministrazione

6. WLC — WLAN aggiuntive
   └─ Ufficio Tecnico (WLAN 2)
   └─ Magazzino (WLAN 3)
   └─ Segreteria (WLAN 4)

7. WLC — AP Groups
   └─ AMM → WLAN Amministrazione + LAP-AMM
   └─ TEC → WLAN Ufficio Tecnico + LAP-TEC
   └─ MAG → WLAN Magazzino + LAP-MAG
   └─ SEG → WLAN Segreteria + LAP-SEG

8. Smartphone
   └─ Connetti a SSID area di appartenenza
   └─ Seleziona DHCP — verifica IP ricevuto

9. Verifica
   └─ Ping cross-area (smartphone → Internet)
   └─ Navigazione web verso www.sito.it
```

---

## 📚 Riferimenti

- 📖 [Cisco WLC 2504 — Configuration Guide](https://www.cisco.com/c/en/us/td/docs/wireless/controller/7-4/configuration/guides/consolidated/b_cg74_CONSOLIDATED.html)
- 📖 [CAPWAP — RFC 5415](https://www.rfc-editor.org/rfc/rfc5415)
- 🌐 [Teoria L04 — WLAN Enterprise: WLC, 802.1X e AP Group](https://profgiagnotti.it/corsi/networking/)
- 🌐 [The Things Network — AP Groups in WLC](https://www.cisco.com/c/en/us/support/docs/wireless-mobility/wireless-lan-wlan/68087-wlc-apgroups.html)
