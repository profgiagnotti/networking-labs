# Laboratorio 2 – Analisi delle connessioni con netstat / ss

## Obiettivo
- Visualizzare connessioni attive
- Identificare porte e processi
- Comprendere il ruolo del livello di trasporto

## Prerequisiti
- Sistema Linux o Windows
- Terminale / Prompt dei comandi

---

## Parte 1 – Visualizzare connessioni

### Su Linux: 
'ss -tuln'


oppure: 'netstat -tuln'


### Su Windows:
'netstat -an'


---

## Parte 2 – Analisi output

Osservare:
- Indirizzo locale
- Porta
- Stato della connessione (LISTEN, ESTABLISHED)

Esempio: '192.168.1.5:22'


Domande:
- Qual è la porta?
- È lato client o server?

---

## Parte 3 – Connessioni attive

1. Aprire un browser e visitare un sito
2. Eseguire: 'ss -t'

3. Individuare connessioni ESTABLISHED

---

## Parte 4 – Identificare servizi

Alcune porte comuni:
- 80 → HTTP
- 443 → HTTPS
- 22 → SSH

---

## Domande finali

- Che differenza c’è tra LISTEN e ESTABLISHED?
- Quali porte sono attive nel tuo sistema?
- Quante connessioni TCP hai trovato?
