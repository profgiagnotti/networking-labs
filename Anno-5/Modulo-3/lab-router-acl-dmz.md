# 🔬 Lab B — ACL su router con DMZ, rete interna e rete esterna

![Materia](https://img.shields.io/badge/materia-Networking-3DE8A0?style=flat-square)
![Anno](https://img.shields.io/badge/anno-5-3DE8A0?style=flat-square)
![Modulo](https://img.shields.io/badge/modulo-3-3DE8A0?style=flat-square)
![Livello](https://img.shields.io/badge/livello-avanzato-FF5C5C?style=flat-square)
![Tool](https://img.shields.io/badge/tool-Packet%20Tracer-1BA0D7?style=flat-square&logo=cisco)

> Laboratorio pratico su ACL estese, DMZ e routing su router Cisco IOS — Anno 5, Modulo 3  
> 🌐 Teoria collegata: [profgiagnotti.it — L03/L04 ACL standard ed estese](https://profgiagnotti.it/corsi/networking/)

---

## 🎯 Obiettivi

Al termine di questo laboratorio sarai in grado di:

- ✅ Costruire una topologia con Router A (aziendale), Router B (Internet) e tre segmenti di rete: DMZ, LAN interna e rete esterna
- ✅ Configurare il **routing statico** tra tutte le reti
- ✅ Scrivere e applicare **ACL estese** per controllare il traffico tra DMZ, LAN interna e rete esterna
- ✅ Usare la keyword **`established`** per gestire le risposte TCP senza aprire connessioni non richieste
- ✅ Verificare che i server in DMZ siano raggiungibili dall'esterno e che la rete interna sia protetta

---

## 🗺️ Topologia di rete

```
┌──────────────────────────────────────────────────────────────┐
│                      RETE AZIENDALE                          │
│                                                              │
│  ┌─────────────────────────┐   ┌──────────────────────────┐  │
│  │    DMZ 192.168.0.0/24   │   │  INTERNA 192.168.1.0/24  │  │
│  │                         │   │                          │  │
│  │  [www.miosito.com]      │   │  [PC1] 192.168.1.3       │  │
│  │   192.168.0.2           │   │  [www.mioftp.com]        │  │
│  │  [www.gmail.com]        │   │   192.168.1.2            │  │
│  │   192.168.0.3           │   │         |                │  │
│  │         |               │   │    [Switch S]            │  │
│  │    [Switch2]            │   │    Fa0/1                 │  │
│  │    Fa2/1  Fa1/1         │   │    Fa1/1 Fa2/1           │  │
│  └──────┬──────────────────┘   └──────────┬───────────────┘  │
│         │ Fa0/0                           │ Fa1/0             │
│         └──────────[Router A]─────────────┘                  │
│                        │ Se2/0                               │
│                   100.0.0.1                                  │
└────────────────────────┼─────────────────────────────────────┘
                         │ 100.0.0.2 (Se2/0)
                    [Router B]
                      Fa0/0
                     8.0.0.1
                         │
                    [Switch0]
              ┌──────────┼──────────────┐
              │          │              │
         [PC est.]  [google.com]  [DNS Server]  [DHCP Server]
          8.0.0.10    8.0.0.2       8.0.0.3       8.0.0.4

              RETE ESTERNA 8.0.0.0/8
```

---

## 📋 Piano di indirizzamento

| Dispositivo | Interfaccia | Indirizzo IP | Subnet Mask | Gateway |
|---|---|---|---|---|
| **www.miosito.com** (DMZ) | Fa0 | 192.168.0.2 | 255.255.255.0 | 192.168.0.1 |
| **www.gmail.com** (DMZ) | Fa0 | 192.168.0.3 | 255.255.255.0 | 192.168.0.1 |
| **PC1** (LAN interna) | Fa0 | 192.168.1.3 | 255.255.255.0 | 192.168.1.1 |
| **www.mioftp.com** (LAN interna) | Fa0 | 192.168.1.2 | 255.255.255.0 | 192.168.1.1 |
| **PC esterno** | Fa0 | 8.0.0.10 | 255.0.0.0 | 8.0.0.1 |
| **google.com** (server esterno) | Fa0 | 8.0.0.2 | 255.0.0.0 | 8.0.0.1 |
| **DNS Server** (rete esterna) | Fa0 | 8.0.0.3 | 255.0.0.0 | 8.0.0.1 |
| **DHCP Server** (rete esterna) | Fa0 | 8.0.0.4 | 255.0.0.0 | 8.0.0.1 |
| **Router A** — verso DMZ | Fa0/0 | 192.168.0.1 | 255.255.255.0 | — |
| **Router A** — verso LAN | Fa1/0 | 192.168.1.1 | 255.255.255.0 | — |
| **Router A** — verso Router B | Se2/0 | 100.0.0.1 | 255.0.0.0 | — |
| **Router B** — verso Router A | Se2/0 | 100.0.0.2 | 255.0.0.0 | — |
| **Router B** — verso rete esterna | Fa0/0 | 8.0.0.1 | 255.0.0.0 | — |

---

## 📋 Politica di sicurezza — cosa vogliamo ottenere

Prima di scrivere qualsiasi ACL, è fondamentale definire chiaramente la **politica di sicurezza**:

| Traffico | Permesso? | Motivo |
|---|---|---|
| PC esterno → www.miosito.com (HTTP) | ✅ Sì | Server web pubblico in DMZ |
| PC esterno → www.gmail.com (HTTP/SMTP) | ✅ Sì | Server mail pubblico in DMZ |
| PC esterno → www.mioftp.com (FTP) | ❌ No | Server FTP è interno, non esposto |
| PC esterno → PC1 | ❌ No | Host interni non raggiungibili |
| PC1 → google.com (HTTP) | ✅ Sì | Navigazione Internet dalla LAN |
| PC1 → DMZ | ✅ Sì | LAN può accedere alla DMZ |
| PC1 → www.mioftp.com (FTP) | ✅ Sì | Accesso FTP dalla rete interna |
| DMZ → LAN interna | ❌ No | I server DMZ non devono accedere alla LAN |
---

## 📋 Step 1 — Costruzione della topologia in Packet Tracer

### 1.1 — Dispositivi da inserire

| Dispositivo | Modello PT | Quantità |
|---|---|---|
| Router aziendale (Router A) | Router-PT o 2911 | 1 |
| Router Internet (Router B) | Router-PT o 2911 | 1 |
| Switch DMZ (Switch2) | 2960-24TT | 1 |
| Switch LAN (Switch S) | 2960-24TT | 1 |
| Switch esterno (Switch0) | 2960-24TT | 1 |
| Server www.miosito.com | Server-PT | 1 |
| Server www.gmail.com | Server-PT | 1 |
| Server www.mioftp.com | Server-PT | 1 |
| Server google.com | Server-PT | 1 |
| DNS Server | Server-PT | 1 |
| DHCP Server | Server-PT | 1 |
| PC1 (LAN interna) | PC-PT | 1 |
| PC esterno | PC-PT | 1 |

### 1.2 — Connessioni (cavi dritti — straight-through)

| Da | Porta | A | Porta |
|---|---|---|---|
| www.miosito.com | Fa0 | Switch2 (DMZ) | Fa0/1 |
| www.gmail.com | Fa0 | Switch2 (DMZ) | Fa0/2 |
| Switch2 (DMZ) | Fa2/1 | Router A | Fa0/0 |
| PC1 | Fa0 | Switch S (LAN) | Fa1/1 |
| www.mioftp.com | Fa0 | Switch S (LAN) | Fa2/1 |
| Switch S (LAN) | Fa0/1 | Router A | Fa1/0 |
| google.com | Fa0 | Switch0 (esterno) | Fa0/1 |
| DNS Server | Fa0 | Switch0 (esterno) | Fa0/2 |
| DHCP Server | Fa0 | Switch0 (esterno) | Fa0/3 |
| PC esterno | Fa0 | Switch0 (esterno) | Fa0/4 |
| Switch0 | Fa3/1 | Router B | Fa0/0 |

### 1.3 — Connessione seriale Router A ↔ Router B

| Da | Porta | A | Porta |
|---|---|---|---|
| Router A | Se2/0 | Router B | Se2/0 |

> 📌 Per i router-PT in Packet Tracer usa un **cavo seriale DCE/DTE**. Il router che funge da DCE deve avere il comando `clock rate` configurato (vedi Step 2).

---

## 📋 Step 2 — Configurazione di Router A (router aziendale)

Router A gestisce le tre interfacce: verso la DMZ, verso la LAN interna e verso Internet (Router B).

```
Router> enable
Router# configure terminal
Router(config)# hostname RouterA

! ─────────────────────────────────────────────────
! INTERFACCE
! ─────────────────────────────────────────────────

! Interfaccia verso la DMZ (192.168.0.0/24)
RouterA(config)# interface FastEthernet0/0
RouterA(config-if)# ip address 192.168.0.1 255.255.255.0
RouterA(config-if)# description Interfaccia-DMZ
RouterA(config-if)# no shutdown
RouterA(config-if)# exit

! Interfaccia verso la rete interna (192.168.1.0/24)
RouterA(config)# interface FastEthernet1/0
! Dobbiamo consentire al Server DHCP esterno alla LAN di configurare i dispositivi interni alla LAN
RouterA(config-if)# ip helper-address 8.0.0.4
RouterA(config-if)# ip address 192.168.1.1 255.255.255.0
RouterA(config-if)# description Interfaccia-LAN-Interna
RouterA(config-if)# no shutdown
RouterA(config-if)# exit

! Interfaccia seriale verso Router B
RouterA(config)# interface Serial2/0
RouterA(config-if)# ip address 100.0.0.1 255.0.0.0
RouterA(config-if)# description Collegamento-verso-Internet
RouterA(config-if)# no shutdown
RouterA(config-if)# exit

! ─────────────────────────────────────────────────
! ROUTING DINAMICO RIPv1 (no subnetting) (per semplicità)
! ─────────────────────────────────────────────────

! Annunciamo le reti adiacenti
RouterA(config)# router rip
RouterA(config-rip)# network 192.168.0.0
RouterA(config-rip)# network 192.168.1.0
RouterA(config-rip)# network 100.0.0.0
RouterA(config-rip)# exit

RouterA(config)# end
RouterA# write memory
```

### Verifica Router A

```
RouterA# show ip interface brief
RouterA# show ip route
```

Devranno comparire le rotte `C` (verso le reti direttamente connesse).

---

## 📋 Step 3 — Configurazione di Router B (router Internet)

Router B simula Internet. Conosce tutte le reti e instrada il traffico correttamente.

```
Router> enable
Router# configure terminal
Router(config)# hostname RouterB

! Interfaccia seriale verso Router A
RouterB(config)# interface Serial2/0
RouterB(config-if)# ip address 100.0.0.2 255.0.0.0
RouterB(config-if)# description Collegamento-verso-RouterA
! Se questo router è il DCE del cavo seriale, serve il clock rate
RouterB(config-if)# clock rate 64000
RouterB(config-if)# no shutdown
RouterB(config-if)# exit

! Interfaccia verso la rete esterna (8.0.0.0/8)
RouterB(config)# interface FastEthernet0/0
RouterB(config-if)# ip address 8.0.0.1 255.0.0.0
RouterB(config-if)# description Rete-Esterna
RouterB(config-if)# no shutdown
RouterB(config-if)# exit

! ─────────────────────────────────────────────────
! ROUTING DINAMICO RIP (per semplicità)
! Router B deve sapere come raggiungere la DMZ
! e la LAN interna (via Router A)
! ─────────────────────────────────────────────────

! Annunciamo le reti adiacenti
RouterB(config)# router rip
RouterB(config-rip)# network 8.0.0.0
RouterA(config-rip)# network 100.0.0.0
RouterA(config-rip)# exit

RouterB(config)# end
RouterB# write memory
```

### Verifica Router B

```
RouterB# show ip route
```

Devono comparire le due rotte `C` (verso le reti direttamente connesse) 
e le due rotte `R` (192.168.0.0 e 192.168.1.0) raggiungibili con RIP

---

## 📋 Step 4 — Configurazione dei dispositivi finali

### Server www.miosito.com (DMZ)

**Config → FastEthernet0:**
```
IP: 192.168.0.2 / SM: 255.255.255.0 / GW: 192.168.0.1 / DNS: 8.0.0.3
```
**Services → HTTP → ON**

Modifica `index.html`:
```html
<!DOCTYPE html>
<html>
<body>
  <h1>www.miosito.com</h1>
  <p>Server web aziendale in DMZ - 192.168.0.2</p>
</body>
</html>
```

### Server www.gmail.com (DMZ — simula server mail)

**Config → FastEthernet0:**
```
IP: 192.168.0.3 / SM: 255.255.255.0 / GW: 192.168.0.1 / DNS: 8.0.0.3
```
**Services → HTTP → ON** 

Modifica `index.html`:
```html
<!DOCTYPE html>
<html>
<body>
  <h1>www.gmail.com (simulato)</h1>
  <p>Server mail in DMZ - 192.168.0.3</p>
</body>
</html>
```
 **Sevices → EMAIL → ON** per simulare SMTP:

```
 Domain name -> gmail.com ->set
 User setup -> Userename:User1 Password:User1
 User setup -> Userename:User2 Password:User2
```

### Server www.mioftp.com (LAN interna)

**Config → FastEthernet0:**
```
IP: 192.168.1.2 / SM: 255.255.255.0 / GW: 192.168.1.1 / DNS: 8.0.0.3 / DNS: 8.0.0.3
```
**Services → FTP → ON**

Aggiungi un utente FTP:
- Username: `studente` / Password: `studente123`
- Permessi: Read, Write, Delete, Rename, List ✅

### Server google.com (rete esterna)

**Config → FastEthernet0:**
```
IP: 8.0.0.2 / SM: 255.0.0.0 / GW: 8.0.0.1 / DNS: 8.0.0.3
```
**Services → HTTP → ON**

Modifica `index.html`:
```html
<!DOCTYPE html>
<html>
<body>
  <h1>google.com (simulato)</h1>
  <p>Server esterno - 8.0.0.2</p>
</body>
</html>
```

### DNS Server (rete esterna)

**Config → FastEthernet0:**
```
IP: 8.0.0.3 / SM: 255.0.0.0 / GW: 8.0.0.1 / DNS: 8.0.0.3
```
**Services → DNS → ON**

Aggiungi i record DNS:

| Name | Type | Address |
|---|---|---|
| www.miosito.com | A Record | 192.168.0.2 |
| www.gmail.com | A Record | 192.168.0.3 |
| www.mioftp.com | A Record | 192.168.1.2 |
| gmail.com | CNAME | www.gmail.com |

### DHCP Server (rete esterna)

**Config → FastEthernet0:**
```
IP: 8.0.0.4 / SM: 255.0.0.0 / GW: 8.0.0.1 / DNS: 8.0.0.3
```
**Services → DHCP → ON**:

```
!DHCP per dispositivi della rete 8.0.0.0
Pool Name: serverPool / GW: 8.0.0.1 / DNS: 8.0.0.3 / Start IP: 8.0.0.10 / SM: 255.0.0.0 / Maximum Number of Users: 512
!DHCP per dispositivi della rete 192.168.1.0
Pool Name: serverPool2 / GW: 192.168.1.1 / DNS: 8.0.0.3 / Start IP: 192.168.1.10 / SM: 255.255.255.0 / Maximum Number of Users: 246
```

### PC1 (LAN interna)

**Desktop → IP Configuration:**
```
Inizialmente configuriamo il dispositivo in modo statico. Poi testeremo il DHCP
IP: 192.168.1.3 / SM: 255.255.255.0 / GW: 192.168.1.1 / DNS: 8.0.0.3
```

### PC esterno

**Desktop → IP Configuration:**
```
Inizialmente configuriamo il dispositivo in modo statico. Poi testeremo il DHCP
IP: 8.0.0.10 / SM: 255.0.0.0 / GW: 8.0.0.1 / DNS: 8.0.0.3
```

---

## 📋 Step 5 — Test di connettività base (senza ACL)

Prima di applicare le ACL, verifica che il routing funzioni correttamente. Tutti i ping devono rispondere.

```
! Dal PC1 — verifica raggiungibilità
ping 192.168.0.2        ! → www.miosito.com in DMZ
ping 8.0.0.2            ! → google.com esterno
ping 192.168.1.2        ! → www.mioftp.com (stessa rete)

! Dal PC esterno — verifica raggiungibilità
ping 192.168.0.2        ! → www.miosito.com in DMZ
ping 192.168.1.2        ! → www.mioftp.com (deve funzionare PRIMA delle ACL)
ping 192.168.1.3        ! → PC1 (deve funzionare PRIMA delle ACL)
```

> 📌 Se qualche ping non risponde già in questa fase, il problema è nel **routing**, non nelle ACL. Risolvi prima il routing e poi procedi con le ACL.

---


## 📋 Step 6 — Configurazione delle ACL estese

Questa è la parte centrale del laboratorio. Configuriamo una ACL:

- **100**: applicata `in` sull'interfaccia Se2/0 — filtra il traffico che arriva da Internet verso la rete aziendale

### ACL-ESTERNA — traffico da Internet verso la rete aziendale

```

#### ── PERMESSI DHCP ────────────────────────────────────
```
! Dobbiamo permettere l’autoconfigurazione e aprire al traffico le porte (67 e 68) su cui 
!lavora il protocollo 

RouterA(config)# access-list 100 remark === DHCP ===
RouterA(config)access-list 100 permit udp any any eq 67
RouterA(config)access-list 100 permit udp any any eq 68


```
#### ── PERMESSI DNS ─────────────────────────

! Quando il DNS risponde:
! · SORGENTE → porta 53
! · DESTINAZIONE → porta ALTA casuale (>1023), NON 53
! Quindi il pacchetto reale è:
! UDP src port 53 ---> dst port 1025 / 1030 / 49152 ...
! Inoltre non funziona estabilished (lavora su UDP)
! In definitiva dobbiamo consentire:
! UDP da 8.0.0.3 porta 53 verso porte maggiori rispetto alle well-known ports

RouterA(config)#access-list 100 remark === DNS (RISPOSTE) ===
RouterA(config)#access-list 100 permit udp host 8.0.0.3 eq 53 192.168.1.0 0.0.0.255 gt 1023
```

```
#### ── PERMESSI DMZ ─────────────────────────
! Dobbiamo consentire l'accesso pubblico per web e mail server DMZ. In realtà basterebbe la regola 
!sulla porta 80 (HTTP), quella sulla porta 110 (POP3) e quella sulla porta 25 (SMTP) ma a scopo didattico
!permettiamo l’accesso attraverso la porta 443 (HTTPS), 143 (IMAP)

RouterA(config)#access-list 100 permit tcp any host 192.168.0.2 eq 80
RouterA(config)#access-list 100 permit tcp any host 192.168.0.2 eq 443
RouterA(config)#access-list 100 permit tcp any host 192.168.0.3 eq 25
RouterA(config)#access-list 100 permit tcp any host 192.168.0.3 eq 110
RouterA(config)#access-list 100 permit tcp any host 192.168.0.3 eq 143

! Permette i messaggi ICMP unreachable (necessari per MTU discovery)
RouterA(config-ext-nacl)# permit icmp any any unreachable
```

```
#### ── BLOCCO ESPLICITO FTP DALL' ESTERNO e PERMESSI FTP DALL'INTERNO ─────────────────────────────────────────

! NOTA: con Packet Tracer o server FTP passivo, la porta 20 non viene usata direttamente 
! verso i client della LAN, quindi non serve filtrarla nella ACL interna

! Nega TUTTO il traffico non autorizzato verso il server FTP

RouterA(config)#deny tcp any host 192.168.1.2 eq 21

! Permetti il traffico dalla rete interna verso il server FTP

RouterA(config)#permit tcp 192.168.1.0 0.0.0.255 host 192.168.1.2 eq 21
```



```

---

## 📋 Step 8 — Verifica delle ACL

```
RouterA# show access-lists
RouterA# show access-lists ACL-ESTERNA
RouterA# show access-lists ACL-DMZ
RouterA# show ip interface Serial2/0
RouterA# show ip interface FastEthernet0/0
```

L'output di `show access-lists` mostra le regole con i contatori dei match. Inizialmente tutti sono 0 — crescono man mano che esegui i test.

---

## 📋 Step 9 — Test di connettività (con ACL attive)

Esegui ogni test e confronta il risultato con quello atteso.

### Test 1 — PC esterno → www.miosito.com ✅ (deve funzionare)

Dal **PC esterno** (8.0.0.10): `Desktop → Web Browser`
```
http://192.168.0.2
```
oppure, se il DNS è configurato:
```
http://www.miosito.com
```

**Risultato atteso:** la pagina HTML del server appare nel browser.

**Cosa verifica:** l'ACL-ESTERNA permette TCP porta 80 verso 192.168.0.2.

---

### Test 2 — PC esterno → www.gmail.com ✅ (deve funzionare)

Dal **PC esterno**: `Desktop → Web Browser`
```
http://192.168.0.3
```

**Risultato atteso:** la pagina del server appare.

---

### Test 3 — PC esterno → www.mioftp.com ❌ (deve fallire)

Dal **PC esterno**: `Desktop → Command Prompt`
```
ftp 192.168.1.2
```

**Risultato atteso:** connessione rifiutata o timeout — il server FTP è nella LAN interna, non accessibile dall'esterno.

**Cosa verifica:** l'ACL-ESTERNA non ha regole che permettono il traffico verso 192.168.1.0/24 (solo `established` per le risposte).

---

### Test 4 — PC esterno → PC1 ❌ (deve fallire)

Dal **PC esterno**: `Desktop → Command Prompt`
```
ping 192.168.1.3
```

**Risultato atteso:** nessuna risposta (Request timeout).

---

### Test 5 — PC1 → google.com ✅ (deve funzionare)

Dal **PC1** (192.168.1.3): `Desktop → Web Browser`
```
http://8.0.0.2
```

**Risultato atteso:** la pagina di google.com simulato appare.

**Cosa verifica:** il PAT traduce l'IP privato del PC1 e l'ACL-ESTERNA permette le risposte TCP con `established`.

---

### Test 6 — PC1 → www.mioftp.com FTP ✅ (deve funzionare)

Dal **PC1**: `Desktop → Command Prompt`
```
ftp 192.168.1.2
```

Inserisci le credenziali: `studente` / `studente123`

**Risultato atteso:** accesso FTP riuscito — prompt `ftp>`.

```
ftp> dir
ftp> quit
```

**Cosa verifica:** il traffico all'interno della stessa rete (LAN interna) non è filtrato dalle ACL. Le ACL filtrano solo il traffico che transita attraverso le interfacce configurate.

---

### Test 7 — PC1 → www.miosito.com (DMZ) ✅ (deve funzionare)

Dal **PC1**: `Desktop → Web Browser`
```
http://192.168.0.2
```

**Risultato atteso:** la pagina appare.

**Cosa verifica:** il traffico dalla LAN interna verso la DMZ non è filtrato da ACL-ESTERNA (che agisce solo su Se2/0) né da ACL-DMZ (che filtra solo il traffico che arriva dalla DMZ in direzione inbound su Fa0/0).

---

### Test 8 — www.miosito.com → LAN interna ❌ (deve fallire)

Apri la CLI del server **www.miosito.com** (in Packet Tracer i server hanno una scheda Desktop con Command Prompt):

`www.miosito.com → Desktop → Command Prompt`
```
ping 192.168.1.3
```

**Risultato atteso:** nessuna risposta.

**Cosa verifica:** l'ACL-DMZ blocca tutto il traffico dalla rete 192.168.0.0/24 verso la rete 192.168.1.0/24.

---

### Test 9 — PC1 → ping verso Internet ✅ (deve funzionare)

Dal **PC1**: `Desktop → Command Prompt`
```
ping 8.0.0.2
```

**Risultato atteso:** ping riuscito.

**Cosa verifica:** l'ACL-ESTERNA permette `icmp any any echo-reply` quindi le risposte ai ping arrivano correttamente.

---

### Test 10 — PC esterno → ping verso DMZ ✅ (verifica parziale)

Dal **PC esterno**:
```
ping 192.168.0.2
```

**Risultato atteso:** potrebbe fallire perché l'ACL-ESTERNA non ha una regola `permit icmp any host 192.168.0.2 echo`. Solo le `echo-reply` sono permesse.

Per permettere anche i ping verso la DMZ, aggiungi questa regola **prima** del `deny ip any any`:

```
RouterA(config)# ip access-list extended ACL-ESTERNA
RouterA(config-ext-nacl)# no deny ip any any log
RouterA(config-ext-nacl)# permit icmp any 192.168.0.0 0.0.0.255 echo
RouterA(config-ext-nacl)# deny ip any any log
RouterA(config-ext-nacl)# exit
```

> 📌 Su ACL con nome è possibile rimuovere singole ACE con `no <testo-ace>` e aggiungere nuove ACE senza riscrivere tutto — questo è uno dei vantaggi delle ACL con nome rispetto a quelle numeriche.

---

## 📋 Step 10 — Monitoraggio e debug

### Visualizza i contatori delle ACL

```
RouterA# show access-lists
```

Output esempio dopo i test:
```
Extended IP access list ACL-ESTERNA
    10 permit tcp any host 192.168.0.2 eq www (8 matches)
    20 permit tcp any host 192.168.0.2 eq 443 (0 matches)
    30 permit tcp any host 192.168.0.3 eq www (5 matches)
    40 permit tcp any host 192.168.0.3 eq smtp (0 matches)
    50 permit tcp any 192.168.1.0 0.0.0.255 established (24 matches)
    60 permit icmp any any echo-reply (6 matches)
    70 permit icmp any any unreachable (0 matches)
    80 deny ip any any log (3 matches)

Extended IP access list ACL-DMZ
    10 deny ip 192.168.0.0 0.0.0.255 192.168.1.0 0.0.0.255 log (0 matches)
    20 permit ip any any (12 matches)
```

I **contatori** sono essenziali per il debug: se una regola ha sempre 0 match ma dovrebbe averne, probabilmente c'è una regola più generale che la "intercetta" prima.

### Azzera i contatori per ricominciare i test

```
RouterA# clear ip access-list counters
```

### Visualizza la tabella NAT durante i test

```
RouterA# show ip nat translations
```

Output durante la navigazione di PC1:
```
Pro  Inside global   Inside local    Outside local   Outside global
tcp  100.0.0.1:1025  192.168.1.3:1025  8.0.0.2:80    8.0.0.2:80
```

---

## 📋 Step 11 — Aggiunta di una ACL standard (esercizio supplementare)

Come esercizio supplementare, aggiungi un'ACL **standard** per bloccare l'accesso al server FTP solo da un host specifico esterno alla LAN. Ricorda: le ACL standard vanno applicate **vicino alla destinazione**.

```
! Scenario: bloccare solo il PC esterno (8.0.0.10) dal server FTP
! Tutti gli altri host della rete interna possono accedere

RouterA(config)# ip access-list standard PROTEGGI-FTP
RouterA(config-std-nacl)# deny host 8.0.0.10
RouterA(config-std-nacl)# permit any
RouterA(config-std-nacl)# exit

! Applicazione vicino alla DESTINAZIONE (interfaccia LAN)
! in uscita verso la rete interna
RouterA(config)# interface FastEthernet1/0
RouterA(config-if)# ip access-group PROTEGGI-FTP out
RouterA(config-if)# exit
```

> ⚠️ Nota: questo scenario ha valore didattico ma in questo laboratorio il PC esterno è già bloccato dall'ACL-ESTERNA prima di arrivare qui. L'ACL standard è utile quando si vuole agire solo sull'IP sorgente senza considerare protocollo e porta.

---

## 📋 Riepilogo comandi di verifica

```
! ── INTERFACCE ─────────────────────────────────────────────
RouterA# show ip interface brief           ! stato di tutte le interfacce
RouterA# show ip interface Serial2/0       ! ACL applicate su Se2/0
RouterA# show ip interface FastEthernet0/0 ! ACL applicate su Fa0/0

! ── ROUTING ────────────────────────────────────────────────
RouterA# show ip route                     ! tabella di routing completa

! ── NAT ────────────────────────────────────────────────────
RouterA# show ip nat translations          ! traduzioni NAT attive
RouterA# show ip nat statistics            ! statistiche PAT
RouterA# clear ip nat translation *        ! azzera tutte le traduzioni

! ── ACL ────────────────────────────────────────────────────
RouterA# show access-lists                 ! tutte le ACL con match counter
RouterA# show access-lists ACL-ESTERNA     ! solo ACL-ESTERNA
RouterA# show access-lists ACL-DMZ         ! solo ACL-DMZ
RouterA# clear ip access-list counters     ! azzera i contatori
```

---

## 📋 Tabella riepilogativa dei test

Compila questa tabella dopo aver eseguito tutti i test:

| # | Test | Da | Verso | Porta | ACL che agisce | Risultato atteso | Risultato ottenuto |
|---|---|---|---|---|---|---|---|
| 1 | HTTP verso miosito | PC esterno | 192.168.0.2 | 80 | ACL-ESTERNA | ✅ OK | |
| 2 | HTTP verso gmail | PC esterno | 192.168.0.3 | 80 | ACL-ESTERNA | ✅ OK | |
| 3 | FTP verso mioftp | PC esterno | 192.168.1.2 | 21 | ACL-ESTERNA | ❌ BLOCCATO | |
| 4 | Ping verso PC1 | PC esterno | 192.168.1.3 | ICMP | ACL-ESTERNA | ❌ BLOCCATO | |
| 5 | HTTP verso google | PC1 | 8.0.0.2 | 80 | ACL-ESTERNA (risposta) | ✅ OK | |
| 6 | FTP verso mioftp | PC1 | 192.168.1.2 | 21 | nessuna | ✅ OK | |
| 7 | HTTP verso miosito | PC1 | 192.168.0.2 | 80 | nessuna | ✅ OK | |
| 8 | Ping verso PC1 | www.miosito.com | 192.168.1.3 | ICMP | ACL-DMZ | ❌ BLOCCATO | |
| 9 | Ping verso google | PC1 | 8.0.0.2 | ICMP | ACL-ESTERNA (reply) | ✅ OK | |

---

## 📋 Domande di verifica

1. Perché l'**ACL-ESTERNA** è applicata `in` sull'interfaccia **Se2/0** e non `out`? Cosa cambierebbe se la applicassimo `out` su Fa0/0 o Fa1/0?

2. La regola `permit tcp any 192.168.1.0 0.0.0.255 established` permette le risposte HTTP per i client LAN. Spiega tecnicamente perché un pacchetto SYN proveniente da un attaccante esterno **non corrisponde** a questa regola.

3. L'**ACL-DMZ** è applicata `in` su Fa0/0 (interfaccia DMZ). Perché non è stata applicata `out` su Fa1/0 (interfaccia LAN)? Il risultato sarebbe lo stesso? Ci sarebbero differenze di efficienza?

4. Perché le **ACL standard** vanno applicate vicino alla destinazione mentre le **ACL estese** vanno applicate vicino alla sorgente? Usa la topologia di questo laboratorio per fare un esempio concreto di cosa succederebbe se invertissimo questo principio.

5. Nel laboratorio hai configurato il **PAT** con `ip nat inside source list ... interface Serial2/0 overload`. Cosa significa `overload` e cosa succederebbe senza quella keyword?

6. Dopo aver applicato le ACL, i contatori di `show access-lists` mostrano 0 match per la regola `deny ip 192.168.0.0 0.0.0.255 192.168.1.0 0.0.0.255` dell'ACL-DMZ. Questo è normale o indica un problema? Come potresti verificare che la regola funzioni davvero?

---

## 📚 Risorse

- 🔗 [Cisco — Configuring IP Access Lists](https://www.cisco.com/c/en/us/support/docs/security/ios-firewall/23602-confaccesslists.html)
- 📄 [Cisco — NAT Configuration Guide IOS](https://www.cisco.com/c/en/us/support/docs/ip/network-address-translation-nat/13772-12.html)
- 🖧 [Cisco Packet Tracer — download gratuito](https://www.netacad.com/courses/packet-tracer)

---

## 🔗 Risorse correlate

- 🌐 **Sito:** [profgiagnotti.it](https://profgiagnotti.it)
- ▶️ **YouTube:** [youtube.com/@profgiagnotti](https://youtube.com/@profgiagnotti)
- 💬 **Discord:** [Unisciti alla community](https://discord.gg/profgiagnotti)

---

*Materiale a scopo educativo · Licenza MIT · Prof. Giagnotti*
