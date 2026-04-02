# 🔬 Lab — VPN Site-to-Site IPsec su router Cisco IOS

![Materia](https://img.shields.io/badge/materia-Networking-3DE8A0?style=flat-square)
![Anno](https://img.shields.io/badge/anno-5-3DE8A0?style=flat-square)
![Modulo](https://img.shields.io/badge/modulo-3-3DE8A0?style=flat-square)
![Livello](https://img.shields.io/badge/livello-avanzato-FF5C5C?style=flat-square)
![Tool](https://img.shields.io/badge/tool-Packet%20Tracer-1BA0D7?style=flat-square&logo=cisco)

> Laboratorio pratico su VPN Site-to-Site con IPsec — Anno 5, Modulo 3  
> 🌐 Teoria collegata: [profgiagnotti.it — L07 IPsec: protocollo, modalità e negoziazione](https://profgiagnotti.it/corsi/networking/)

---

## 🎯 Obiettivi

Al termine di questo laboratorio sarai in grado di:

- ✅ Costruire una topologia con due sedi collegate tramite un router Internet simulato
- ✅ Configurare la **ISAKMP policy** (Fase 1 IKE) su entrambi i router
- ✅ Configurare il **transform set** (Fase 2 IKE — ESP con AES e SHA)
- ✅ Definire la **crypto ACL** per selezionare il traffico da proteggere
- ✅ Creare e applicare la **crypto map** all'interfaccia WAN
- ✅ Verificare il tunnel con `show crypto isakmp sa` e `show crypto ipsec sa`
- ✅ Confermare che il traffico tra le due LAN viene cifrato nel tunnel

---

## 🗺️ Topologia di rete

```
┌────────────────────────────┐         ┌────────────────────────────┐
│       SEDE A               │         │       SEDE B               │
│   LAN: 192.168.1.0/24      │         │   LAN: 192.168.2.0/24      │
│                            │         │                            │
│  [PC-A1] 192.168.1.10      │         │  [Web Server] 192.168.2.2  │
│  [PC-A2] 192.168.1.20      │         │        |                   │
│       |                    │         │        |                   │
│  [Switch-A]                │         │  [Switch-B]                │
│       | Fa0/3              |         |        | Fa0/3             |
|       |                    |         |        |                   |
|       │ G0/0               |         |        │ G0/0              |
│  [Router A]                │         │  [Router B]                │
│       | G0/1               │         │        | G0/1              │
│   100.0.0.2                │         │   200.0.0.2                │
└────────────┬───────────────┘         └──────────────┬─────────────┘
             │                                        │
             │ G0/0  100.0.0.1    200.0.0.1  G0/1     │
             └──────────[Router ISP]──────────────────┘
                         (simula Internet)
```

---

## 📋 Piano di indirizzamento

| Dispositivo | Interfaccia | Indirizzo IP | Subnet Mask | Gateway |
|---|---|---|---|---|
| PC-A1 | Fa0 | 192.168.1.10 | 255.255.255.0 | 192.168.1.1 |
| PC-A2 | Fa0 | 192.168.1.20 | 255.255.255.0 | 192.168.1.1 |
| Web Server | Fa0 | 192.168.2.2 | 255.255.255.0 | 192.168.2.1 |
| Router A — verso LAN Sede A | G0/0 | 192.168.1.1 | 255.255.255.0 | — |
| Router A — verso ISP | G0/1 | 100.0.0.2 | 255.255.255.252 | — |
| Router B — verso LAN Sede B | G0/0 | 192.168.2.1 | 255.255.255.0 | — |
| Router B — verso ISP | G0/1 | 200.0.0.2 | 255.255.255.252 | — |
| Router ISP — verso Router A | G0//0 | 100.0.0.1 | 255.255.255.252 | — |
| Router ISP — verso Router B | G0/1 | 200.0.0.2 | 255.255.255.252 | — |

> 📌 **Nota sugli indirizzi WAN**: nei laboratori Packet Tracer è comune usare reti /30 per i link punto-punto WAN — contengono solo 2 indirizzi host, esattamente quelli necessari.

---

## 📋 Step 1 — Costruzione della topologia

### 1.1 — Dispositivi da inserire

| Dispositivo | Modello PT | Quantità |
|---|---|---|
| Router A (Sede A) | Router 1941 | 1 |
| Router B (Sede B) | Router 1941 | 1 |
| Router ISP (Internet) | Router 1941 | 1 |
| Switch Sede A | 2960-24TT | 1 |
| Switch Sede B | 2960-24TT | 1 |
| PC Sede A | PC-PT | 2 |
| Web Server | Server-PT | 1 |

### 1.2 — Cablaggio

| Da | Porta | A | Porta | Tipo cavo |
|---|---|---|---|---|
| PC-A1 | Fa0 | Switch-A | Fa0/1 | Dritto |
| PC-A2 | Fa0 | Switch-A | Fa0/2 | Dritto |
| Switch-A | Fa0/3 | Router A | G0/0 | Dritto |
| Router A | G0/1 | Router ISP | G0/0 | Incrociato |
| Router ISP | G0/1 | Router B | G0/1 | Incrociato |
| Router B | G0/0 | Switch-B | Fa0/3 | Dritto |
| Switch-B | Fa0/1 | Web Server | Fa0 | Dritto |



---

## 📋 Step 2 — Configurazione IPsec su Router A

Prima di configurare il protocollo IPsec dobbiamo installare il software securityk9 sui Router A e Router B:

```
Router> enable
Router# configure terminal
Router(config)# hostname RouterA
RouterA(config)# licence boot module c1900 technology-ackage security k9
RouterA# wr mem
RouterA# reload

!idem per il Router B
Router> enable
Router# configure terminal
Router(config)# hostname RouterB
RouterB(config)# licence boot module c1900 technology-ackage security k9
RouterB# wr mem
RouterB# reload
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


## 📋 Step 3 — Configurazione base (prerequisito VPN)

Prima di configurare IPsec, la rete deve essere operativa: interfacce configurate e routing funzionante.

### Router ISP — configurazione interfacce e routing

```
Router> enable
Router# configure terminal
Router(config)# hostname RouterISP

! Interfaccia verso Router A
RouterISP(config)# interface G0/0
RouterISP(config-if)# ip address 100.0.0.1 255.255.255.252
RouterISP(config-if)# no shutdown
RouterISP(config-if)# exit

! Interfaccia verso Router B
RouterISP(config)# interface G1/0
RouterISP(config-if)# ip address 200.0.0.1 255.255.255.252
RouterISP(config-if)# no shutdown
RouterISP(config-if)# exit

! Routing con protocollo RIP v1 (per semplicità nell'attività di laboratorio)
! (nella realtà Internet non conosce gli IP privati — servirebbe il NAT, PAT)
! (Alternativa -> rotte statiche)
RouterISP(config)# router rip
RouterISP(config)# network 100.0.0.0
RouterISP(config)# network 200.0.0.0

! Rotta verso il link WAN di Router B
RouterISP(config)# ip route 200.0.0.0 255.255.255.252 200.0.0.2


RouterISP(config)# end
RouterISP# write memory
```

### Router A — configurazione base

```


! Interfaccia LAN verso Sede A
RouterA(config)# interface G0/0
RouterA(config-if)# ip address 192.168.1.1 255.255.255.0
RouterA(config-if)# description LAN-Sede-A
RouterA(config-if)# no shutdown
RouterA(config-if)# exit

! Interfaccia WAN verso ISP (IP pubblico Sede A)
RouterA(config)# interface G0/1
RouterA(config-if)# ip address 100.0.0.2 255.255.255.252
RouterA(config-if)# description WAN-verso-ISP
RouterA(config-if)# no shutdown
RouterA(config-if)# exit

! Routing con protocollo RIP v1 (per semplicità nell'attività di laboratorio)
! (Alternativa -> rotta di default 0.0.0.0 0.0.0.0 100.0.0.2)
RouterISP(config)# router rip
RouterISP(config)# network 100.0.0.0
RouterISP(config)# network 192.168.1.0

RouterA(config)# end
RouterA# write memory
```

### Router B — configurazione base

```


! Interfaccia LAN verso Sede B
RouterB(config)# interface G0/0
RouterB(config-if)# ip address 192.168.2.1 255.255.255.0
RouterB(config-if)# description LAN-Sede-B
RouterB(config-if)# no shutdown
RouterB(config-if)# exit

! Interfaccia WAN verso ISP (IP pubblico Sede B)
RouterB(config)# interface G0/1
RouterB(config-if)# ip address 200.0.0.2 255.255.255.252
RouterB(config-if)# description WAN-verso-ISP
RouterB(config-if)# no shutdown
RouterB(config-if)# exit

! Routing con protocollo RIP v1 (per semplicità nell'attività di laboratorio)
! (Alternativa -> rotta di default 0.0.0.0 0.0.0.0 200.0.0.2)
RouterISP(config)# router rip
RouterISP(config)# network 200.0.0.0
RouterISP(config)# network 192.168.2.0

RouterB(config)# end
RouterB# write memory
```

### Configurazione dei dispositivi terminali

**PC-A1**: IP `192.168.1.10` / SM `255.255.255.0` / GW `192.168.1.1`  
**PC-A2**: IP `192.168.1.20` / SM `255.255.255.0` / GW `192.168.1.1`  
**Web Server**: IP `192.168.2.2` / SM `255.255.255.0` / GW `192.168.2.1`  

**Services → HTTP → ON**

Modifica `index.html`:
```
<!DOCTYPE html>
<html>
<body>
  <h1>La VPN Site-to-Site funziona!</h1>
</body>
</html>
```

### Verifica connettività base (senza VPN)

Da **PC-A1**: `Desktop → Command Prompt`
```
ping 200.0.0.2    ! → IP pubblico Router B: deve rispondere ✅
ping 192.168.2.2  ! → Web Server: deve rispondere ✅ (PRIMA della VPN)
```

> 📌 Assicurati che questi ping funzionino **prima** di configurare IPsec. Se non funzionano il problema è nel routing, non nella VPN.

---


La configurazione IPsec segue sempre quattro passi. Ogni passo corrisponde a un elemento della negoziazione IKE.

### Passo 1 — ISAKMP Policy (Fase 1 IKE)

```
RouterA(config)# crypto isakmp policy 10
! Il numero 10 è la priorità della policy (più basso = più prioritario)
! Se esiste più di una policy, il router sceglie quella con priorità più alta
! che sia compatibile con il peer

RouterA(config-isakmp)# encryption aes 256
! Algoritmo di cifratura per il canale IKE di controllo

RouterA(config-isakmp)# hash sha
! Algoritmo di hash per verificare l'integrità dei messaggi IKE

RouterA(config-isakmp)# authentication pre-share
! Metodo di autenticazione tra i due peer
! pre-share = chiave segreta condivisa (Pre-Shared Key, PSK)
! L'alternativa è "rsa-sig" con certificati digitali

RouterA(config-isakmp)# group 5
! Gruppo Diffie-Hellman per lo scambio sicuro delle chiavi
! Gruppo 5 = 1536 bit — obsoleto ma il massimo possibile in simulazione con PKT
! Gruppo 14 = 2048 bit — il minimo raccomandato oggi
! Gruppi 19 e 20 (384/256-bit ellittico) sono ancora più sicuri

RouterA(config-isakmp)# lifetime 86400
! Durata della SA IKE in secondi: 86400 = 24 ore
! Dopo la scadenza le chiavi vengono rinegoziati automaticamente

RouterA(config-isakmp)# exit

! Definisce la chiave pre-condivisa per il peer Router B
! La chiave DEVE essere identica su entrambi i router
RouterA(config)# crypto isakmp key VpnSecret!2026 address 200.0.0.2
! "VpnSecret!2026" = chiave segreta (sceglila lunga e complessa)
! "200.0.0.2" = IP pubblico dell'altro peer (Router B)
```

### Passo 2 — Transform Set (Fase 2 IKE)

```
! Il transform set definisce gli algoritmi per proteggere i DATI degli utenti
! (non il canale di controllo IKE, quello era definito al Passo 1)
RouterA(config)# crypto ipsec transform-set TS-SEDE-A-B esp-aes 256 esp-sha-hmac
! "TS-SEDE-A-B" = nome del transform set (sceglilo descrittivo)
! esp-aes 256   = cifratura ESP con AES a 256 bit
! esp-sha-hmac = integrità ESP con HMAC-SHA
```

### Passo 3 — Crypto ACL (traffico da proteggere)

```
! Questa ACL NON filtra il traffico — lo SELEZIONA per la cifratura
! Solo il traffico che corrisponde a questa ACL viene cifrato nel tunnel
! Il resto del traffico (es. navigazione Internet) passa normalmente

RouterA(config)# ip access-list extended ACL-VPN-A-B
RouterA(config-ext-nacl)# permit ip 192.168.1.0 0.0.0.255 192.168.2.0 0.0.0.255
! Tutto il traffico IP da LAN Sede A (192.168.1.0/24)
! verso LAN Sede B (192.168.2.0/24) verrà cifrato e tunnelato

RouterA(config-ext-nacl)# exit

! IMPORTANTE: su Router B la crypto ACL è SPECULARE (src e dst invertiti)
! permit ip 192.168.2.0 0.0.0.255 192.168.1.0 0.0.0.255
```

### Passo 4 — Crypto Map e applicazione

```
! La crypto map lega insieme ISAKMP policy, transform set e crypto ACL
RouterA(config)# crypto map VPN-MAP-A 10 ipsec-isakmp
! "VPN-MAP-A" = nome della crypto map
! "10" = numero di sequenza (priorità, come nella ISAKMP policy)
! ipsec-isakmp = usa IKE per la negoziazione automatica delle chiavi

RouterA(config-crypto-map)# set peer 200.0.0.2
! IP pubblico del router dell'altra sede (Router B)
! È l'indirizzo verso cui vengono mandati i pacchetti del tunnel

RouterA(config-crypto-map)# set transform-set TS-SEDE-A-B
! Usa il transform set definito al Passo 2

RouterA(config-crypto-map)# match address ACL-VPN-A-B
! Usa la crypto ACL definita al Passo 3
! Solo il traffico che corrisponde a questa ACL usa questo tunnel

RouterA(config-crypto-map)# set security-association lifetime seconds 3600
! Durata della IPsec SA (Fase 2): 3600 = 1 ora
! Più breve della Fase 1 — le chiavi dati cambiano più spesso per sicurezza

RouterA(config-crypto-map)# exit

! Applica la crypto map sull'interfaccia WAN
! DEVE essere applicata sull'interfaccia che riceve/invia traffico Internet
RouterA(config)# interface G0/1
RouterA(config-if)# crypto map VPN-MAP-A
! Da questo momento, ogni pacchetto in uscita che corrisponde
! alla crypto ACL verrà cifrato e incapsulato nel tunnel IPsec

RouterA(config-if)# exit
RouterA(config)# end
RouterA# write memory
```

---

## 📋 Step 4 — Configurazione IPsec su Router B



La configurazione è **speculare** a Router A. Le differenze sono:
- IP del peer: `200.0.0.1` (Router A)
- Crypto ACL: sorgente e destinazione invertite

```
! ─── PASSO 1: ISAKMP Policy ────────────────────────────────────────────
RouterB(config)# crypto isakmp policy 10
RouterB(config-isakmp)# encryption aes 256
RouterB(config-isakmp)# hash sha
RouterB(config-isakmp)# authentication pre-share
RouterB(config-isakmp)# group 5
RouterB(config-isakmp)# lifetime 86400
RouterB(config-isakmp)# exit

! Stessa chiave di Router A — DEVE essere identica
RouterB(config)# crypto isakmp key VpnSecret!2026 address 100.0.0.2
! "100.0.0.2" = IP pubblico del peer (Router A)

! ─── PASSO 2: Transform Set ─────────────────────────────────────────────
! Stesso transform set di Router A — algoritmi devono coincidere
RouterB(config)# crypto ipsec transform-set TS-SEDE-B-A esp-aes 256 esp-sha-hmac
RouterB(cfg-crypto-trans)# exit

! ─── PASSO 3: Crypto ACL ────────────────────────────────────────────────
! ATTENZIONE: sorgente e destinazione sono INVERTITE rispetto a Router A
RouterB(config)# ip access-list extended ACL-VPN-B-A
RouterB(config-ext-nacl)# permit ip 192.168.2.0 0.0.0.255 192.168.1.0 0.0.0.255
! Traffico da LAN Sede B → LAN Sede A viene cifrato
RouterB(config-ext-nacl)# exit

! ─── PASSO 4: Crypto Map e applicazione ─────────────────────────────────
RouterB(config)# crypto map VPN-MAP-B 10 ipsec-isakmp
RouterB(config-crypto-map)# set peer 100.0.0.2
! IP pubblico del peer = Router A
RouterB(config-crypto-map)# set transform-set TS-SEDE-B-A
RouterB(config-crypto-map)# match address ACL-VPN-B-A
RouterB(config-crypto-map)# set security-association lifetime seconds 3600
RouterB(config-crypto-map)# exit

RouterB(config)# interface G0/1
RouterB(config-if)# crypto map VPN-MAP-B
RouterB(config-if)# exit

RouterB(config)# end
RouterB# write memory
```


---

## 📋 Step 5 — Verifica del tunnel

### Verifica Fase 1 — IKE SA

```
RouterA# show crypto isakmp sa
```

Output atteso con tunnel attivo:
```
dst             src             state          conn-id slot status
200.0.0.2       100.0.0.1       QM_IDLE             1    0 ACTIVE
```

- `QM_IDLE` → la Fase 1 è completata e il canale IKE è attivo
- Se lo stato è `MM_NO_STATE` o `AG_NO_STATE` → la Fase 1 sta ancora negoziando o ha fallito

### Verifica Fase 2 — IPsec SA

```
RouterA# show crypto ipsec sa
```

Output atteso (estratto):
```
interface: GigabitEthernet0/1
    Crypto map tag: VPN-MAP-A, local addr 100.0.0.2

   protected vrf: (none)
   local  ident (addr/mask/prot/port): (192.168.1.0/255.255.255.0/0/0)
   remote ident (addr/mask/prot/port): (192.168.2.0/255.255.255.0/0/0)
   current_peer 200.0.0.2 port 500

    #pkts encaps: 5, #pkts encrypt: 5, #pkts digest: 5
    #pkts decaps: 5, #pkts decrypt: 5, #pkts verify: 5
```

- `#pkts encaps/encrypt` → pacchetti **cifrati** in uscita (Sede A → Sede B)
- `#pkts decaps/decrypt` → pacchetti **decifrati** in ingresso (Sede B → Sede A)
- I contatori devono aumentare dopo ogni ping

### Verifica la crypto map

```
RouterA# show crypto map
```

Mostra la configurazione completa della crypto map con peer, transform set e ACL.

### Test di connettività con tunnel attivo

Da **PC-A1**:
```
ping 192.168.2.2     ! → Web Server: deve rispondere ✅
```

Da **Web Server**:
```
ping 192.168.1.10    ! → PC-A1: deve rispondere ✅
```

---

## 📋 Step 6 — Verifica che il traffico sia davvero cifrato

Uno dei test più importanti: verificare che il traffico tra le LAN usi il tunnel e non passi in chiaro.

### Test: il traffico nel tunnel NON è visibile in chiaro

In modalità **Simulazione** di Packet Tracer:
1. Clicca su **Simulation** (in basso a destra)
2. Imposta il filtro su `ICMP` 
3. Esegui un ping da PC-A1 verso 192.168.2.2
4. Osserva i pacchetti che attraversano il collegamento tra Router A e Router ISP:
   - I pacchetti devono essere di tipo **ESP** (non ICMP in chiaro)
   - L'header esterno mostra gli IP pubblici 100.0.0.2 → 200.0.0.2
   - Il payload è cifrato — non si vede il contenuto ICMP originale

### Test: traffico fuori dal tunnel passa normalmente

Aggiungi un server su una terza rete (es. 8.8.8.8 simulato) e verifica che il traffico Internet dei PC non venga cifrato nel tunnel — solo il traffico verso l'altra sede deve essere protetto.

---

## 📋 Step 7 — Debug e risoluzione problemi

Se il tunnel non si stabilisce, usa questi comandi per identificare il problema:

```
! Debug IKE — mostra i messaggi di negoziazione in tempo reale
RouterA# debug crypto isakmp
! Avvia un ping verso l'altra sede e osserva l'output

! Se la Fase 1 fallisce, i messaggi mostrano dove si è bloccata la negoziazione
! Cause comuni:
! - chiavi pre-condivise diverse sui due router
! - algoritmi incompatibili (encryption, hash, group devono coincidere)
! - IP del peer errato

! Debug IPsec — mostra i dettagli della Fase 2
RouterA# debug crypto ipsec

! IMPORTANTE: disabilita sempre il debug dopo l'uso
RouterA# undebug all
! oppure
RouterA# no debug all
```

### Problemi comuni e soluzioni

| Problema | Causa probabile | Soluzione |
|---|---|---|
| Fase 1 non si stabilisce | Chiavi PSK diverse o algoritmi incompatibili | Verifica `crypto isakmp policy` e `crypto isakmp key` su entrambi i router |
| Fase 1 OK ma Fase 2 fallisce | Transform set incompatibili | Verifica `crypto ipsec transform-set` — devono usare gli stessi algoritmi |
| Tunnel attivo ma ping fallisce | Crypto ACL errata | Verifica che la ACL corrisponda al traffico: sorgente/dest corrette, wildcard corretta |
| Primo ping fallisce | Timeout negoziazione | Normale — riprova il ping, il tunnel sarà già attivo |
| `#pkts encaps` cresce ma `#pkts decaps` rimane 0 | Router B non risponde | Verifica configurazione Router B, soprattutto il peer address |

---

## 📋 Riepilogo comandi

```
! ── CONFIGURAZIONE VPN ────────────────────────────────────────────────

! FASE 1 — ISAKMP Policy
crypto isakmp policy <priorità>
 encryption aes 256
 hash sha
 authentication pre-share
 group 5
 lifetime 86400

! Chiave pre-condivisa
crypto isakmp key <CHIAVE-SEGRETA> address <IP-PEER>

! FASE 2 — Transform Set
crypto ipsec transform-set <NOME> esp-aes 256 esp-sha-hmac
 mode tunnel

! Crypto ACL
ip access-list extended <NOME-ACL>
 permit ip <LAN-LOCALE> <WILDCARD> <LAN-REMOTA> <WILDCARD>

! Crypto Map
crypto map <NOME-MAP> <SEQ> ipsec-isakmp
 set peer <IP-PEER>
 set transform-set <NOME-TS>
 match address <NOME-ACL>
 set security-association lifetime seconds 3600

! Applicazione sull'interfaccia WAN
interface <INTERFACCIA-WAN>
 crypto map <NOME-MAP>

! ── VERIFICA ──────────────────────────────────────────────────────────
show crypto isakmp sa         ! stato Fase 1 — cerca QM_IDLE
show crypto ipsec sa          ! stato Fase 2 — controlla contatori
show crypto map               ! configurazione completa
show crypto isakmp policy     ! verifica parametri Fase 1
show crypto ipsec transform-set ! verifica transform set

! ── DEBUG ─────────────────────────────────────────────────────────────
debug crypto isakmp           ! negoziazione Fase 1 in tempo reale
debug crypto ipsec            ! negoziazione Fase 2 in tempo reale
undebug all                   ! disabilita tutti i debug
```

---

## 📋 Domande di verifica

1. Dopo la configurazione, esegui `show crypto isakmp sa` su Router A. Cosa indica lo stato `QM_IDLE`? Cosa indicherebbe invece `MM_NO_STATE`?

2. La crypto ACL su Router A è `permit ip 192.168.1.0 0.0.0.255 192.168.2.0 0.0.0.255` mentre su Router B è `permit ip 192.168.2.0 0.0.0.255 192.168.1.0 0.0.0.255`. Perché devono essere **speculari** e cosa succederebbe se su Router B usassi la stessa ACL di Router A?

3. Nel transform set hai usato `esp-aes 256 esp-sha-hmac`. Cosa succederebbe se su Router A usassi `esp-aes 128` e su Router B `esp-aes 256`? La Fase 2 si completterebbe?

4. Il primo ping da PC-A1 verso Web Server spesso fallisce, mentre i successivi funzionano. Spiega il motivo tecnico di questo comportamento collegandolo al meccanismo di attivazione on-demand del tunnel IPsec.

5. Esamina l'output di `show crypto ipsec sa` sul tuo router. Identifica i campi `#pkts encaps` e `#pkts decaps`. Dopo dieci ping da PC-A1 verso Web Server, di quanto dovresti aspettarti che questi contatori siano aumentati? Perché entrambi aumentano invece di uno solo?

6. Cos'è il `lifetime` della SA e perché la IPsec SA (Fase 2, 3600s) ha una durata più breve della IKE SA (Fase 1, 86400s)?

---

## 📚 Risorse

- 🔗 [Cisco — Site-to-Site IPsec VPN Configuration Guide](https://www.cisco.com/c/en/us/support/docs/security-vpn/ipsec-negotiation-ike-protocols/217432-configure-site-to-site-ipsec-vpn.html)
- 📄 [NIST SP 800-77 — Guide to IPsec VPNs](https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-77.pdf)
- 📋 [RFC 7296 — IKEv2](https://www.rfc-editor.org/rfc/rfc7296)

---

## 🔗 Risorse correlate

- 🌐 **Sito:** [profgiagnotti.it](https://profgiagnotti.it)
- ▶️ **YouTube:** [youtube.com/@profgiagnotti](https://youtube.com/@profgiagnotti)
- 💬 **Discord:** [Unisciti alla community](https://discord.gg/profgiagnotti)

---

*Materiale a scopo educativo · Licenza MIT · Prof. Giagnotti*
