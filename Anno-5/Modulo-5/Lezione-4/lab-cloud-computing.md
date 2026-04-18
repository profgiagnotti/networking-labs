# Laboratorio – Introduzione al Cloud Computing

## Obiettivo
Comprendere i principi del cloud computing attraverso attività pratiche:
- creare una macchina virtuale
- configurare un servizio web
- accedere remotamente
- simulare un'infrastruttura cloud

---

## Strumenti necessari
- :contentReference[oaicite:0]{index=0} (oppure altro hypervisor)
- Immagine Linux (es. Ubuntu Server)
- Terminale

---

## Scenario

Sei un amministratore di sistema e devi:
- creare un server nel cloud
- configurarlo
- renderlo accessibile in rete

---

# FASE 1 – Creazione macchina virtuale

## Procedura

1. Apri VirtualBox
2. Crea una nuova VM:
   - Nome: `Cloud-Server`
   - RAM: almeno 2 GB
   - Disco: 20 GB
3. Monta l'immagine ISO di Ubuntu
4. Avvia la VM e completa l'installazione

---

##  Domande

1. Cos'è una macchina virtuale?
2. Quali risorse hai assegnato?

---

# FASE 2 – Configurazione rete

## Obiettivo
Permettere alla VM di comunicare con l'esterno

## Procedura

1. Imposta la rete su:
   - NAT (semplice) oppure
   - Bridged (più realistico)

2. Verifica IP: 'ip a'


---

## ✍️ Domande

1. Che indirizzo IP ha la VM?
2. È raggiungibile dall'host?

---

# 🔹 FASE 3 – Accesso remoto (SSH)

## Procedura

1. Installa SSH:
'sudo apt update
sudo apt install openssh-server'


2. Verifica servizio:
'sudo systemctl status ssh'


3. Collegati da host:
'ssh user@IP_VM'


---

## Domande

1. Cos'è SSH?
2. Perché è importante nel cloud?

---

# FASE 4 – Deploy server web

## Procedura

1. Installa nginx:
'sudo apt install nginx'

2. Avvia servizio:
'sudo systemctl start nginx'

3. Apri browser e visita:
'http://IP_VM'


---

## 🔍 Attività

- Verifica che la pagina web sia raggiungibile
- Modifica la pagina di default

---

## ✍️ Domande

1. Che porta utilizza HTTP?
2. Il server è accessibile dall'esterno?

---

# 🔹 FASE 5 – Simulazione cloud

## Obiettivo
Comprendere il concetto di scalabilità

## Attività

- Crea una seconda VM
- Replica il server web
- Simula:
  - più utenti
  - più server

---

## Domande

1. Cos'è la scalabilità?
2. Qual è il vantaggio del cloud rispetto a un server fisico?

---

# FASE 6 – Concetti teorici

Completa:

| Modello | Descrizione |
|--------|------------|
| IaaS   |            |
| PaaS   |            |
| SaaS   |            |

---

# FASE 7 – Analisi critica

1. Quali vantaggi offre il cloud?
2. Quali rischi esistono?
3. Quando NON useresti il cloud?

---

# Consegna

- Screenshot VM
- Configurazione rete
- Server web funzionante
- Risposte alle domande

---

