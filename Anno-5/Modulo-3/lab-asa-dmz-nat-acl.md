# 🔬 Lab A — Firewall ASA 5506 con DMZ, NAT e ACL

![Materia](https://img.shields.io/badge/materia-Networking-3DE8A0?style=flat-square)
![Anno](https://img.shields.io/badge/anno-5-3DE8A0?style=flat-square)
![Modulo](https://img.shields.io/badge/modulo-3-3DE8A0?style=flat-square)
![Livello](https://img.shields.io/badge/livello-avanzato-FF5C5C?style=flat-square)
![Tool](https://img.shields.io/badge/tool-Packet%20Tracer-1BA0D7?style=flat-square&logo=cisco)

> Laboratorio pratico su firewall ASA, DMZ, NAT e ACL — Anno 5, Modulo 3  
> 🌐 Teoria collegata: [profgiagnotti.it — L05 DMZ, NAT, PAT e sicurezza perimetrale](https://profgiagnotti.it/corsi/networking/)

---

## 🎯 Obiettivi

Al termine di questo laboratorio sarai in grado di:

- ✅ Costruire una topologia con firewall ASA 5506-X, DMZ, LAN e rete esterna in Packet Tracer
- ✅ Configurare le tre interfacce dell'ASA con security level appropriati
- ✅ Configurare il PAT dinamico per permettere agli host LAN e DMZ di accedere a Internet
- ✅ Configurare il NAT statico per rendere il web server in DMZ raggiungibile dall'esterno
- ✅ Scrivere e applicare ACL sull'interfaccia outside dell'ASA
- ✅ Verificare il funzionamento con ping e browser dal PC esterno e dai PC interni

---

## 🗺️ Topologia di rete

```
┌─────────────────────────────────────────────────────────────┐
│                        AZIENDA                              │
│                                                             │
│  ┌──────────────────┐           ┌──────────────────────┐    │
│  │       DMZ        │           │         LAN          │    │
│  │                  │           │                      │    │
│  │  [WebServer]     │           │  [PC1] 192.168.1.10  │    │
│  │  192.168.2.10    │           │  [PC2] 192.168.1.11  │    │
│  │       |          │           │  [SrvInt] 192.168.1.2│    │
│  │  [Switch1]       │           │       |              │    │
│  │       |          │           │  [Switch2]           │    │
│  │  Fa0/2           │           │  Fa0/1               │    │
│  └───────┬──────────┘           └────────┬─────────────┘    │
│          │ Gig1/1                        │ Gig1/2           │
│          └───────────[ASA 5506-X]────────┘                  │
│                           │ Gig1/3                          │
│                      150.10.0.1                             │
└───────────────────────────┼─────────────────────────────────┘
                            │ 150.10.0.2
                     [Router INTERNET]
                       Fa1/0 | Fa0/0
                         10.0.0.1
                            │
                        [Switch0]
                            │
                     [PC esterno]
                      10.0.0.2
```

---

## 📋 Piano di indirizzamento

| Dispositivo | Interfaccia | Indirizzo IP | Subnet Mask | Gateway | Note |
|---|---|---|---|---|---|
| WebServer (DMZ) | Fa0 | 192.168.2.10 | 255.255.255.0 | 192.168.2.1 | DNS: 192.168.2.1 |
| PC1 (LAN) | Fa0 | 192.168.1.10 | 255.255.255.0 | 192.168.1.1 | |
| PC2 (LAN) | Fa0 | 192.168.1.11 | 255.255.255.0 | 192.168.1.1 | |
| Server Interno (LAN) | Fa0 | 192.168.1.2 | 255.255.255.0 | 192.168.1.1 | |
| PC esterno | Fa0 | 10.0.0.2 | 255.0.0.0 | 10.0.0.1 | |
| ASA — interfaccia LAN | Gig1/2 | 192.168.1.1 | 255.255.255.0 | — | inside, SL 100 |
| ASA — interfaccia DMZ | Gig1/2 | 192.168.2.1 | 255.255.255.0 | — | dmz, SL 50 |
| ASA — interfaccia WAN | Gig1/3 | 150.10.0.1 | 255.255.255.0 | — | outside, SL 0 |
| Router Internet — verso ASA | Fa1/0 | 150.10.0.2 | 255.255.255.0 | — | |
| Router Internet — verso esterno | Fa0/0 | 10.0.0.1 | 255.0.0.0 | — | |

> 📌 L'IP pubblico dell'azienda (quello visibile da Internet) è **150.10.0.1** — l'interfaccia outside dell'ASA.

---

## 📋 Step 1 — Costruzione della topologia in Packet Tracer

### 1.1 — Dispositivi da inserire

| Dispositivo | Modello PT | Quantità |
|---|---|---|
| Firewall ASA | ASA 5506-X | 1 |
| Router Internet | Router-PT o 2911 | 1 |
| Switch DMZ | 2960-24TT | 1 |
| Switch LAN | 2960-24TT | 1 |
| Switch esterno | 2960-24TT | 1 |
| Server web (DMZ) | Server-PT | 1 |
| Server interno (LAN) | Server-PT | 1 |
| PC LAN | PC-PT | 2 |
| PC esterno | PC-PT | 1 |

### 1.2 — Connessioni con cavi dritti (straight-through)

| Da | Porta | A | Porta |
|---|---|---|---|
| WebServer | Fa0 | Switch1 (DMZ) | Fa0/1 |
| Switch1 (DMZ) | Fa0/2 | ASA | Gig1/1 |
| Switch2 (LAN) | Fa0/1 | ASA | Gig1/2 |
| PC1 | Fa0 | Switch2 (LAN) | Fa0/2 |
| PC2 | Fa0 | Switch2 (LAN) | Fa0/3 |
| Server Interno | Fa0 | Switch2 (LAN) | Fa0/4 |
| Router Internet | Fa0/0 | Switch0 (esterno) | Fa0/1 |
| PC esterno | Fa0 | Switch0 (esterno) | Fa0/2 |

### 1.3 — Connessione seriale o con cavo dritto ASA → Router

| Da | Porta | A | Porta |
|---|---|---|---|
| ASA | Gig1/3 | Router Internet | Fa1/0 |

> ⚠️ In Packet Tracer l'ASA 5506-X usa porte **GigabitEthernet** numerate diversamente dalla realtà fisica. Verifica le porte disponibili nel dispositivo che trovi nella tua versione di PT.

---

## 📋 Step 2 — Configurazione del Router Internet

Il Router Internet simula la rete pubblica. Ha due interfacce: una verso l'ASA e una verso la rete "esterna" dove si trova il PC esterno.

```
Router> enable
Router# configure terminal
Router(config)# hostname RouterInternet

! Interfaccia verso ASA (rete 150.10.0.0)
RouterInternet(config)# interface FastEthernet1/0
RouterInternet(config-if)# ip address 150.10.0.2 255.255.255.0
RouterInternet(config-if)# no shutdown
RouterInternet(config-if)# exit

! Interfaccia verso rete esterna (rete 10.0.0.0)
RouterInternet(config)# interface FastEthernet0/0
RouterInternet(config-if)# ip address 10.0.0.1 255.0.0.0
RouterInternet(config-if)# no shutdown
RouterInternet(config-if)# exit

! Rotta statica verso la rete DMZ (192.168.2.0)
! Necessaria per raggiungere il web server dall'esterno
RouterInternet(config)# ip route 192.168.2.0 255.255.255.0 150.10.0.1

! Rotta statica verso la rete LAN (192.168.1.0)
! Necessaria per le risposte ai client LAN
RouterInternet(config)# ip route 192.168.1.0 255.255.255.0 150.10.0.1

RouterInternet(config)# end
RouterInternet# write memory
```

### Verifica Router Internet

```
RouterInternet# show ip interface brief
RouterInternet# show ip route
```

L'output di `show ip route` deve mostrare le due rotte statiche verso 192.168.2.0 e 192.168.1.0 con next-hop 150.10.0.1.

---

## 📋 Step 3 — Configurazione del PC esterno e dei dispositivi finali

### PC esterno

Clicca su **PC esterno → Desktop → IP Configuration**:

| Campo | Valore |
|---|---|
| IP Address | 10.0.0.2 |
| Subnet Mask | 255.0.0.0 |
| Default Gateway | 10.0.0.1 |

### PC1 e PC2 (LAN)

Clicca su ogni PC → **Desktop → IP Configuration**:

| Campo | PC1 | PC2 |
|---|---|---|
| IP Address | 192.168.1.10 | 192.168.1.11 |
| Subnet Mask | 255.255.255.0 | 255.255.255.0 |
| Default Gateway | 192.168.1.1 | 192.168.1.1 |

### Server Interno (LAN)

**Config → FastEthernet0**:

| Campo | Valore |
|---|---|
| IP Address | 192.168.1.2 |
| Subnet Mask | 255.255.255.0 |
| Default Gateway | 192.168.1.1 |

### WebServer (DMZ)

**Config → FastEthernet0**:

| Campo | Valore |
|---|---|
| IP Address | 192.168.2.10 |
| Subnet Mask | 255.255.255.0 |
| Default Gateway | 192.168.2.1 |

Attiva il servizio HTTP: **Services → HTTP → ON**

Modifica la pagina `index.html` con un contenuto riconoscibile:
```html
<!DOCTYPE html>
<html>
<head><title>Azienda - Web Server DMZ</title></head>
<body>
  <h1>Server Web Aziendale</h1>
  <p>Questo server si trova nella DMZ - IP: 192.168.2.10</p>
</body>
</html>
```

---

## 📋 Step 4 — Configurazione dell'ASA 5506-X

Questa è la parte centrale del laboratorio. Accedi alla CLI dell'ASA cliccando sul dispositivo → scheda **CLI**.

### 4.1 — Accesso e configurazione base

```
! Al primo avvio l'ASA potrebbe chiedere se avviare la wizard interattiva
! Rispondi NO per configurare manualmente
ciscoasa> enable
Password: (invio — password vuota di default)
ciscoasa# configure terminal
ciscoasa(config)# hostname ASA-Lab
```

### 4.2 — Configurazione interfacce e security level

```
! ─────────────────────────────────────────────────
! INTERFACCIA OUTSIDE — verso Internet (WAN)
! Security level 0 = minima fiducia
! ─────────────────────────────────────────────────
ASA-Lab(config)# interface GigabitEthernet1/3
ASA-Lab(config-if)# ip address 150.10.0.1 255.255.255.0
ASA-Lab(config-if)# nameif outside
ASA-Lab(config-if)# security-level 0
ASA-Lab(config-if)# no shutdown
ASA-Lab(config-if)# exit

! ─────────────────────────────────────────────────
! INTERFACCIA INSIDE — verso LAN interna
! Security level 100 = massima fiducia
! ─────────────────────────────────────────────────
ASA-Lab(config)# interface GigabitEthernet1/2
ASA-Lab(config-if)# ip address 192.168.1.1 255.255.255.0
ASA-Lab(config-if)# nameif inside
ASA-Lab(config-if)# security-level 100
ASA-Lab(config-if)# no shutdown
ASA-Lab(config-if)# exit

! ─────────────────────────────────────────────────
! INTERFACCIA DMZ — verso la zona demilitarizzata
! Security level 50 = fiducia intermedia
! ─────────────────────────────────────────────────
ASA-Lab(config)# interface GigabitEthernet0/2
ASA-Lab(config-if)# ip address 192.168.2.1 255.255.255.0
ASA-Lab(config-if)# nameif dmz
ASA-Lab(config-if)# security-level 50
ASA-Lab(config-if)# no shutdown
ASA-Lab(config-if)# exit
```

> 📌 **Logica del security level**: il traffico fluisce liberamente da livelli alti verso bassi (inside → outside è permesso di default). Da livelli bassi verso alti è bloccato e richiede ACL esplicite (outside → dmz richiede una regola di permit).

### Verifica interfacce

```
ASA-Lab# show interface ip brief
```

Tutte e tre le interfacce devono mostrare stato `up` e l'indirizzo IP corretto.

---

### 4.3 — Configurazione NAT con object NAT

L'ASA usa il meccanismo **object NAT** (o auto-NAT): si crea un oggetto di rete e si associa la regola NAT direttamente all'oggetto.

```
! ─────────────────────────────────────────────────
! PAT DINAMICO — host LAN escono con IP dell'interfaccia outside
! Tutti i PC della rete 192.168.1.0/24 accedono a Internet
! con l'IP pubblico 150.10.0.1 e porte diverse
! ─────────────────────────────────────────────────
ASA-Lab(config)# object network LAN-INTERNA
ASA-Lab(config-network-object)# subnet 192.168.1.0 255.255.255.0
ASA-Lab(config-network-object)# nat (inside,outside) dynamic interface
ASA-Lab(config-network-object)# exit

! ─────────────────────────────────────────────────
! PAT DINAMICO — host DMZ escono con IP dell'interfaccia outside
! Il web server può avviare connessioni verso Internet se necessario
! ─────────────────────────────────────────────────
ASA-Lab(config)# object network DMZ-NET
ASA-Lab(config-network-object)# subnet 192.168.2.0 255.255.255.0
ASA-Lab(config-network-object)# nat (dmz,outside) dynamic interface
ASA-Lab(config-network-object)# exit

! ─────────────────────────────────────────────────
! NAT STATICO — il web server in DMZ è raggiungibile
! dall'esterno all'IP pubblico 150.10.0.1
! IP privato 192.168.2.10 ↔ IP pubblico 150.10.0.1
! (mappatura permanente e bidirezionale)
! ─────────────────────────────────────────────────
ASA-Lab(config)# object network WEBSERVER-DMZ
ASA-Lab(config-network-object)# host 192.168.2.10
ASA-Lab(config-network-object)# nat (dmz,outside) static 150.10.0.1
ASA-Lab(config-network-object)# exit
```

> ⚠️ **Nota importante**: il NAT statico per il web server mappa l'intero IP pubblico 150.10.0.1 verso 192.168.2.10. Questo significa che qualsiasi traffico che arriva su 150.10.0.1 — su qualsiasi porta — viene girato al web server. Per limitare solo la porta 80, usare il **port forwarding** (vedi sezione avanzata in fondo).

### Verifica NAT

```
ASA-Lab# show nat
ASA-Lab# show xlate
```

`show nat` mostra le regole configurate. `show xlate` mostra le traduzioni attive in tempo reale.

---

### 4.4 — Rotta di default

```
! ─────────────────────────────────────────────────
! ROTTA DI DEFAULT
! Tutto il traffico non specificato viene instradato
! verso il Router Internet (150.10.0.2)
! ─────────────────────────────────────────────────
ASA-Lab(config)# route outside 0.0.0.0 0.0.0.0 150.10.0.2
```

### Verifica routing

```
ASA-Lab# show route
```

Deve comparire una rotta `S* 0.0.0.0/0 [1/0] via 150.10.0.2, outside`.

---

### 4.5 — Configurazione ACL sull'interfaccia outside

Il traffico dall'interfaccia outside (security-level 0) verso inside e dmz (security-level più alto) è **bloccato di default**. Occorre permettere esplicitamente solo ciò che è necessario.

```
! ─────────────────────────────────────────────────
! ACL OUTSIDE — applicata al traffico in ingresso
! da Internet verso la rete aziendale
! ─────────────────────────────────────────────────

! Permette i ping di risposta (echo-reply)
! Senza questa regola i PC interni non ricevono
! le risposte ai loro ping verso Internet
ASA-Lab(config)# access-list OUTSIDE-IN extended permit icmp any any echo-reply

! Permette i messaggi ICMP "unreachable" (destination unreachable)
! Necessari per il corretto funzionamento di Path MTU Discovery
ASA-Lab(config)# access-list OUTSIDE-IN extended permit icmp any any unreachable

! Permette traffico HTTP (porta 80) verso il web server
! Il client esterno si connette all'IP pubblico 150.10.0.1
! che l'ASA traduce (NAT statico) verso 192.168.2.10
ASA-Lab(config)# access-list OUTSIDE-IN extended permit tcp any host 150.10.0.1 eq www

! Permette traffico HTTPS (porta 443) verso il web server
ASA-Lab(config)# access-list OUTSIDE-IN extended permit tcp any host 150.10.0.1 eq 443

! Nega esplicitamente tutto il resto
! (la regola "deny any any" è implicita su ASA,
! ma renderla esplicita attiva il logging)
ASA-Lab(config)# access-list OUTSIDE-IN extended deny ip any any log

! ─────────────────────────────────────────────────
! APPLICA L'ACL all'interfaccia outside in ingresso
! ─────────────────────────────────────────────────
ASA-Lab(config)# access-group OUTSIDE-IN in interface outside

ASA-Lab(config)# end
ASA-Lab# write memory
```

### Verifica ACL

```
ASA-Lab# show access-list OUTSIDE-IN
ASA-Lab# show access-group
```

`show access-list` mostra le regole con i contatori dei match. Dopo i test, i contatori degli echo-reply e del traffico HTTP devono essere > 0.

---

## 📋 Step 5 — Test di connettività

Esegui i test nell'ordine indicato. Ogni test verifica un aspetto specifico della configurazione.

### Test 1 — Ping dalla LAN verso Internet ✅

Dal **PC1** (192.168.1.10): `Desktop → Command Prompt`

```
ping 150.10.0.2
```

**Risultato atteso:** ping riuscito (Reply from 150.10.0.2)

**Cosa verifica:** il PAT funziona — i PC della LAN raggiungono Internet tramite l'IP pubblico dell'ASA.

**Se fallisce:** verifica la rotta di default sull'ASA e il PAT della LAN (`show nat`, `show route`).

---

### Test 2 — Ping dal PC esterno verso l'IP pubblico ✅

Dal **PC esterno** (10.0.0.2): `Desktop → Command Prompt`

```
ping 150.10.0.1
```

**Risultato atteso:** ping riuscito

**Cosa verifica:** il Router Internet instrada correttamente verso l'ASA e l'ACL OUTSIDE-IN permette le risposte ICMP echo-reply.

**Se fallisce:** verifica la rotta sul Router Internet e l'ACL (`show route` sul router, `show access-list` sull'ASA).

---

### Test 3 — Browser dal PC esterno verso il web server ✅

Dal **PC esterno**: `Desktop → Web Browser`

Digita nella barra degli indirizzi:
```
http://150.10.0.1
```

**Risultato atteso:** appare la pagina HTML del web server ("Server Web Aziendale").

**Cosa verifica:** il NAT statico traduce l'IP pubblico verso il web server in DMZ, l'ACL permette il traffico HTTP.

**Se fallisce:** verifica il NAT statico (`show nat`), l'ACL (`show access-list`) e che il servizio HTTP sia attivo sul web server.

---

### Test 4 — PC esterno NON raggiunge il server interno ❌ (atteso)

Dal **PC esterno**: `Desktop → Command Prompt`

```
ping 192.168.1.2
```

**Risultato atteso:** ping fallisce (Request timeout o Destination host unreachable)

**Cosa verifica:** il server interno nella LAN è correttamente protetto — dall'esterno non è raggiungibile.

---

### Test 5 — PC LAN naviga sul web server DMZ ✅

Dal **PC1**: `Desktop → Web Browser`

```
http://192.168.2.10
```

**Risultato atteso:** appare la pagina del web server.

**Cosa verifica:** il traffico dalla LAN (SL 100) verso la DMZ (SL 50) è permesso dal security level (alto verso basso).

---

### Test 6 — PC LAN raggiunge Internet ✅

Dal **PC1**: `Desktop → Web Browser`

```
http://10.0.0.2
```

oppure dal Command Prompt:
```
ping 10.0.0.2
```

**Risultato atteso:** la pagina del PC esterno appare, oppure il ping risponde.

**Cosa verifica:** il PAT LAN funziona per tutto il traffico verso Internet.

---

### Test 7 — PC esterno NON raggiunge la LAN direttamente ❌ (atteso)

Dal **PC esterno**:
```
ping 192.168.1.10
```

**Risultato atteso:** fallisce.

**Cosa verifica:** l'ACL OUTSIDE-IN blocca il traffico non autorizzato verso la LAN.

---

## 📋 Step 6 — Verifica della tabella NAT in tempo reale

Mentre i test sono in corso, visualizza le traduzioni NAT attive:

```
ASA-Lab# show xlate
```

Output esempio durante la navigazione di PC1:
```
Global 150.10.0.1   Local  192.168.1.10  ICMP  id 1
Global 150.10.0.1   Local  192.168.1.11  TCP  50231 -> 10.0.0.2:80
Global 150.10.0.1   Local  192.168.2.10  STATIC
```

L'ultima riga mostra il NAT statico sempre attivo per il web server.

```
ASA-Lab# show nat detail
```

Mostra le statistiche di ogni regola NAT — quanti pacchetti ha tradotto.

---

## 📋 Step 7 (avanzato) — Port Forwarding per HTTPS

In questo step avanzato modifichiamo il NAT statico per usare il **port forwarding** invece di mappare l'intero IP. Questo permette di avere più servizi su IP diversi usando lo stesso IP pubblico.

```
! Rimuovi il NAT statico generico precedente
ASA-Lab(config)# no object network WEBSERVER-DMZ

! Ricrea con port forwarding specifico per porta 80
ASA-Lab(config)# object network WEBSERVER-HTTP
ASA-Lab(config-network-object)# host 192.168.2.10
ASA-Lab(config-network-object)# nat (dmz,outside) static 150.10.0.1 service tcp www www
ASA-Lab(config-network-object)# exit

! Port forwarding per porta 443 (HTTPS) allo stesso server
ASA-Lab(config)# object network WEBSERVER-HTTPS
ASA-Lab(config-network-object)# host 192.168.2.10
ASA-Lab(config-network-object)# nat (dmz,outside) static 150.10.0.1 service tcp 443 443
ASA-Lab(config-network-object)# exit
```

Con questa configurazione, solo le porte 80 e 443 dell'IP pubblico 150.10.0.1 vengono inoltrate al web server. Una connessione su porta 22 (SSH) verso 150.10.0.1 non raggiungerà il server.

---

## 📋 Step 8 — Aggiunta di un server DNS locale (opzionale)

Per un laboratorio più realistico, aggiungi un server DNS nella DMZ che risolva il nome `www.azienda.it` verso 150.10.0.1.

### Configura il server DNS in DMZ

Aggiungi un secondo server in DMZ con IP `192.168.2.11` (collega allo stesso Switch1).

**Server DNS → Services → DNS → ON**

Aggiungi i record:

| Name | Type | Address |
|---|---|---|
| www.azienda.it | A Record | 150.10.0.1 |
| azienda.it | CNAME | www.azienda.it |

### Aggiorna i DNS sui client

Su ogni PC (PC1, PC2, PC esterno), imposta il DNS Server a `192.168.2.11`.

### Test DNS

Dal **PC esterno**: `Web Browser`
```
http://www.azienda.it
```

Risultato atteso: il browser risolve il nome e carica la pagina del web server.

---

## 📋 Riepilogo comandi di verifica

```
! ── INTERFACCE ─────────────────────────────────────────────
ASA-Lab# show interface ip brief           ! stato e IP di tutte le interfacce
ASA-Lab# show nameif                       ! nome e security level delle interfacce

! ── ROUTING ────────────────────────────────────────────────
ASA-Lab# show route                        ! tabella di routing

! ── NAT ────────────────────────────────────────────────────
ASA-Lab# show nat                          ! regole NAT configurate
ASA-Lab# show nat detail                   ! statistiche per regola
ASA-Lab# show xlate                        ! traduzioni NAT attive in tempo reale
ASA-Lab# clear xlate                       ! azzera la tabella di traduzione (test)

! ── ACL ────────────────────────────────────────────────────
ASA-Lab# show access-list                  ! tutte le ACL con contatori
ASA-Lab# show access-list OUTSIDE-IN       ! solo l'ACL specificata
ASA-Lab# show access-group                 ! quale ACL è applicata su quale interfaccia

! ── CONNESSIONI ─────────────────────────────────────────────
ASA-Lab# show conn                         ! connessioni TCP/UDP attive

! ── LOG ─────────────────────────────────────────────────────
ASA-Lab# show logging                      ! log di sistema (utile per debug ACL)
```

---

## 📋 Domande di verifica

1. Cos'è il **security level** dell'ASA e perché il traffico dalla LAN (SL 100) verso Internet (SL 0) non richiede una ACL esplicita mentre il contrario sì?

2. Qual è la differenza tra il **PAT dinamico** configurato per la LAN e il **NAT statico** configurato per il web server? In quale scenario si usa ciascuno?

3. Nel laboratorio hai aperto solo le porte 80 e 443 verso il web server. Cosa succederebbe se un attaccante cercasse di connettersi alla porta 22 (SSH) dell'IP pubblico 150.10.0.1? Dove verrebbe bloccato?

4. Perché nel piano di indirizzamento il web server ha come **gateway 192.168.2.1** (l'interfaccia DMZ dell'ASA) invece del Router Internet? Traccia il percorso di un pacchetto dal web server verso il PC esterno.

5. La regola ACL `permit icmp any any echo-reply` è necessaria per i ping dalla LAN verso Internet. Spiega perché: cosa succederebbe senza di essa durante un ping da PC1 verso 10.0.0.2?

6. Nella sezione "Step 7 avanzato" hai modificato il NAT statico con il port forwarding. Quali sono i vantaggi di questa soluzione rispetto al NAT statico generico dell'IP intero?

---

## 📚 Risorse

- 📄 [Cisco ASA 5506-X Getting Started Guide](https://www.cisco.com/c/en/us/td/docs/security/asa/asa96/asdm76/getting-started/asa-5506-gsg.html)
- 🌐 [Cisco ASA — NAT Configuration Examples](https://www.cisco.com/c/en/us/support/docs/security/asa-5500-x-series-next-generation-firewalls/115904-asa-config-dmz-00.html)
- 📄 [Cisco — Understanding ASA Security Levels](https://www.cisco.com/c/en/us/support/docs/security/pix-500-series-security-appliances/68661-asa-sec-levels.html)

---

## 🔗 Risorse correlate

- 🌐 **Sito:** [profgiagnotti.it](https://profgiagnotti.it)
- ▶️ **YouTube:** [youtube.com/@profgiagnotti](https://youtube.com/@profgiagnotti)
- 💬 **Discord:** [Unisciti alla community](https://discord.gg/profgiagnotti)

---

*Materiale a scopo educativo · Licenza MIT · Prof. Giagnotti*
