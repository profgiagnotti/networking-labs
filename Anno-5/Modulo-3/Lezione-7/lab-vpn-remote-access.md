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
│       LAN: 172.16.0.0/16              │
│                                       │
│                                       │
│  [WEB Server]  172.16.0.2             │
│       |                               │
│  [Switch LAN]                         |
|       | Fa1/1                         |
|       |                               │
│       | G0/1 — 172.16.0.1             │
│  [Router VPN Gateway]                 │
│       | G0/0 — 98.100.25.24           │
└───────────────────┬───────────────────┘
                    │
              (Internet simulato)
                    │
       98.100.25.25 | Fa0/0
           [Router Internet]
              Se3/0 | 85.120.2.28
                    │
┌───────────────────────────────────────┐
│        [Router domestico]             │
│        Se2/0 — 85.120.2.27            |
|                   |  Fa0/0            |
|                   |                   |
│                   | Fa0/1             │
│             [Switch LAN]              |
|                   | Fa1/1             |
|                   |                   │
│      [Home Worker] 192.168.0.2        │
|                                       |
|                                       |
│           RETE DOMESTICA              │
│         LAN: 192.168.0.0/24           |   
└───────────────────────────────────────┘
```

---

## 📋 Piano di indirizzamento

| Dispositivo | Interfaccia | Indirizzo IP | Subnet Mask | Gateway |
|---|---|---|---|---|
| Home Worker (rete domestica) | Fa0 | 192.168.0.2 | 255.255.255.0 | 192.168.0.1 |
| Web Server (rete aziendale) | Fa0 | 172.16.0.2 | 255.255.0.0 | 172.16.0.1 |
| Router domestico verso LAN | Fa0/0 | 192.168.0.1 | 255.255.255.0 | — |
| Router domestico verso Internet| Se2/0 | 85.120.2.27 | 255.0.0.0 | — |
| Router VPN — verso azienda | G0/0 | 172.16.0.1 | 255.255.0.0 | — |
| Router VPN — verso Internet | G0/1 | 98.100.25.24 | 255.0.0.0 | — |
| Router Internet — verso azienda | Fa0/0 | 98.100.25.25 | 255.0.0.0 | — |
| Router Internet — verso remoto | Se3/0 | 85.120.2.28 | 255.0.0.0 | — |

**Pool VPN** (indirizzi assegnati ai client VPN remoti):

| Parametro | Valore |
|---|---|
| Nome pool | VPN-pool |
| Rete | 172.16.32.0/24 |
| Range | 172.16.32.101 — 172.16.32.200 |

> 📌 Il pool VPN usa una rete distinta dalla LAN aziendale (172.16.0.0/16). Quando il PC HomeWorker si connette, riceverà un IP in 172.16.32.x e potrà comunicare con i dispositivi della LAN 172.16.0.0/16.

---

## 📋 Step 1 — Costruzione della topologia

### 1.1 — Dispositivi da inserire

| Dispositivo | Modello PT | Quantità |
|---|---|---|
| Router VPN Gateway | Router 1941 | 1 |
| Router Internet | Router PT | 1 |
| Router Domestico | Router PT | 1 |
| Switch LAN aziendale | 2960-24TT | 1 |
| Switch rete remota | 2960-24TT | 1 |
| PC-Home Worker (rete LAN) | PC-PT | 1 |
| Web Server (rete aziendale) | Server-PT | 1 |

### 1.2 — Cablaggio

| Da | Porta | A | Porta | Tipo cavo |
|---|---|---|---|---|
| PC-Home Worker | Fa0 | Switch LAN | Fa1/1 | Dritto |
| Switch LAN | Fa0/1 | Router Domestico | Fa0/0 | Dritto |
| Router Domestico | Se2/0 | Router Internet | Se3/0 | Seriale |
| Router Internet | Fa0/0 | Router Aziendale | G0/0 | Incrociato |
| Router Aziendale | G0/1 | Switch Remoto | Fa1/1 | Dritto |
| Switch Remoto | Fa0/1 | Web Server | Fa0 | Dritto |

### 1.3 — Configurazione dispositivi finali

**PC-Home Worker**: IP `192.168.0.2` / SM `255.255.255.0` / GW `192.168.0.1`

**Server aziendale**:
- IP `172.16.0.2` / SM `255.255.0.0` / GW `172.16.0.1`
- Attiva **HTTP**: Services → HTTP → ON
- Modifica `index.html`:
```html
<html><body>
  <h1>Server Aziendale Interno</h1>
  <p>Visibile solo dalla rete aziendale o tramite VPN</p>
</body></html>
```

---

## 📋 Step 2 — Configurazione base dei router

Prima di configurare il protocollo IPsec dobbiamo installare il software securityk9 sul Router Aziendale:

```
Router> enable
Router# configure terminal
Router(config)# hostname RouterVPN
RouterA(config)# licence boot module c1900 technology-ackage security k9
RouterA# wr mem
RouterA# reload

```

Se l'installazione è andata a buon fine il comando 
```
RouterA#show version  
RouterB#show version 
```

dovrebbe mostrare:

Technology Package License Information for Module:'c1900'
```
----------------------------------------------------------------
Technology    Technology-package          Technology-package
              Current       Type          Next reboot
-----------------------------------------------------------------
ipbase        ipbasek9      Permanent     ipbasek9
security      securityk9    Evaluation    securityk9
data          disable       None          None
```

### Router Internet

```

! Interfaccia verso Router VPN
Router> enable
Router# configure terminal
Router(config)# hostname RouterInternet
RouterInternet(config)# interface Fa0/0
RouterInternet(config-if)# ip address 98.100.25.25 255.0.0.0
RouterInternet(config-if)# no shutdown
RouterInternet(config-if)# exit

! Interfaccia verso la rete del PC remoto
RouterInternet(config)# interface Se3/0
RouterInternet(config-if)# ip address 85.120.2.28 255.0.0.0
RouterInternet(config-if)# no shutdown
RouterInternet(config-if)# exit

! Rotte dinamiche con RIP
RouterInternet(config)# router rip
RouterInternet(config)# network 85.0.0.0
RouterInternet(config)# network 98.0.0.0

RouterInternet(config)# end
RouterInternet# write memory
```

### Router Domestico

```

! Interfaccia verso Router Internet
Router> enable
Router# configure terminal
Router(config)# hostname RouterLAN
RouterLAN(config)# interface Fa0/0
RouterLAN(config-if)# ip address 192.168.0.1 255.255.255.0
RouterLAN(config-if)# no shutdown
RouterLAN(config-if)# exit

! Interfaccia verso Router Internet
RouterInternet(config)# interface Se2/0
RouterInternet(config-if)# ip address 85.120.2.27 255.0.0.0
RouterInternet(config-if)# no shutdown
RouterInternet(config-if)# exit

! Rotte dinamiche con RIP
RouterInternet(config)# router rip
RouterInternet(config)# network 85.0.0.0
RouterInternet(config)# network 192.168.0.0

RouterInternet(config)# end
RouterInternet# write memory
```

### Router VPN Gateway — configurazione base

```

! Interfaccia LAN verso la rete aziendale
RouterVPN(config)# interface G0/1
RouterVPN(config-if)# ip address 172.16.0.1 255.255.0.0
RouterVPN(config-if)# no shutdown
RouterVPN(config-if)# exit

! Interfaccia WAN verso Internet
RouterVPN(config)# interface G0/1
RouterVPN(config-if)# ip address 98.100.25.24 255.0.0.0
RouterVPN(config-if)# no shutdown
RouterVPN(config-if)# exit

! Rotte dinamiche con RIP
RouterInternet(config)# router rip
RouterInternet(config)# network 98.0.0.0
RouterInternet(config)# network 172.16.0.0

RouterVPN(config)# end
RouterVPN# write memory
```

### Verifica connettività base

Dal **PC-REMOTO**: `Desktop → Command Prompt`
```
ping 98.100.25.24    ! → Router VPN WAN: deve rispondere ✅
```

---

## 📋 Step 3 — Configurazione del server VPN (EasyVPN Server) sul RouterVPN



La VPN Remote Access su Cisco IOS si basa su **EasyVPN** — una versione semplificata che centralizza tutta la configurazione sul server.

### Passo 1 — Pool di indirizzi IP per i client VPN

```
! Definisce il range di IP che il server VPN assegnerà ai client remoti
! Questi IP permettono al client di "appartenere" alla rete aziendale
RouterVPN(config)# ip local pool VPN-pool 172.16.32.101 172.16.32.200
! "VPN-pool" = nome del pool (riferimento nei passi successivi)
! 172.16.32.101 = primo IP assegnabile
! 172.16.32.200 = ultimo IP assegnabile
! Supporta fino a 100 client VPN contemporanei
```

### Passo 2 — Configurazione AAA per autenticazione locale

```
! AAA (Authentication Authorization Accounting)
! Definisce come il server VPN autentica gli utenti
RouterVPN(config)# aaa new-model
! Abilita il modello AAA

RouterVPN(config)# aaa authentication login VPN-client local
! "VPN-client" = nome della lista di autenticazione
! "local" = usa il database locale del router (non RADIUS/TACACS)

RouterVPN(config)# aaa authorization network VPN-ATS local
! Autorizzazione di rete tramite database locale

! Crea gli utenti VPN nel database locale
RouterVPN(config)# username mario secret mario
RouterVPN(config)# username luigi   secret luigi
! Questi sono le credenziali PERSONALI di ciascun utente VPN
! (diversi dalle credenziali di gruppo definite al Passo 3)


```

### Passo 3 — ISAKMP Policy (Fase 1)

```
RouterVPN(config)# crypto isakmp policy 1
RouterVPN(config-isakmp)# encryption aes 256
! Cifratura del canale IKE di controllo

RouterVPN(config-isakmp)# hash sha
! Hash per l'integrità dei messaggi IKE

RouterVPN(config-isakmp)# authentication pre-share
! Autenticazione con chiave pre-condivisa
! In ambienti enterprise si usano certificati digitali (rsa-sig)

RouterVPN(config-isakmp)# group 5
! Gruppo Diffie-Hellman 2048 bit

RouterVPN(config-isakmp)# lifetime 7200
! SA IKE dura 2 ore (7200 secondi)
! Più breve rispetto alla Site-to-Site (24h) perché le sessioni remote
! sono in genere più corte

RouterVPN(config-isakmp)# exit
```

### Passo 4 — Gruppo ISAKMP con credenziali VPN

```
! Il "gruppo" definisce le credenziali e i parametri per i client remoti
! Un client VPN si autentica fornendo il nome del gruppo e la chiave
RouterVPN(config)# crypto isakmp client configuration group VPN-HOME
! "VPN-HOME" = nome del gruppo VPN
! Il client VPN dovrà inserire esattamente questo nome

RouterVPN(config-isakmp-group)# key homevpngroupsecret
! Chiave di gruppo (Group Password): il client deve conoscerla per autenticarsi
! È una prima autenticazione "di gruppo" — non identifica il singolo utente

RouterVPN(config-isakmp-group)# pool VPN-pool
! Assegna al gruppo il pool di IP definito al Passo 1
! I client di questo gruppo riceveranno un IP da questo pool

RouterVPN(config-isakmp-group)# exit
```


### Passo 5 — Creazione policy per isakmp (IKE) per stabilire la SA

```
RouterVPN(config)# crypto ipsec transform-set VPNipsec esp-aes esp-sha-hmac

! Crypto Map DINAMICA — usata per client la cui IP non è noto in anticipo
! A differenza della Site-to-Site (IP fisso), i client remoti hanno IP variabile
RouterVPN(config)# crypto dynamic-map VPNdynset 10
RouterVPN(config-crypto-map)# set transform-set VPNipsec
RouterVPN(config-crypto-map)# reverse-route
! reverse-route: aggiunge automaticamente la rotta verso il client nel routing table
RouterVPN(config-crypto-map)# exit

! Crypto Map STATICA per il client
RouterVPN(config)# crypto map VPNstaticmap client configuration address respond
RouterVPN(config)# crypto map VPNstaticmap client authentication list VPN-client
RouterVPN(config)# crypto map VPNstaticmap isakmp authorization list VPN-HOME
RouterVPN(config)# crypto map VPNstaticmap 1 ipsec-isakmp dynamic VPNdynset
```


### Passo 6 — Applica la crypto map all'interfaccia WAN

```
RouterVPN(config)# interface G0/0
RouterVPN(config-if)# crypto map VPNstaticmap
! Attiva la VPN sull'interfaccia WAN
! Tutte le connessioni IPsec in arrivo vengono gestite da questa map

RouterVPN(config-if)# exit
RouterVPN(config)# end
RouterVPN# write memory
```

---

## 📋 Step 7 — Configurazione del client VPN sul PC-REMOTO

In Packet Tracer il client VPN si configura nel pannello del PC.

1. Clicca su **PC-REMOTO**
2. Vai su **Desktop → VPN**
3. Compila i campi:

| Campo | Valore |
|---|---|
| GROUPNAME | `VPN-HOME` |
| GROUP KEY | `homevpngroupsecret` |
| HOST | `98.100.25.24` (IP WAN del Router VPN) |
| Username | `mario` |
| Password | `mario` |


4. Clicca **Connect**

Se la configurazione è corretta, vedrai:
- **Status: Connected**
- Il PC-REMOTO riceverà un IP nel range 172.16.32.101–172.16.32.200

> ⚠️ **Nota Packet Tracer**: la versione del client VPN integrato in PT può variare. In alcune versioni si usa Desktop → VPN Client, in altre le impostazioni sono in Desktop → IP Configuration. Consulta la versione specifica di PT in uso.

---

## 📋 Step 8 — Verifica della connessione VPN

### Verifica sul server VPN

```
! Mostra le sessioni VPN attive
RouterVPN# show crypto isakmp sa
```

Output atteso:
```
dst                 src         state           conn-id  slot  status
192.168.0.2     98.100.25.24    QM_IDLE           1063    0    ACTIVE
```

```
! Mostra le SA IPsec (Fase 2) attive
RouterVPN# show crypto ipsec sa
```




### Verifica dal PC-REMOTO

Dopo la connessione VPN, dal **PC-REMOTO**: `Desktop → Command Prompt`

```
ipconfig
! Mostra la configurazione IP: dovresti vedere sia l'IP reale (192.168.0.2)
! che l'IP VPN assegnato (172.16.32.x)

ping 172.16.0.2
! → Server aziendale: deve rispondere ✅
! Questo ping usa il tunnel VPN

```

Dal **PC-REMOTO**: `Desktop → Web Browser`
```
http://172.16.0.2
! La pagina del server aziendale deve apparire ✅
! Questo è il test definitivo: il client remoto accede alla rete interna
```


---



## 📋 Riepilogo comandi di configurazione server VPN

```
! ── POOL IP PER CLIENTI VPN ──────────────────────────────────────────
ip local pool <NOME-POOL> <IP-START> <IP-END>

! ── AAA E UTENTI ──────────────────────────────────────────────────────
aaa new-model
aaa authentication login <LISTA-AUTH> local
aaa authorization network <LISTA-AUTHZ> local
username <UTENTE> secret <PASSWORD>

! ── ISAKMP POLICY ─────────────────────────────────────────────────────
crypto isakmp policy <PRIORITA>
 encryption aes 256
 hash sha
 authentication pre-share
 group 5
 lifetime 7200

! ── GRUPPO VPN CON CREDENZIALI ────────────────────────────────────────
crypto isakmp client configuration group <NOME-GRUPPO>
 key <CHIAVE-GRUPPO>
 pool <NOME-POOL>

! ── ACL SPLIT TUNNELING ─────────────────────────────────────────────── opzionale
access-list <NUM-ACL> permit ip <POOL-VPN> <WILDCARD> <LAN-AZIENDALE> <WILDCARD>

! ── TRANSFORM SET ─────────────────────────────────────────────────────
crypto ipsec transform-set <NOME-TS> esp-aes esp-sha-hmac
 mode tunnel

! ── CRYPTO MAP DINAMICA ───────────────────────────────────────────────
crypto dynamic-map <NOME-DYNMAP> 10
 set transform-set <NOME-TS>
 reverse-route

! ── CRYPTO MAP STATICA ───────────────────────────────────────────────
crypto map VPNstaticmap client configuration address respond
crypto map VPNstaticmap client authentication list <LISTA>
crypto map VPNstaticmap isakmp authorization list <LISTA>
crypto map VPNstaticmap 1 ipsec-isakmp dynamic VPNdynset



! ── APPLICAZIONE INTERFACCIA ──────────────────────────────────────────
interface <INTERFACCIA-WAN>
 crypto map <NOME-MAP>

! ── VERIFICA ──────────────────────────────────────────────────────────
show crypto isakmp sa
show crypto ipsec sa
show ip local pool <NOME-POOL>
show crypto isakmp client configuration group <NOME-GRUPPO>
```

---

## 📋 Domande di verifica

1. Nella VPN Remote Access hai configurato un **pool di indirizzi** (172.16.32.101–200) diverso dalla LAN aziendale (172.16.0.0/16). Perché è necessario usare una rete distinta invece di assegnare IP dalla stessa subnet della LAN?

2. Qual è la differenza tra le **credenziali di gruppo** (`key xxxxx`) e le **credenziali utente** (`username / secret`)? A quale scopo serve ciascuna?

3. Cos'è il **split tunneling** ed è implementato attraverso l'ACL? Modifica la configurazione per abilitarlo e descrivi i pro e contro delle due scelte.

4. Il comando `show ip local pool xxxxx` mostra `In use: 0` anche dopo che il client si è connesso. Elenca almeno tre possibili cause e come diagnosticarle.

5. Confronta la VPN **Site-to-Site** configurata nel laboratorio precedente con questa **Remote Access**: quali componenti di configurazione sono comuni a entrambe? Quali sono presenti solo in una delle due?

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
