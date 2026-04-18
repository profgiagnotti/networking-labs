# Laboratorio 3 – Simulazione TCP e UDP con Netcat

## Obiettivo
- Simulare una connessione TCP
- Simulare comunicazione UDP
- Comprendere le differenze pratiche

## Prerequisiti
- Netcat installato (nc)
- Due terminali

---

## Parte 1 – Connessione TCP

### Terminale 1 (server): 
'nc -l 12345'


### Terminale 2 (client):
'nc -l 12345'


---

## Parte 2 – Scambio messaggi

1. Scrivere un messaggio nel client
2. Verificare che arrivi al server
3. Rispondere dal server

✔ Connessione stabile → TCP

---

## Parte 3 – Connessione UDP

### Terminale 1 (server):
'nc -u -l 12345'


### Terminale 2 (client):
'nc -u localhost 12345'


---

## Parte 4 – Osservazioni

- I messaggi potrebbero non arrivare sempre
- Non c'è handshake
- Nessuna garanzia di consegna

---

## Parte 5 – Confronto pratico

| Caratteristica | TCP | UDP |
|---------------|-----|-----|
| Connessione   | Sì  | No  |
| Affidabilità  | Alta| Bassa |
| Velocità      | Media | Alta |

---

## Domande finali

- Qual è la differenza principale osservata?
- TCP garantisce la consegna?
- UDP è più veloce? Perché?

