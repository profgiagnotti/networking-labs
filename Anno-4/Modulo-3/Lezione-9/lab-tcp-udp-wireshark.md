# Laboratorio 1 – Analisi del traffico con Wireshark

## Obiettivo
- Catturare pacchetti di rete
- Identificare un handshake TCP
- Distinguere traffico TCP e UDP

## Prerequisiti
- Wireshark installato
- Connessione a Internet

---

## Parte 1 – Avvio cattura pacchetti

1. Aprire Wireshark
2. Selezionare l'interfaccia di rete attiva (Wi-Fi o Ethernet)
3. Cliccare su **Start Capturing Packets**

---

## Parte 2 – Generare traffico

1. Aprire un browser
2. Visitare un sito web (es. google.com)
3. Tornare su Wireshark e fermare la cattura

---

## Parte 3 – Analisi handshake TCP

1. Inserire nel filtro: 'tcp'
2. Cercare pacchetti con flag:
- SYN
- SYN, ACK
- ACK

3. Identificare il three-way handshake:
- Client → SYN
- Server → SYN-ACK
- Client → ACK

---

## Parte 4 – Distinguere TCP e UDP

1. Filtrare traffico TCP: 'tcp'

2. Filtrare traffico UDP: 'udp'

3. Osservare differenze:
- TCP: handshake, affidabile
- UDP: nessuna connessione, più veloce

---

## Domande finali

- Qual è la differenza principale tra TCP e UDP?
- Quanti pacchetti servono per stabilire una connessione TCP?
- Hai trovato traffico UDP? In quale contesto?

