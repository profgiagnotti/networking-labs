# 🔬 Lab — ACL Estese con nome: protezione LAN interna e server FTP

![Materia](https://img.shields.io/badge/materia-Networking-3DE8A0?style=flat-square)
![Anno](https://img.shields.io/badge/anno-5-3DE8A0?style=flat-square)
![Modulo](https://img.shields.io/badge/modulo-3-3DE8A0?style=flat-square)
![Livello](https://img.shields.io/badge/livello-avanzato-FF5C5C?style=flat-square)
![Tool](https://img.shields.io/badge/tool-Packet%20Tracer-1BA0D7?style=flat-square&logo=cisco)

> Laboratorio pratico su ACL estese con nome — Anno 5, Modulo 3  
> 🌐 Teoria collegata: [profgiagnotti.it — L04 ACL estese: sintassi, inbound/outbound, established](https://profgiagnotti.it/corsi/networking/)

---

## 🎯 Obiettivi

Al termine di questo laboratorio sarai in grado di:

- ✅ Progettare una ACL estesa con nome a partire da una politica di sicurezza
- ✅ Distinguere quando usare `permit tcp`, `permit ip` e la keyword `established`
- ✅ Determinare l'interfaccia e la direzione corretta di applicazione per un'ACL estesa
- ✅ Configurare e verificare una ACL estesa con nome su router Cisco IOS
- ✅ Spiegare perché l'ACL estesa va applicata **vicino alla sorgente** del traffico da bloccare

---

## 🗺️ Topologia di rete

```
┌─────────────────────────────────────────┐
│        LAN INTERNA 192.168.1.0/24       │
│                                         │
│   [PC1] 192.168.1.10                    │
│   [PC2] 192.168.1.20                    │
│   [FTP Server] 192.168.1.2              │
│    www.mioftp.it                        │
│         |                               │
│     [Switch0]                           │
│      Fa0/1 (verso router)               │
└──────────────┬──────────────────────────┘
               │ Fa0/0 — 192.168.1.1
           [Router A]
               │ Fa1/0 — 10.0.0.1
┌──────────────┴──────────────────────────┐
│        LAN ESTERNA 10.0.0.0/24          │
│                                         │
│   [Web Server] 10.0.0.2                 │
│   [PC3] 10.0.0.10                       │
│         |                               │
│     [Switch1]                           │
└─────────────────────────────────────────┘
```

---

## 📋 Piano di indirizzamento

| Dispositivo | Interfaccia | Indirizzo IP | Subnet Mask | Gateway |
|---|---|---|---|---|
| PC1 (LAN interna) | Fa0 | 192.168.1.10 | 255.255.255.0 | 192.168.1.1 |
| PC2 (LAN interna) | Fa0 | 192.168.1.20 | 255.255.255.0 | 192.168.1.1 |
| FTP Server (LAN interna) | Fa0 | 192.168.1.2 | 255.255.255.0 | 192.168.1.1 |
| Web Server (LAN esterna) | Fa0 | 10.0.0.2 | 255.255.255.0 | 10.0.0.1 |
| PC3 (LAN esterna) | Fa0 | 10.0.0.10 | 255.255.255.0 | 10.0.0.1 |
| Router A — verso LAN interna | Fa0/0 | 192.168.1.1 | 255.255.255.0 | — |
| Router A — verso LAN esterna | Fa1/0 | 10.0.0.1 | 255.255.255.0 | — |

---

## 📋 Politica di sicurezza — cosa vogliamo ottenere

| Traffico | Permesso? | Motivazione |
|---|---|---|
| PC LAN → Web Server esterno (HTTP porta 80) | ✅ Sì | I client interni devono navigare |
| PC LAN → FTP Server interno (porta 21) | ✅ Sì | Accesso FTP dalla rete interna |
| Risposte HTTP/FTP verso la LAN | ✅ Sì | Necessarie per completare le sessioni avviate |
| Host esterno → FTP Server | ❌ No | Il server FTP è riservato alla LAN interna |
| Host esterno → qualsiasi PC della LAN | ❌ No | Nessuna connessione non richiesta dall'esterno |
| Altro traffico non specificato | ✅ Sì | Evitare blocchi accidentali |

---

## 📋 Step 1 — Costruzione della topologia in Packet Tracer

### Dispositivi da inserire

| Dispositivo | Modello PT | Quantità |
|---|---|---|
| Router A | Router-PT o 2911 | 1 |
| Switch LAN interna (Switch0) | 2960-24TT | 1 |
| Switch LAN esterna (Switch1) | 2960-24TT | 1 |
| PC1, PC2 | PC-PT | 2 |
| FTP Server | Server-PT | 1 |
| Web Server | Server-PT | 1 |
| PC3 | PC-PT | 1 |

### Cablaggio (cavi dritti — straight-through)

| Da | Porta | A | Porta |
|---|---|---|---|
| PC1 | Fa0 | Switch0 | Fa0/1 |
| PC2 | Fa0 | Switch0 | Fa1/1 |
| FTP Server | Fa0 | Switch0 | Fa2/1 |
| Switch0 | Fa3/1 | Router A | Fa0/0 |
| Router A | Fa1/0 | Switch1 | Fa0/1 |
| Web Server | Fa0 | Switch1 | Fa2/1 |
| PC3 | Fa0 | Switch1 | Fa1/1 |

---

## 📋 Step 2 — Configurazione di base (prerequisito)

### Router A — interfacce

```
Router> enable
Router# configure terminal
Router(config)# hostname RouterA

! Interfaccia verso LAN interna
RouterA(config)# interface FastEthernet0/0
RouterA(config-if)# ip address 192.168.1.1 255.255.255.0
RouterA(config-if)# description LAN-Interna
RouterA(config-if)# no shutdown
RouterA(config-if)# exit

! Interfaccia verso LAN esterna
RouterA(config)# interface FastEthernet1/0
RouterA(config-if)# ip address 10.0.0.1 255.255.255.0
RouterA(config-if)# description LAN-Esterna
RouterA(config-if)# no shutdown
RouterA(config-if)# exit
```

### FTP Server — configurazione servizio

Clicca sul **FTP Server → Services → FTP → ON**

Aggiungi un account utente:

| Username | Password | Permessi |
|---|---|---|
| studente | ftp123 | ✅ Read ✅ Write ✅ List |

### Web Server — configurazione servizio

Clicca sul **Web Server → Services → HTTP → ON**

Modifica `index.html`:
```html
<!DOCTYPE html>
<html>
<body>
  <h1>Web Server Esterno</h1>
  <p>IP: 10.0.0.2 — accessibile dalla LAN interna</p>
</body>
</html>
```

### Verifica connettività base (senza ACL)

Dal **PC1**, testa che tutto funzioni prima di applicare l'ACL:
```
ping 10.0.0.2        ! → Web Server esterno: deve rispondere ✅
ping 192.168.1.2     ! → FTP Server interno: deve rispondere ✅
ping 10.0.0.10       ! → PC3 esterno: deve rispondere ✅
```

Dal **PC3** (esterno):
```
ping 192.168.1.10    ! → PC1 interno: deve rispondere ✅ (PRIMA delle ACL)
ping 192.168.1.2     ! → FTP Server: deve rispondere ✅ (PRIMA delle ACL)
```

> 📌 Se tutti i ping rispondono, il routing funziona. Solo dopo questa verifica ha senso applicare le ACL.

---

## 📋 Step 3 — Analisi prima di scrivere l'ACL

Prima di configurare qualsiasi ACL, è fondamentale rispondere a tre domande.

### Domanda 1 — Tipo di ACL: standard o estesa?

Il requisito chiede di filtrare in base a:

| Criterio | Presente? |
|---|---|
| IP sorgente | ✅ (LAN interna vs esterna) |
| IP destinazione | ✅ (FTP Server, Web Server) |
| Protocollo | ✅ (TCP) |
| Porta | ✅ (80 HTTP, 21 FTP) |

Con quattro criteri di filtraggio → **ACL estesa**. Le ACL standard (solo IP sorgente) non sarebbero sufficienti.

Usiamo anche la forma **con nome** per una configurazione più leggibile e modificabile.

### Domanda 2 — Dove applicare l'ACL?

Le ACL estese vanno applicate **il più vicino possibile alla sorgente del traffico da bloccare**. Il traffico pericoloso arriva dalla rete esterna (PC3, Web Server) ed entra nel router tramite l'interfaccia **Fa1/0**.

Applicando l'ACL su Fa1/0 in ingresso, i pacchetti indesiderati vengono scartati subito, prima di consumare risorse di routing.

### Domanda 3 — In o Out?

Rispetto all'interfaccia **Fa1/0**:
- Il traffico esterno (PC3, Web Server) **entra** in Fa1/0 provenendo dalla LAN esterna
- La sorgente del traffico da controllare è nella rete **direttamente connessa** a Fa1/0

→ Direzione: **`in`**

> 📌 **Regola**: se la sorgente del traffico è nella LAN collegata all'interfaccia → `in`. Se la sorgente è in una rete raggiunta tramite routing → `out`.

---

## 📋 Step 4 — Configurazione dell'ACL estesa con nome

```
RouterA(config)# ip access-list extended ACL-LAN-PROTETTA
```

Siamo ora in modalità `config-ext-nacl`. Inseriamo le ACE nell'ordine corretto.

### ACE 1 — Permetti HTTP dalla LAN interna verso il Web Server

```
RouterA(config-ext-nacl)# permit tcp 192.168.1.0 0.0.0.255 host 10.0.0.2 eq 80
```

| Parametro | Valore | Significato |
|---|---|---|
| `permit` | — | azione: permetti |
| `tcp` | — | protocollo: HTTP usa TCP |
| `192.168.1.0 0.0.0.255` | wildcard | tutta la rete LAN interna /24 |
| `host 10.0.0.2` | — | solo verso il Web Server |
| `eq 80` | porta dst | servizio HTTP |

> 📌 **Nota**: questa regola permette ai PC interni di avviare connessioni HTTP verso il Web Server. Le risposte del server vengono gestite dalla regola `established` (ACE 3).

---

### ACE 2 — Permetti FTP dalla LAN interna verso il FTP Server

```
RouterA(config-ext-nacl)# permit tcp 192.168.1.0 0.0.0.255 host 192.168.1.2 eq 21
```

| Parametro | Valore | Significato |
|---|---|---|
| `permit` | — | azione: permetti |
| `tcp` | — | protocollo: FTP usa TCP |
| `192.168.1.0 0.0.0.255` | wildcard | tutta la LAN interna |
| `host 192.168.1.2` | — | solo verso il FTP Server |
| `eq 21` | porta dst | controllo FTP (autenticazione e comandi) |

> ⚠️ **Perché solo la porta 21 e non anche la 20?**  
> La porta 21 gestisce il canale di controllo FTP (autenticazione e comandi). Il canale dati (porta 20 o porte dinamiche in modalità passiva) rimane **interno alla LAN** — i dati viaggiano direttamente tra PC e FTP Server senza mai attraversare Fa1/0, quindi non devono essere filtrati qui.

---

### ACE 3 — Permetti le risposte TCP verso la LAN (established)

```
RouterA(config-ext-nacl)# permit tcp any 192.168.1.0 0.0.0.255 established
```

| Parametro | Valore | Significato |
|---|---|---|
| `permit` | — | azione: permetti |
| `tcp` | — | solo risposte TCP |
| `any` | — | da qualsiasi sorgente esterna |
| `192.168.1.0 0.0.0.255` | wildcard | verso la LAN interna |
| `established` | — | solo pacchetti con flag ACK o RST attivo |

> 📌 **Come funziona `established`?**  
> Il primo pacchetto di una nuova connessione TCP è sempre un **SYN** (senza flag ACK). Tutti i pacchetti successivi — risposte, dati, chiusura — hanno il flag ACK attivo. La keyword `established` corrisponde solo a pacchetti con ACK o RST → permette le risposte alle connessioni avviate dall'interno, blocca qualsiasi nuova connessione iniziata dall'esterno.

---

### ACE 4 — Nega tutto il traffico esterno verso la LAN interna

```
RouterA(config-ext-nacl)# deny ip any 192.168.1.0 0.0.0.255
```

| Parametro | Valore | Significato |
|---|---|---|
| `deny` | — | azione: blocca |
| `ip` | — | qualsiasi protocollo IP (TCP, UDP, ICMP...) |
| `any` | — | da qualsiasi sorgente esterna |
| `192.168.1.0 0.0.0.255` | wildcard | verso qualsiasi host della LAN interna |

> 📌 **Effetto**: nessun host esterno può raggiungere il FTP Server, i PC interni o qualsiasi altro dispositivo della LAN. Il FTP Server è protetto automaticamente perché fa parte della rete `192.168.1.0/24`.

---

### ACE 5 — Permetti tutto il traffico non specificato

```
RouterA(config-ext-nacl)# permit ip any any
RouterA(config-ext-nacl)# exit
```

> ⚠️ **Perché è necessaria questa regola?**  
> Senza `permit ip any any`, il **deny implicito** finale bloccherebbe anche traffico legittimo non previsto — ad esempio, il traffico tra la LAN esterna e reti non coinvolte in questa policy. La regola garantisce che solo i flussi specificati vengano filtrati.

---

### Riepilogo ACL completa

```
RouterA(config)# ip access-list extended ACL-LAN-PROTETTA
RouterA(config-ext-nacl)# permit tcp 192.168.1.0 0.0.0.255 host 10.0.0.2 eq 80
RouterA(config-ext-nacl)# permit tcp 192.168.1.0 0.0.0.255 host 192.168.1.2 eq 21
RouterA(config-ext-nacl)# permit tcp any 192.168.1.0 0.0.0.255 established
RouterA(config-ext-nacl)# deny ip any 192.168.1.0 0.0.0.255
RouterA(config-ext-nacl)# permit ip any any
RouterA(config-ext-nacl)# exit
```

---

## 📋 Step 5 — Applicazione dell'ACL all'interfaccia

```
! Applica l'ACL sull'interfaccia verso la LAN esterna
! Direzione IN — il traffico esterno entra da qui

RouterA(config)# interface FastEthernet1/0
RouterA(config-if)# ip access-group ACL-LAN-PROTETTA in
RouterA(config-if)# exit

RouterA(config)# end
RouterA# write memory
```

---

## 📋 Step 6 — Verifica dell'ACL

```
RouterA# show access-lists
RouterA# show access-lists ACL-LAN-PROTETTA
RouterA# show ip interface FastEthernet1/0
```

Output atteso di `show access-lists` (prima dei test, tutti i contatori sono 0):
```
Extended IP access list ACL-LAN-PROTETTA
    10 permit tcp 192.168.1.0 0.0.0.255 host 10.0.0.2 eq www
    20 permit tcp 192.168.1.0 0.0.0.255 host 192.168.1.2 eq ftp
    30 permit tcp any 192.168.1.0 0.0.0.255 established
    40 deny ip any 192.168.1.0 0.0.0.255
    50 permit ip any any
```

Output atteso di `show ip interface FastEthernet1/0`:
```
FastEthernet1/0 is up, line protocol is up
  ...
  Inbound  access list is ACL-LAN-PROTETTA
  Outgoing access list is not set
  ...
```

---

## 📋 Step 7 — Test di connettività

### Test 1 — PC1 → Web Server (HTTP) ✅

Dal **PC1** (192.168.1.10): `Desktop → Web Browser`
```
http://10.0.0.2
```
**Risultato atteso:** la pagina HTML del Web Server appare nel browser.

**Quale ACE interviene:** ACE 1 (`permit tcp ... host 10.0.0.2 eq 80`) permette la richiesta. ACE 3 (`established`) permette la risposta del server.

---

### Test 2 — PC1 → FTP Server (FTP) ✅

Dal **PC1**: `Desktop → Command Prompt`
```
ftp 192.168.1.2
```
Inserisci username: `studente`, password: `ftp123`.

**Risultato atteso:** accesso FTP riuscito — prompt `ftp>`.

```
ftp> dir
ftp> quit
```

**Quale ACE interviene:** ACE 2 (`permit tcp ... host 192.168.1.2 eq 21`) permette il canale di controllo FTP.

---

### Test 3 — PC3 esterno → FTP Server ❌

Dal **PC3** (10.0.0.10): `Desktop → Command Prompt`
```
ftp 192.168.1.2
```
**Risultato atteso:** connessione rifiutata o timeout.

**Quale ACE interviene:** ACE 3 (`established`) non corrisponde perché il SYN iniziale non ha il flag ACK. ACE 4 (`deny ip any 192.168.1.0`) blocca la connessione.

---

### Test 4 — PC3 esterno → PC1 ❌

Dal **PC3**: `Desktop → Command Prompt`
```
ping 192.168.1.10
```
**Risultato atteso:** nessuna risposta.

**Quale ACE interviene:** ACE 4 (`deny ip any 192.168.1.0 0.0.0.255`) blocca l'ICMP echo verso la LAN interna.

---

### Test 5 — PC1 → PC3 (ping verso esterno) ✅

Dal **PC1**: `Desktop → Command Prompt`
```
ping 10.0.0.10
```
**Risultato atteso:** ping riuscito.

**Perché funziona?** Il ping dal PC1 esce da Fa0/0 (interfaccia LAN) e non passa da Fa1/0 in direzione `in`. La risposta di PC3 entra da Fa1/0 e corrisponde ad ACE 3 (`established` — flag ACK sul pacchetto echo-reply ICMP).

> ⚠️ **Nota**: `established` funziona solo per TCP. Per ICMP, Packet Tracer tende a comportarsi in modo più permissivo. In un firewall reale occorrerebbe aggiungere `permit icmp any 192.168.1.0 0.0.0.255 echo-reply`.

---

### Test 6 — Web Server esterno → PC1 ❌

Dal **Web Server** (10.0.0.2): `Desktop → Command Prompt`
```
ping 192.168.1.10
```
**Risultato atteso:** nessuna risposta — il Web Server non può avviare connessioni verso la LAN interna.

---

### Riepilogo test

| Scenario | Da | Verso | Porta | Risultato | ACE |
|---|---|---|---|---|---|
| PC LAN → Web Server HTTP | PC1 | 10.0.0.2 | 80 | ✅ OK | ACE 1 + ACE 3 |
| PC LAN → FTP Server | PC1 | 192.168.1.2 | 21 | ✅ OK | ACE 2 |
| Esterno → FTP Server | PC3 | 192.168.1.2 | 21 | ❌ BLOCCATO | ACE 4 |
| Esterno → PC LAN | PC3 | 192.168.1.10 | ICMP | ❌ BLOCCATO | ACE 4 |
| Risposte server → LAN | Web Server | 192.168.1.x | ACK | ✅ OK | ACE 3 |
| PC LAN → PC esterno | PC1 | 10.0.0.10 | ICMP | ✅ OK | ACE 5 |

---

## 📋 Step 8 — Lettura dei contatori dopo i test

Dopo aver eseguito tutti i test, verifica i contatori delle ACE:

```
RouterA# show access-lists ACL-LAN-PROTETTA
```

Output esempio:
```
Extended IP access list ACL-LAN-PROTETTA
    10 permit tcp 192.168.1.0 0.0.0.255 host 10.0.0.2 eq www (4 matches)
    20 permit tcp 192.168.1.0 0.0.0.255 host 192.168.1.2 eq ftp (2 matches)
    30 permit tcp any 192.168.1.0 0.0.0.255 established (18 matches)
    40 deny ip any 192.168.1.0 0.0.0.255 (6 matches)
    50 permit ip any any (3 matches)
```

I **contatori** confermano che:
- Le prime due ACE hanno catturato le connessioni avviate dalla LAN
- ACE 3 ha gestito il traffico di risposta (sempre il numero più alto)
- ACE 4 ha bloccato i tentativi di accesso dall'esterno
- ACE 5 ha permesso traffico residuo non coinvolto nella policy

---

## 📋 Riepilogo comandi

```
! ── DEFINIZIONE ACL ESTESA CON NOME ──────────────────────
ip access-list extended ACL-LAN-PROTETTA
 permit tcp 192.168.1.0 0.0.0.255 host 10.0.0.2 eq 80
 permit tcp 192.168.1.0 0.0.0.255 host 192.168.1.2 eq 21
 permit tcp any 192.168.1.0 0.0.0.255 established
 deny ip any 192.168.1.0 0.0.0.255
 permit ip any any

! ── APPLICAZIONE ──────────────────────────────────────────
interface FastEthernet1/0
 ip access-group ACL-LAN-PROTETTA in

! ── VERIFICA ──────────────────────────────────────────────
show access-lists
show access-lists ACL-LAN-PROTETTA
show ip interface FastEthernet1/0
clear ip access-list counters          ! azzera i contatori per nuovi test

! ── MODIFICA SINGOLA ACE (solo con ACL con nome) ──────────
ip access-list extended ACL-LAN-PROTETTA
 no permit tcp any 192.168.1.0 0.0.0.255 established   ! rimuove l'ACE
 permit tcp any 192.168.1.0 0.0.0.255 established       ! reinserisce

! ── RIMOZIONE COMPLETA ────────────────────────────────────
interface FastEthernet1/0
 no ip access-group ACL-LAN-PROTETTA in
no ip access-list extended ACL-LAN-PROTETTA
```

---

## 📋 Confronto ACL standard vs ACL estesa — questo scenario

| Aspetto | ACL standard | ACL estesa (usata qui) |
|---|---|---|
| Criteri di filtraggio | Solo IP sorgente | IP src, IP dst, protocollo, porta |
| Posizionamento | Vicino alla destinazione | Vicino alla sorgente (Fa1/0 `in`) |
| Blocco FTP dall'esterno | ❌ Impossibile (stesso IP sorgente) | ✅ `deny ip any 192.168.1.0` |
| Permesso HTTP solo verso un server | ❌ Impossibile | ✅ `permit tcp ... host 10.0.0.2 eq 80` |
| Keyword established | ❌ Non disponibile | ✅ Gestisce le risposte TCP |
| ACL con nome | ✅ Sì | ✅ Sì (entrambe lo supportano) |

---

## 📋 Domande di verifica

1. L'ACL è applicata `in` su **Fa1/0** (interfaccia esterna). Perché non è stata applicata `out` su **Fa0/0** (interfaccia LAN)? Il risultato finale sarebbe identico? Ci sarebbe qualche differenza di efficienza?

2. La ACE `permit tcp any 192.168.1.0 0.0.0.255 established` permette le risposte HTTP verso la LAN. Spiega perché un attaccante che invia un pacchetto TCP con flag ACK impostato artificialmente **potrebbe** bypassare questo controllo. Come si risolve il problema definitivamente?

3. Il traffico FTP usa due canali: il canale di controllo (porta 21) e il canale dati (porta 20 o porte dinamiche). Perché nell'ACL è stata filtrata solo la porta 21 e non anche la porta 20? Cosa succederebbe se il FTP Server fosse nella rete **esterna** invece che nella LAN interna?

4. Modifica l'ACL per aggiungere questo requisito: **i PC interni possono accedere anche a HTTPS (porta 443) sul Web Server esterno**. Scrivi la nuova ACE e indica la posizione corretta nella lista.

5. La ACE finale `permit ip any any` serve a evitare blocchi accidentali. In quale scenario specifico questa regola è indispensabile? Cosa succederebbe se la rimuovessimo dalla configurazione attuale?

---

## 📚 Risorse

- 🔗 [Cisco — Configuring Extended IP Access Lists](https://www.cisco.com/c/en/us/support/docs/security/ios-firewall/23602-confaccesslists.html)
- 📄 [Cisco IOS — IP Access List Entry Sequence Numbering](https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/sec_data_acl/configuration/xe-3s/sec-data-acl-xe-3s-book/sec-acl-seq-num.html)
- 🖧 [Cisco Packet Tracer — download gratuito](https://www.netacad.com/courses/packet-tracer)

---

## 🔗 Risorse correlate

- 🌐 **Sito:** [profgiagnotti.it](https://profgiagnotti.it)
- ▶️ **YouTube:** [youtube.com/@profgiagnotti](https://youtube.com/@profgiagnotti)
- 💬 **Discord:** [Unisciti alla community](https://discord.gg/profgiagnotti)

---

*Materiale a scopo educativo · Licenza MIT · Prof. Giagnotti*
