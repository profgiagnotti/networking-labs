# 🔬 Lab — ACL Standard: esercizi pratici su topologia multi-LAN

![Materia](https://img.shields.io/badge/materia-Networking-3DE8A0?style=flat-square)
![Anno](https://img.shields.io/badge/anno-5-3DE8A0?style=flat-square)
![Modulo](https://img.shields.io/badge/modulo-3-3DE8A0?style=flat-square)
![Livello](https://img.shields.io/badge/livello-intermedio-FFAA3D?style=flat-square)
![Tool](https://img.shields.io/badge/tool-Packet%20Tracer-1BA0D7?style=flat-square&logo=cisco)

> Laboratorio pratico su ACL standard numeriche — Anno 5, Modulo 3  
> 🌐 Teoria collegata: [profgiagnotti.it — L03 ACL: concetti, wildcard mask e ACL standard](https://profgiagnotti.it/corsi/networking/)

---

## 🎯 Obiettivi

Al termine di questo laboratorio sarai in grado di:

- ✅ Progettare una ACL standard a partire da una politica di sicurezza espressa in linguaggio naturale
- ✅ Calcolare la wildcard mask a partire dalla subnet mask
- ✅ Determinare su quale interfaccia e in quale direzione (`in` / `out`) applicare l'ACL
- ✅ Configurare ACL standard numeriche su router Cisco IOS e verificarne il funzionamento con ping
- ✅ Riconoscere il ruolo del `deny` implicito finale e la necessità di un `permit any` esplicito

---

## 🗺️ Topologia di rete

```
┌──────────────────────────────────┐
│       LAN 1: 192.168.1.0/24      │
│  [PC0] 192.168.1.1               │
│  [PC1] 192.168.1.2               │
│  [PC2] 192.168.1.3               │
│         |                        │
│     [Switch1]                    │
│      Fa0/1                       │
└──────────┬───────────────────────┘
           │ Fa0/0
      [Router0]
           │ Fa1/0
┌──────────┴───────────────────────┐
│       LAN 2: 192.168.2.0/24      │
│  [PC3] 192.168.2.1               │
│  [PC4] 192.168.2.2               │
│  [PC5] 192.168.2.3               │
│         |                        │
│     [Switch0]                    │
└──────────────────────────────────┘

[Router0] ── Se2/0 ── 10.0.0.0 ── Se2/0 ── [Router2]
                                               │ Fa0/0
                              ┌────────────────┴──────────────┐
                              │       LAN 3: 192.168.3.0/24   │
                              │   [PC6] 192.168.3.1           │
                              │        |                      │
                              │    [Switch2]                  │
                              └───────────────────────────────┘
```

---

## 📋 Piano di indirizzamento

| Dispositivo | Interfaccia | Indirizzo IP | Subnet Mask | Gateway |
|---|---|---|---|---|
| PC0 (LAN 1) | Fa0 | 192.168.1.1 | 255.255.255.0 | 192.168.1.254 |
| PC1 (LAN 1) | Fa0 | 192.168.1.2 | 255.255.255.0 | 192.168.1.254 |
| PC2 (LAN 1) | Fa0 | 192.168.1.3 | 255.255.255.0 | 192.168.1.254 |
| PC3 (LAN 2) | Fa0 | 192.168.2.1 | 255.255.255.0 | 192.168.2.254 |
| PC4 (LAN 2) | Fa0 | 192.168.2.2 | 255.255.255.0 | 192.168.2.254 |
| PC5 (LAN 2) | Fa0 | 192.168.2.3 | 255.255.255.0 | 192.168.2.254 |
| PC6 (LAN 3) | Fa0 | 192.168.3.1 | 255.255.255.0 | 192.168.3.254 |
| Router0 — verso LAN 1 | Fa0/0 | 192.168.1.254 | 255.255.255.0 | — |
| Router0 — verso LAN 2 | Fa1/0 | 192.168.2.254 | 255.255.255.0 | — |
| Router0 — verso Router2 | Se2/0 | 10.0.0.1 | 255.0.0.0 | — |
| Router2 — verso Router0 | Se2/0 | 10.0.0.2 | 255.0.0.0 | — |
| Router2 — verso LAN 3 | Fa0/0 | 192.168.3.254 | 255.255.255.0 | — |

---

## 📋 Configurazione di base (prerequisito)

Prima di procedere con gli esercizi sulle ACL, verifica che la rete sia già operativa:
interfacce configurate, routing attivo (statico o RIP) e ping funzionanti tra tutte le LAN.

Se devi configurare il routing RIP su entrambi i router:

```
! ── Router0 ────────────────────────────────────────────
Router0(config)# router rip
Router0(config-router)# network 192.168.1.0
Router0(config-router)# network 192.168.2.0
Router0(config-router)# network 10.0.0.0
Router0(config-router)# exit

! ── Router2 ────────────────────────────────────────────
Router2(config)# router rip
Router2(config-router)# network 192.168.3.0
Router2(config-router)# network 10.0.0.0
Router2(config-router)# exit
```

### Verifica della raggiungibilità prima delle ACL

Dal **PC0** esegui:
```
ping 192.168.2.1    ! → PC3 in LAN 2: deve rispondere ✅
ping 192.168.3.1    ! → PC6 in LAN 3: deve rispondere ✅
```

Se tutti i ping rispondono, la rete è operativa e puoi procedere con gli esercizi.

---

---

# 📝 Esercizio 1 — Bloccare PC0, permettere PC1 e PC2

## Requisiti

Sulla base della topologia di figura, creare una ACL che:

- ❌ **Blocchi** il traffico tra **PC0** della LAN 1 e **tutti i PC della LAN 2**
- ✅ **Consenta** il traffico tra **PC1** e **PC2** della LAN 1 con tutti i PC della LAN 2
- ✅ Ai PC della **LAN 3** è consentito il traffico da e verso le altre due LAN

---

## Analisi del problema

Il requisito chiede di filtrare in base all'**IP sorgente** (PC0 deve essere bloccato, PC1 e PC2 no) senza vincoli su protocollo o porta. Questo è esattamente il caso d'uso delle **ACL standard**.

### Quali ACE servono?

| ACE | Azione | Sorgente | Motivo |
|---|---|---|---|
| 1 | `deny` | `host 192.168.1.1` (PC0) | Blocca solo PC0 |
| 2 | `permit` | `any` | Permette tutto il resto — **obbligatoria** per evitare il deny implicito finale |

> ⚠️ **Attenzione al deny implicito**: ogni ACL Cisco termina con un `deny any` invisibile. Se non si aggiunge `permit any`, tutto il traffico non esplicitamente permesso viene bloccato — incluso PC1 e PC2.

### Dove applicare l'ACL?

Le **ACL standard** vanno applicate **vicino alla destinazione** perché filtrano solo l'IP sorgente e non possono distinguere la destinazione.

La destinazione del traffico di PC0 che vogliamo bloccare è la **LAN 2**: l'interfaccia più vicina è **Fa1/0 di Router0** (quella connessa a Switch0 / LAN 2).

### In o Out?

Ragionamento dal punto di vista dell'interfaccia **Fa1/0**:

- I pacchetti di PC0 **entrano** in Router0 da Fa0/0 (LAN 1) e **escono** da Fa1/0 (LAN 2)
- Rispetto all'interfaccia Fa1/0, la sorgente PC0 è **esterna** → si applica **`out`**

> 📌 **Regola pratica**: se l'host sorgente è nella rete connessa all'interfaccia su cui applichi l'ACL → `in`. Se l'host sorgente è in una rete diversa (raggiunge l'interfaccia dopo essere stato instradato) → `out`.

---

## Soluzione — configurazione

```
! ─────────────────────────────────────────────────────────
! ESERCIZIO 1 — ACL standard numero 1
! Blocca PC0 (192.168.1.1), permette tutto il resto
! ─────────────────────────────────────────────────────────

! ACE 1: nega PC0 — usa la keyword "host" (equivale a wildcard 0.0.0.0)
Router0(config)# access-list 1 deny host 192.168.1.1

! ACE 2: permette tutto il traffico rimanente
! Senza questa riga, PC1 e PC2 sarebbero bloccati dal deny implicito!
Router0(config)# access-list 1 permit any

! Applica l'ACL sull'interfaccia verso LAN 2 (destinazione), direzione out
Router0(config)# interface FastEthernet1/0
Router0(config-if)# ip access-group 1 out
Router0(config-if)# exit
```

---

## Verifica dell'Esercizio 1

### Test 1 — PC0 → LAN 2 ❌ (deve fallire)

Da **PC0** (192.168.1.1): `Desktop → Command Prompt`
```
ping 192.168.2.1
ping 192.168.2.2
ping 192.168.2.3
```
**Risultato atteso:** `Request timeout` — PC0 non raggiunge nessun host della LAN 2.

---

### Test 2 — LAN 2 → PC0 ❌ (deve fallire)

Da **PC3** (192.168.2.1):
```
ping 192.168.1.1
```
**Risultato atteso:** nessuna risposta.

> 📌 **Perché fallisce anche il ping di ritorno?** L'ACL blocca il traffico **in uscita da Fa1/0**. Una risposta di PC0 verso la LAN 2 deve passare per Fa1/0 in direzione `out` — viene quindi bloccata allo stesso modo.

---

### Test 3 — PC1 → LAN 2 ✅ (deve funzionare)

Da **PC1** (192.168.1.2):
```
ping 192.168.2.1
```
**Risultato atteso:** ping riuscito — PC1 non è nella lista dei deny.

---

### Test 4 — PC2 → LAN 2 ✅ (deve funzionare)

Da **PC2** (192.168.1.3):
```
ping 192.168.2.1
```
**Risultato atteso:** ping riuscito.

---

### Test 5 — PC6 (LAN 3) → LAN 2 ✅ (deve funzionare)

Da **PC6** (192.168.3.1):
```
ping 192.168.2.1
```
**Risultato atteso:** ping riuscito — l'ACL è applicata solo su Fa1/0 di Router0, il traffico proveniente dalla LAN 3 transita su un percorso diverso (Router2 → Router0 → Fa1/0) ma con IP sorgente 192.168.3.1, che corrisponde alla regola `permit any`.

---

### Test 6 — PC0 → LAN 3 ✅ (deve funzionare)

Da **PC0** (192.168.1.1):
```
ping 192.168.3.1
```
**Risultato atteso:** ping riuscito — l'ACL è applicata **solo** su Fa1/0 (verso LAN 2). Il traffico verso LAN 3 esce da Se2/0, dove non c'è nessuna ACL configurata.

---

### Verifica della configurazione

```
Router0# show access-lists
Router0# show ip interface FastEthernet1/0
```

Output atteso di `show access-lists` dopo i test:
```
Standard IP access list 1
    10 deny   host 192.168.1.1 (N matches)
    20 permit any (N matches)
```

I contatori (`N matches`) devono essere maggiori di 0 dopo aver eseguito i test.

---

---

# 📝 Esercizio 2 — LAN 2 comunica con tutti, LAN 1 e LAN 3 bloccate tra loro

## Requisiti

Sulla base della stessa topologia:

- ✅ **Tutti i PC della LAN 2** possono comunicare con tutti i PC delle altre LAN
- ❌ **Bloccare** il traffico tra **LAN 1 e LAN 3** (in entrambe le direzioni)

---

## Analisi del problema

Il requisito filtra in base alle reti sorgente (LAN 1, LAN 2, LAN 3) senza distinguere porte o protocolli → **ACL standard**.

### Quale logica di filtraggio applicare?

Si permette il traffico proveniente da LAN 2 e si blocca tutto il resto. Le due ACE necessarie sono:

| ACE | Azione | Sorgente | Motivo |
|---|---|---|---|
| 1 | `permit` | `192.168.2.0 0.0.0.255` | Permette tutto il traffico da LAN 2 |
| 2 | `deny` | `any` | Blocca tutto il resto (LAN 1 e LAN 3) |

### Calcolo della wildcard mask per LAN 2

```
  255.255.255.255
- 255.255.255.0     (subnet mask della LAN 2)
= 0.0.0.255         (wildcard mask)
```

La wildcard `0.0.0.255` significa: controlla i primi tre ottetti (devono essere `192.168.2`) e ignora l'ultimo (qualsiasi host della rete).

### Dove applicare l'ACL?

La politica blocca il traffico **tra LAN 1 e LAN 3** in entrambe le direzioni. Occorre bloccare:

1. Il traffico da LAN 1 verso LAN 3 — passa da Router0 uscendo su Se2/0
2. Il traffico da LAN 3 verso LAN 1 — entra in Router0 da Se2/0 e deve essere bloccato prima di raggiungere Fa0/0

La soluzione più efficace è applicare la stessa ACL su **due interfacce di Router0**:
- `Fa1/0 out` — blocca il traffico verso LAN 2 che non proviene da LAN 2 (protezione simmetrica)
- `Se2/0 out` — blocca il traffico verso LAN 3 che non proviene da LAN 2

In questo modo:
- Il traffico da LAN 2 corrisponde alla regola `permit` → passa
- Il traffico da LAN 1 o LAN 3 corrisponde alla regola `deny any` → bloccato

### In o Out?

Sia per Fa1/0 che per Se2/0, le sorgenti LAN 1 e LAN 3 sono **esterne** all'interfaccia su cui si applica l'ACL → direzione **`out`**.

---

## Soluzione — configurazione

```
! ─────────────────────────────────────────────────────────
! ESERCIZIO 2 — ACL standard numero 2
! Permette LAN 2, blocca tutto il resto
! ─────────────────────────────────────────────────────────

! ACE 1: permette il traffico proveniente da tutta la LAN 2
! Wildcard 0.0.0.255 corrisponde a qualsiasi host in 192.168.2.0/24
Router0(config)# access-list 2 permit 192.168.2.0 0.0.0.255

! ACE 2: nega esplicitamente tutto il resto
! (LAN 1 e LAN 3 sono bloccate)
Router0(config)# access-list 2 deny any

! ─────────────────────────────────────────────────────────
! Applicazione sull'interfaccia verso LAN 2 (Fa1/0)
! Direzione: out
! ─────────────────────────────────────────────────────────
Router0(config)# interface FastEthernet1/0
Router0(config-if)# ip access-group 2 out
Router0(config-if)# exit

! ─────────────────────────────────────────────────────────
! Applicazione sull'interfaccia seriale verso Router2/LAN 3
! Direzione: out
! Blocca il traffico da LAN 1 verso LAN 3 e viceversa
! ─────────────────────────────────────────────────────────
Router0(config)# interface Serial2/0
Router0(config-if)# ip access-group 2 out
Router0(config-if)# exit
```

> ⚠️ **Nota**: se nell'Esercizio 1 era ancora configurata l'ACL 1 su Fa1/0, rimuovila prima di applicare la nuova:
> ```
> Router0(config)# interface FastEthernet1/0
> Router0(config-if)# no ip access-group 1 out
> Router0(config-if)# exit
> Router0(config)# no access-list 1
> ```

---

## Verifica dell'Esercizio 2

### Test 1 — PC3 (LAN 2) → PC0 (LAN 1) ✅ (deve funzionare)

Da **PC3** (192.168.2.1):
```
ping 192.168.1.1
```
**Risultato atteso:** ping riuscito — il traffico da LAN 2 corrisponde alla regola `permit 192.168.2.0`.

---

### Test 2 — PC3 (LAN 2) → PC6 (LAN 3) ✅ (deve funzionare)

Da **PC3** (192.168.2.1):
```
ping 192.168.3.1
```
**Risultato atteso:** ping riuscito.

---

### Test 3 — PC0 (LAN 1) → PC6 (LAN 3) ❌ (deve fallire)

Da **PC0** (192.168.1.1):
```
ping 192.168.3.1
```
**Risultato atteso:** nessuna risposta — il traffico da LAN 1 esce da Se2/0 dove l'ACL applica `deny any`.

---

### Test 4 — PC6 (LAN 3) → PC0 (LAN 1) ❌ (deve fallire)

Da **PC6** (192.168.3.1):
```
ping 192.168.1.1
```
**Risultato atteso:** nessuna risposta.

> 📌 **Perché fallisce anche questo?** Il traffico da LAN 3 verso LAN 1 entra in Router0 da Se2/0 e dovrebbe uscire da Fa0/0. Ma Fa1/0 (con ACL `out`) non è nel percorso — quindi il blocco avviene sulla stessa Se2/0 in direzione `out` al momento del routing inverso: quando la risposta di PC0 torna verso PC6, deve passare per Se2/0 `out` e viene bloccata dalla `deny any`.

---

### Test 5 — PC0 (LAN 1) → PC3 (LAN 2) ❌ (deve fallire)

Da **PC0** (192.168.1.1):
```
ping 192.168.2.1
```
**Risultato atteso:** nessuna risposta — il traffico da LAN 1 verso LAN 2 esce da Fa1/0 `out` dove l'ACL applica `deny any` (IP sorgente 192.168.1.x non corrisponde alla `permit 192.168.2.0`).

---

### Verifica della configurazione

```
Router0# show access-lists
Router0# show ip interface FastEthernet1/0
Router0# show ip interface Serial2/0
```

Output atteso di `show access-lists`:
```
Standard IP access list 2
    10 permit 192.168.2.0 0.0.0.255 (N matches)
    20 deny   any (N matches)
```

Output atteso di `show ip interface FastEthernet1/0`:
```
...
Outgoing access list is 2
...
```

Output atteso di `show ip interface Serial2/0`:
```
...
Outgoing access list is 2
...
```

---

---

## 📋 Riepilogo comandi

```
! ── DEFINIZIONE ACL ──────────────────────────────────────
access-list 1 deny host 192.168.1.1       ! nega host specifico
access-list 1 permit any                   ! permette tutto il resto

access-list 2 permit 192.168.2.0 0.0.0.255 ! permette una rete
access-list 2 deny any                     ! nega tutto il resto

! ── APPLICAZIONE ─────────────────────────────────────────
interface FastEthernet1/0
 ip access-group 1 out                    ! applica ACL 1 in uscita

interface FastEthernet1/0
 ip access-group 2 out                    ! applica ACL 2 in uscita

interface Serial2/0
 ip access-group 2 out                    ! applica ACL 2 in uscita

! ── RIMOZIONE ────────────────────────────────────────────
interface FastEthernet1/0
 no ip access-group 1 out                 ! rimuove l'ACL dall'interfaccia
no access-list 1                          ! elimina l'intera ACL

! ── VERIFICA ─────────────────────────────────────────────
show access-lists                          ! tutte le ACL con contatori
show access-lists 1                        ! solo ACL 1
show ip interface FastEthernet1/0          ! ACL applicate sull'interfaccia
clear ip access-list counters              ! azzera i contatori per nuovi test
```

---

## 📋 Confronto tra i due esercizi

| | Esercizio 1 | Esercizio 2 |
|---|---|---|
| **Obiettivo** | Blocca un singolo host (PC0) | Blocca intere reti (LAN1 ↔ LAN3) |
| **Tipo di filtraggio** | Host singolo con `host` keyword | Rete con wildcard mask |
| **N° interfacce** | 1 (Fa1/0) | 2 (Fa1/0 + Se2/0) |
| **Logica ACL** | deny host → permit any | permit LAN2 → deny any |
| **Wildcard mask** | `0.0.0.0` (host singolo) | `0.0.0.255` (intera /24) |
| **Direzione** | `out` su Fa1/0 | `out` su Fa1/0 e Se2/0 |
| **Dove applicare** | Vicino alla destinazione (LAN 2) | Vicino alla destinazione (LAN 2 e LAN 3) |

---

## 📋 Domande di verifica

1. Nell'Esercizio 1 l'ACL è applicata `out` su Fa1/0. Cosa succederebbe se la applicassimo `in` su Fa0/0 (interfaccia verso LAN 1)? Il risultato sarebbe identico, parzialmente diverso o completamente diverso? Perché le ACL standard **non** si applicano vicino alla sorgente?

2. Nell'Esercizio 1, il ping da PC6 (LAN 3) verso PC0 (LAN 1) funziona o no? Prima di testarlo, ragiona: il traffico LAN 3 → LAN 1 passa per Fa1/0 di Router0?

3. Nell'Esercizio 2 la regola `deny any` è esplicita. Qual è la differenza pratica tra avere un `deny any` esplicito e affidarsi al `deny implicito` di Cisco IOS? (suggerimento: pensa al logging)

4. Calcola le wildcard mask per le seguenti subnet mask:
   - `255.255.0.0` → ?
   - `255.255.255.128` → ?
   - `255.255.255.240` → ?

5. Nell'Esercizio 2 vengono applicate due ACL sulla stessa interfaccia (Fa1/0) ma in momenti diversi — prima l'ACL 1 dell'Esercizio 1, poi l'ACL 2. Cisco IOS permette di avere due ACL diverse applicate sulla stessa interfaccia nella stessa direzione? Cosa succede quando si applica una seconda ACL `out` su un'interfaccia che ne aveva già una?

---

## 📚 Risorse

- 🔗 [Cisco — Configuring Standard IP Access Lists](https://www.cisco.com/c/en/us/support/docs/security/ios-firewall/23602-confaccesslists.html)
- 📄 [Cisco IOS — Access Control Lists Overview](https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/sec_data_acl/configuration/xe-3s/sec-data-acl-xe-3s-book/sec-access-list-ovrvw.html)
- 🖧 [Cisco Packet Tracer — download gratuito](https://www.netacad.com/courses/packet-tracer)

---

## 🔗 Risorse correlate

- 🌐 **Sito:** [profgiagnotti.it](https://profgiagnotti.it)
- ▶️ **YouTube:** [youtube.com/@profgiagnotti](https://youtube.com/@profgiagnotti)
- 💬 **Discord:** [Unisciti alla community](https://discord.gg/profgiagnotti)

---

*Materiale a scopo educativo · Licenza MIT · Prof. Giagnotti*
