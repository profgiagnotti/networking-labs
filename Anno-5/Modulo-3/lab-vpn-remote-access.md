# 🔬 Lab — VPN Remote Access su router Cisco IOS

![Materia](https://img.shields.io/badge/materia-Networking-3DE8A0?style=flat-square)
![Anno](https://img.shields.io/badge/anno-5-3DE8A0?style=flat-square)
![Modulo](https://img.shields.io/badge/modulo-3-3DE8A0?style=flat-square)
![Livello](https://img.shields.io/badge/livello-avanzato-FF5C5C?style=flat-square)
![Tool](https://img.shields.io/badge/tool-Packet%20Tracer-1BA0D7?style=flat-square&logo=cisco)

> Laboratorio pratico su VPN Remote Access (EasyVPN) — Anno 5, Modulo 3  
> 🌐 Teoria collegata: [profgiagnotti.it — L06/L07 VPN e IPsec](https://profgiagnotti.it/corsi/networking/)

---

## 🎯 Obiettivi

Al termine di questo laboratorio sarai in grado di:

- ✅ Configurare un router Cisco IOS come **server VPN Remote Access** (EasyVPN Server)
- ✅ Definire un **pool di indirizzi IP** per i client VPN remoti
- ✅ Configurare la **policy ISAKMP** e il **transform set** per il tunnel
- ✅ Creare un **gruppo VPN** con credenziali e autorizzazioni specifiche
- ✅ Configurare un **PC client** con il client VPN integrato in Packet Tracer
- ✅ Verificare che il client remoto ottenga un IP interno e raggiunga le risorse aziendali

---

## 🗺️ Topologia di rete

```
┌───────────────────────────────────────┐
│           RETE AZIENDALE              │
│       LAN: 192.168.1.0/24             │
│                                       │
│  [PC-LAN1] 192.168.1.10               │
│  [Server]  192.168.1.100              │
│       |                               │
│  [Switch LAN]                         │
│       | Fa0/0 — 192.168.1.1           │
│  [Router VPN Gateway]                 │
│       | Se2/0 — 10.0.0.1              │
└───────────────────┬───────────────────┘
                    │
              (Internet simulato)
                    │
              10.0.0.2 | Fa0/0
           [Router Internet]
              Fa1/0 | 203.0.113.1
                    │
              [Switch Remoto]
                    │
           [PC-REMOTO] 203.0.113.10
           (il dipendente da casa)
```

---

## 📋 Piano di indirizzamento

| Dispositivo | Interfaccia | Indirizzo IP | Subnet Mask | Gateway |
|---|---|---|---|---|
| PC-LAN1 (rete aziendale) | Fa0 | 192.168.1.10 | 255.255.255.0 | 192.168.1.1 |
| Server (rete aziendale) | Fa0 | 192.168.1.100 | 255.255.255.0 | 192.168.1.1 |
| Router VPN — verso LAN | Fa0/0 | 192.168.1.1 | 255.255.255.0 | — |
| Router VPN — verso Internet | Se2/0 | 10.0.0.1 | 255.255.255.252 | — |
| Router Internet — verso VPN | Se2/0 | 10.0.0.2 | 255.255.255.252 | — |
| Router Internet — verso remoto | Fa1/0 | 203.0.113.1 | 255.255.255.0 | — |
| PC-REMOTO (dipendente remoto) | Fa0 | 203.0.113.10 | 255.255.255.0 | 203.0.113.1 |

**Pool VPN** (indirizzi assegnati ai client VPN remoti):

| Parametro | Valore |
|---|---|
| Nome pool | POOL-VPN-REMOTI |
| Rete | 172.16.1.0/24 |
| Range | 172.16.1.10 — 172.16.1.50 |

> 📌 Il pool VPN usa una rete distinta dalla LAN aziendale (192.168.1.0/24). Quando il PC-REMOTO si connette, riceverà un IP in 172.16.1.x e potrà comunicare con i dispositivi della LAN 192.168.1.0/24.

---

## 📋 Step 1 — Costruzione della topologia

### 1.1 — Dispositivi da inserire

| Dispositivo | Modello PT | Quantità |
|---|---|---|
| Router VPN Gateway | Router-PT o 2911 | 1 |
| Router Internet | Router-PT o 2911 | 1 |
| Switch LAN aziendale | 2960-24TT | 1 |
| Switch rete remota | 2960-24TT | 1 |
| PC-LAN1 (rete aziendale) | PC-PT | 1 |
| Server (rete aziendale) | Server-PT | 1 |
| PC-REMOTO | PC-PT | 1 |

### 1.2 — Cablaggio

| Da | Porta | A | Porta | Tipo cavo |
|---|---|---|---|---|
| PC-LAN1 | Fa0 | Switch LAN | Fa0/1 | Dritto |
| Server | Fa0 | Switch LAN | Fa0/2 | Dritto |
| Switch LAN | Fa0/3 | Router VPN | Fa0/0 | Dritto |
| Router VPN | Se2/0 | Router Internet | Se2/0 | Seriale DCE |
| Router Internet | Fa1/0 | Switch Remoto | Fa0/1 | Dritto |
| Switch Remoto | Fa0/2 | PC-REMOTO | Fa0 | Dritto |

### 1.3 — Configurazione dispositivi finali

**PC-LAN1**: IP `192.168.1.10` / SM `255.255.255.0` / GW `192.168.1.1`

**Server aziendale**:
- IP `192.168.1.100` / SM `255.255.255.0` / GW `192.168.1.1`
- Attiva **HTTP**: Services → HTTP → ON
- Modifica `index.html`:
```html
<html><body>
  <h1>Server Aziendale Interno</h1>
  <p>Visibile solo dalla rete aziendale o tramite VPN</p>
</body></html>
```

**PC-REMOTO**: IP `203.0.113.10` / SM `255.255.255.0` / GW `203.0.113.1`

---

## 📋 Step 2 — Configurazione base dei router

### Router Internet

```
Router> enable
Router# configure terminal
Router(config)# hostname RouterInternet

! Interfaccia seriale verso Router VPN
RouterInternet(config)# interface Serial2/0
RouterInternet(config-if)# ip address 10.0.0.2 255.255.255.252
RouterInternet(config-if)# clock rate 64000
! clock rate sul lato DCE del cavo seriale
RouterInternet(config-if)# no shutdown
RouterInternet(config-if)# exit

! Interfaccia verso la rete del PC remoto
RouterInternet(config)# interface FastEthernet1/0
RouterInternet(config-if)# ip address 203.0.113.1 255.255.255.0
RouterInternet(config-if)# no shutdown
RouterInternet(config-if)# exit

! Rotta verso la LAN aziendale (per instradare le risposte ai client VPN)
RouterInternet(config)# ip route 192.168.1.0 255.255.255.0 10.0.0.1
! Rotta verso il pool VPN (per le risposte agli IP assegnati ai client remoti)
RouterInternet(config)# ip route 172.16.1.0 255.255.255.0 10.0.0.1

RouterInternet(config)# end
RouterInternet# write memory
```

### Router VPN Gateway — configurazione base

```
Router> enable
Router# configure terminal
Router(config)# hostname RouterVPN

! Interfaccia LAN verso la rete aziendale
RouterVPN(config)# interface FastEthernet0/0
RouterVPN(config-if)# ip address 192.168.1.1 255.255.255.0
RouterVPN(config-if)# description LAN-Aziendale
RouterVPN(config-if)# no shutdown
RouterVPN(config-if)# exit

! Interfaccia WAN verso Internet
RouterVPN(config)# interface Serial2/0
RouterVPN(config-if)# ip address 10.0.0.1 255.255.255.252
RouterVPN(config-if)# description WAN-Internet
RouterVPN(config-if)# no shutdown
RouterVPN(config-if)# exit

! Rotta di default verso Internet
RouterVPN(config)# ip route 0.0.0.0 0.0.0.0 10.0.0.2

RouterVPN(config)# end
RouterVPN# write memory
```

### Verifica connettività base

Dal **PC-REMOTO**: `Desktop → Command Prompt`
```
ping 10.0.0.1    ! → Router VPN WAN: deve rispondere ✅
```

> 📌 La LAN aziendale (192.168.1.x) NON deve essere raggiungibile dal PC-REMOTO prima della VPN. Questo è corretto — la VPN serve esattamente per questo.

---

## 📋 Step 3 — Configurazione del server VPN (EasyVPN Server)

La VPN Remote Access su Cisco IOS si basa su **EasyVPN** — una versione semplificata che centralizza tutta la configurazione sul server.

### Passo 1 — Pool di indirizzi IP per i client VPN

```
! Definisce il range di IP che il server VPN assegnerà ai client remoti
! Questi IP permettono al client di "appartenere" alla rete aziendale
RouterVPN(config)# ip local pool POOL-VPN-REMOTI 172.16.1.10 172.16.1.50
! "POOL-VPN-REMOTI" = nome del pool (riferimento nei passi successivi)
! 172.16.1.10 = primo IP assegnabile
! 172.16.1.50 = ultimo IP assegnabile
! Supporta fino a 41 client VPN contemporanei
```

### Passo 2 — ISAKMP Policy (Fase 1)

```
RouterVPN(config)# crypto isakmp policy 10
RouterVPN(config-isakmp)# encryption aes 256
! Cifratura del canale IKE di controllo

RouterVPN(config-isakmp)# hash sha256
! Hash per l'integrità dei messaggi IKE

RouterVPN(config-isakmp)# authentication pre-share
! Autenticazione con chiave pre-condivisa
! In ambienti enterprise si usano certificati digitali (rsa-sig)

RouterVPN(config-isakmp)# group 14
! Gruppo Diffie-Hellman 2048 bit

RouterVPN(config-isakmp)# lifetime 28800
! SA IKE dura 8 ore (28800 secondi)
! Più breve rispetto alla Site-to-Site (24h) perché le sessioni remoto
! sono in genere più corte

RouterVPN(config-isakmp)# exit
```

### Passo 3 — Gruppo ISAKMP con credenziali VPN

```
! Il "gruppo" definisce le credenziali e i parametri per i client remoti
! Un client VPN si autentica fornendo il nome del gruppo e la chiave
RouterVPN(config)# crypto isakmp client configuration group GRUPPO-REMOTI
! "GRUPPO-REMOTI" = nome del gruppo VPN
! Il client VPN dovrà inserire esattamente questo nome

RouterVPN(config-isakmp-group)# key ChiaveGruppo!2024
! Chiave di gruppo (Group Password): il client deve conoscerla per autenticarsi
! È una prima autenticazione "di gruppo" — non identifica il singolo utente

RouterVPN(config-isakmp-group)# pool POOL-VPN-REMOTI
! Assegna al gruppo il pool di IP definito al Passo 1
! I client di questo gruppo riceveranno un IP da questo pool

RouterVPN(config-isakmp-group)# acl 101
! ACL che definisce quali risorse aziendali sono accessibili ai client VPN
! La configuriamo subito dopo

RouterVPN(config-isakmp-group)# dns 192.168.1.1
! Server DNS da comunicare ai client VPN (opzionale)

RouterVPN(config-isakmp-group)# exit
```

### Passo 4 — ACL di accesso per i client VPN

```
! Questa ACL definisce il "split tunneling":
! quale traffico deve passare nel tunnel VPN
! e quale può andare direttamente su Internet
RouterVPN(config)# access-list 101 permit ip 172.16.1.0 0.0.0.255 192.168.1.0 0.0.0.255
! Traffico dal pool VPN (172.16.1.0/24) verso la LAN aziendale (192.168.1.0/24)
! passa nel tunnel cifrato

! Se vuoi che TUTTO il traffico del client passi nel tunnel (no split tunneling):
! access-list 101 permit ip any any
```

### Passo 5 — Transform Set (Fase 2)

```
! Algoritmi per la protezione dei dati utente
RouterVPN(config)# crypto ipsec transform-set TS-REMOTE-ACCESS esp-aes 256 esp-sha256-hmac
RouterVPN(cfg-crypto-trans)# mode tunnel
RouterVPN(cfg-crypto-trans)# exit
```

### Passo 6 — Profilo IPsec e crypto map dinamica

```
! IPsec Profile — lega il transform set per uso con la crypto map dinamica
RouterVPN(config)# crypto ipsec profile PROFILO-REMOTI
RouterVPN(ipsec-profile)# set transform-set TS-REMOTE-ACCESS
RouterVPN(ipsec-profile)# exit

! Crypto Map DINAMICA — usata per client la cui IP non è noto in anticipo
! A differenza della Site-to-Site (IP fisso), i client remoti hanno IP variabile
RouterVPN(config)# crypto dynamic-map DYNMAP-REMOTI 10
RouterVPN(config-crypto-map)# set transform-set TS-REMOTE-ACCESS
RouterVPN(config-crypto-map)# reverse-route
! reverse-route: aggiunge automaticamente la rotta verso il client nel routing table
RouterVPN(config-crypto-map)# exit

! Crypto Map STATICA che include la mappa dinamica
RouterVPN(config)# crypto map VPN-SERVER-MAP 10 ipsec-isakmp dynamic DYNMAP-REMOTI
! La mappa statica "VPN-SERVER-MAP" riferisce alla mappa dinamica "DYNMAP-REMOTI"
! Le connessioni in arrivo da client con IP non predefiniti usano la mappa dinamica
```

### Passo 7 — Configurazione AAA per autenticazione locale

```
! AAA (Authentication Authorization Accounting)
! Definisce come il server VPN autentica gli utenti
RouterVPN(config)# aaa new-model
! Abilita il modello AAA

RouterVPN(config)# aaa authentication login VPN-AUTHN local
! "VPN-AUTHN" = nome della lista di autenticazione
! "local" = usa il database locale del router (non RADIUS/TACACS)

RouterVPN(config)# aaa authorization network VPN-AUTHZ local
! Autorizzazione di rete tramite database locale

! Crea gli utenti VPN nel database locale
RouterVPN(config)# username alice secret AlicePass!2024
RouterVPN(config)# username bob   secret BobPass!2024
! Questi sono le credenziali PERSONALI di ciascun utente VPN
! (diversi dalle credenziali di gruppo definite al Passo 3)

! Collega AAA alla configurazione del client VPN
RouterVPN(config)# crypto isakmp profile PROFILO-CLIENT
RouterVPN(conf-isa-prof)# match identity group GRUPPO-REMOTI
! Applica questo profilo ai client che si identificano con il gruppo "GRUPPO-REMOTI"
RouterVPN(conf-isa-prof)# client authentication list VPN-AUTHN
RouterVPN(conf-isa-prof)# isakmp authorization list VPN-AUTHZ
RouterVPN(conf-isa-prof)# client configuration address respond
! Il server risponde alle richieste di indirizzo IP dai client
RouterVPN(conf-isa-prof)# exit
```

### Passo 8 — Applica la crypto map all'interfaccia WAN

```
RouterVPN(config)# interface Serial2/0
RouterVPN(config-if)# crypto map VPN-SERVER-MAP
! Attiva la VPN sull'interfaccia WAN
! Tutte le connessioni IPsec in arrivo vengono gestite da questa map

RouterVPN(config-if)# exit
RouterVPN(config)# end
RouterVPN# write memory
```

---

## 📋 Step 4 — Configurazione del client VPN sul PC-REMOTO

In Packet Tracer il client VPN si configura nel pannello del PC.

1. Clicca su **PC-REMOTO**
2. Vai su **Desktop → VPN**
3. Compila i campi:

| Campo | Valore |
|---|---|
| Server IP | `10.0.0.1` (IP WAN del Router VPN) |
| Username | `alice` |
| Password | `AlicePass!2024` |
| Group Name | `GRUPPO-REMOTI` |
| Group Key | `ChiaveGruppo!2024` |

4. Clicca **Connect**

Se la configurazione è corretta, vedrai:
- **Status: Connected**
- Il PC-REMOTO riceverà un IP nel range 172.16.1.10–172.16.1.50

> ⚠️ **Nota Packet Tracer**: la versione del client VPN integrato in PT può variare. In alcune versioni si usa Desktop → VPN Client, in altre le impostazioni sono in Desktop → IP Configuration. Consulta la versione specifica di PT in uso.

---

## 📋 Step 5 — Verifica della connessione VPN

### Verifica sul server VPN

```
! Mostra le sessioni VPN attive
RouterVPN# show crypto isakmp sa
```

Output atteso:
```
dst         src         state    conn-id  slot  status
10.0.0.1    203.0.113.10  QM_IDLE    1      0    ACTIVE
```

```
! Mostra le SA IPsec (Fase 2) attive
RouterVPN# show crypto ipsec sa
```

```
! Mostra gli utenti VPN connessi e gli IP assegnati
RouterVPN# show crypto session
```

Output esempio:
```
Crypto session current status
Interface: Serial2/0
Session status: UP-ACTIVE
Peer: 203.0.113.10 port 500
  IKE SA: local 10.0.0.1/500 remote 203.0.113.10/500 Active
  IPSEC FLOW: permit ip 172.16.1.0/255.255.255.0 192.168.1.0/255.255.255.0
```

```
! Mostra gli IP assegnati dal pool VPN
RouterVPN# show ip local pool POOL-VPN-REMOTI
```

Output esempio:
```
Pool          Begin           End             Free    In use
POOL-VPN-REMOTI  172.16.1.10     172.16.1.50      40      1
```

`In use: 1` significa che un client ha ricevuto un IP dal pool.

### Verifica dal PC-REMOTO

Dopo la connessione VPN, dal **PC-REMOTO**: `Desktop → Command Prompt`

```
ipconfig
! Mostra la configurazione IP: dovresti vedere sia l'IP reale (203.0.113.10)
! che l'IP VPN assegnato (172.16.1.x)

ping 192.168.1.100
! → Server aziendale: deve rispondere ✅
! Questo ping usa il tunnel VPN

ping 192.168.1.10
! → PC-LAN1: deve rispondere ✅
```

Dal **PC-REMOTO**: `Desktop → Web Browser`
```
http://192.168.1.100
! La pagina del server aziendale deve apparire ✅
! Questo è il test definitivo: il client remoto accede alla rete interna
```

### Test di isolamento — prima della VPN

Disconnetti la VPN sul PC-REMOTO e ripeti i test:
```
ping 192.168.1.100    ! → DEVE FALLIRE ❌
```
Questo conferma che la rete interna è accessibile **solo tramite VPN**.

---

## 📋 Step 6 — Tabella riepilogativa dei test

| Test | Da | Verso | VPN | Risultato atteso |
|---|---|---|---|---|
| Ping IP pubblico VPN | PC-REMOTO | 10.0.0.1 | ❌ Disconnessa | ✅ OK (routing normale) |
| Ping server interno | PC-REMOTO | 192.168.1.100 | ❌ Disconnessa | ❌ FALLISCE |
| Ping server interno | PC-REMOTO | 192.168.1.100 | ✅ Connessa | ✅ OK (tramite tunnel) |
| Browser server interno | PC-REMOTO | 192.168.1.100 | ✅ Connessa | ✅ Pagina appare |
| Ping client VPN → LAN | PC-LAN1 | 172.16.1.10 (IP VPN alice) | ✅ Connessa | ✅ OK |
| IKE SA attiva | Router VPN | show crypto isakmp sa | ✅ Connessa | QM_IDLE |

---

## 📋 Riepilogo comandi di configurazione server VPN

```
! ── POOL IP PER CLIENTI VPN ──────────────────────────────────────────
ip local pool <NOME-POOL> <IP-START> <IP-END>

! ── ISAKMP POLICY ─────────────────────────────────────────────────────
crypto isakmp policy <PRIORITA>
 encryption aes 256
 hash sha256
 authentication pre-share
 group 14
 lifetime 28800

! ── GRUPPO VPN CON CREDENZIALI ────────────────────────────────────────
crypto isakmp client configuration group <NOME-GRUPPO>
 key <CHIAVE-GRUPPO>
 pool <NOME-POOL>
 acl <NUM-ACL>
 dns <IP-DNS>

! ── ACL SPLIT TUNNELING ───────────────────────────────────────────────
access-list <NUM-ACL> permit ip <POOL-VPN> <WILDCARD> <LAN-AZIENDALE> <WILDCARD>

! ── TRANSFORM SET ─────────────────────────────────────────────────────
crypto ipsec transform-set <NOME-TS> esp-aes 256 esp-sha256-hmac
 mode tunnel

! ── CRYPTO MAP DINAMICA ───────────────────────────────────────────────
crypto dynamic-map <NOME-DYNMAP> 10
 set transform-set <NOME-TS>
 reverse-route

crypto map <NOME-MAP> 10 ipsec-isakmp dynamic <NOME-DYNMAP>

! ── AAA E UTENTI ──────────────────────────────────────────────────────
aaa new-model
aaa authentication login <LISTA-AUTH> local
aaa authorization network <LISTA-AUTHZ> local
username <UTENTE> secret <PASSWORD>

! ── PROFILO ISAKMP ────────────────────────────────────────────────────
crypto isakmp profile <NOME-PROFILO>
 match identity group <NOME-GRUPPO>
 client authentication list <LISTA-AUTH>
 isakmp authorization list <LISTA-AUTHZ>
 client configuration address respond

! ── APPLICAZIONE INTERFACCIA ──────────────────────────────────────────
interface <INTERFACCIA-WAN>
 crypto map <NOME-MAP>

! ── VERIFICA ──────────────────────────────────────────────────────────
show crypto isakmp sa
show crypto ipsec sa
show crypto session
show ip local pool <NOME-POOL>
show crypto isakmp client configuration group <NOME-GRUPPO>
```

---

## 📋 Domande di verifica

1. Nella VPN Remote Access hai configurato un **pool di indirizzi** (172.16.1.10–50) diverso dalla LAN aziendale (192.168.1.0/24). Perché è necessario usare una rete distinta invece di assegnare IP dalla stessa subnet della LAN?

2. Qual è la differenza tra le **credenziali di gruppo** (`key ChiaveGruppo!2024`) e le **credenziali utente** (`username alice secret AlicePass!2024`)? A quale scopo serve ciascuna?

3. Nel laboratorio hai usato una **crypto map dinamica** (`crypto dynamic-map`), diversamente dalla VPN Site-to-Site che usava una crypto map statica. Spiega perché nella Remote Access è necessaria la mappa dinamica.

4. Cos'è il **split tunneling** e come è implementato attraverso l'ACL 101? Modifica la configurazione per disabilitarlo (tutto il traffico nel tunnel) e descrivi i pro e contro delle due scelte.

5. Il comando `show ip local pool POOL-VPN-REMOTI` mostra `In use: 0` anche dopo che il client si è connesso. Elenca almeno tre possibili cause e come diagnosticarle.

6. Confronta la VPN **Site-to-Site** configurata nel laboratorio precedente con questa **Remote Access**: quali componenti di configurazione sono comuni a entrambe? Quali sono presenti solo in una delle due?

---

## 📚 Risorse

- 🔗 [Cisco — EasyVPN Server Configuration Guide](https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/sec_conn_vpnips/configuration/xe-16/sec-conn-vpnips-xe-16-book/sec-easy-vpn-server.html)
- 📄 [Cisco — Remote Access VPN Solutions](https://www.cisco.com/c/en/us/products/security/remote-access-vpn.html)
- 🔗 [Cisco — AAA Configuration Guide](https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/sec_usr_aaa/configuration/xe-16/sec-usr-aaa-xe-16-book.html)

---

## 🔗 Risorse correlate

- 🌐 **Sito:** [profgiagnotti.it](https://profgiagnotti.it)
- ▶️ **YouTube:** [youtube.com/@profgiagnotti](https://youtube.com/@profgiagnotti)
- 💬 **Discord:** [Unisciti alla community](https://discord.gg/profgiagnotti)

---

*Materiale a scopo educativo · Licenza MIT · Prof. Giagnotti*
