# 🔬 Lab — API REST con Postman e JSONPlaceholder

![Materia](https://img.shields.io/badge/materia-Networking-3DE8A0?style=flat-square)
![Anno](https://img.shields.io/badge/anno-5-3DE8A0?style=flat-square)
![Modulo](https://img.shields.io/badge/modulo-1-3DE8A0?style=flat-square)
![Livello](https://img.shields.io/badge/livello-intermedio-FFAA3D?style=flat-square)
![Strumenti](https://img.shields.io/badge/strumenti-Postman%20%7C%20Thunder%20Client-4A9EFF?style=flat-square)

> Laboratorio pratico sul livello applicativo TCP/IP — Anno 5, Modulo 1  
> 🌐 Teoria collegata: [profgiagnotti.it](https://profgiagnotti.it/corsi/networking/)

---

## 🎯 Obiettivi

Al termine di questo laboratorio sarai in grado di:

- ✅ Installare e configurare **Postman** (o Thunder Client) per inviare richieste HTTP a un'API REST
- ✅ Eseguire richieste **GET** verso JSONPlaceholder e interpretare i dati JSON ricevuti
- ✅ Inviare una richiesta **POST** con body JSON e leggere la risposta del server
- ✅ Collegare l'esperienza pratica ai concetti teorici: URI, metodi HTTP, status code, formato JSON

---

## 🛠️ Strumenti necessari

Scegli uno dei due client HTTP — sono equivalenti per questo laboratorio:

| Strumento | Tipo | Link |
|---|---|---|
| **Postman** | App standalone | [postman.com/downloads](https://www.postman.com/downloads/) |
| **Thunder Client** | Estensione VS Code | [VS Code Marketplace](https://marketplace.visualstudio.com/items?itemName=rangav.vscode-thunder-client) |

> **Postman** è consigliato se è la prima volta. **Thunder Client** è comodo se usi già VS Code per programmare.

---

## ℹ️ Cos'è JSONPlaceholder

**JSONPlaceholder** è una API REST pubblica e gratuita che simula un backend completo. È perfetta per fare pratica senza dover configurare nulla.

Risorse disponibili:

```
/posts      /albums     /todos
/comments   /photos     /users
```

> ⚠️ **Nota importante:** JSONPlaceholder *simula* le risposte. Le richieste POST, PUT e DELETE **non modificano dati reali** — il server risponde come se avesse eseguito l'operazione, ma senza persistenza. È completamente sicuro.

---

## 📋 Step 1 — GET: lista di foto

**Metodo:** `GET`  
**URL:** `https://jsonplaceholder.typicode.com/photos`

Imposta il metodo su GET, inserisci l'URL e premi **Send**.

**Cosa osservare nella risposta:**

- Status code: `200 OK`
- Il body contiene un array JSON con **5000 oggetti**
- Ogni oggetto ha questa struttura:

```json
{
  "albumId": 1,
  "id": 1,
  "title": "accusamus beatae ad facilis cum similique qui sunt",
  "url": "https://via.placeholder.com/600/92c952",
  "thumbnailUrl": "https://via.placeholder.com/150/92c952"
}
```

---

## 📋 Step 2 — GET: risorsa specifica con ID

**Metodo:** `GET`  
**URL:** `https://jsonplaceholder.typicode.com/photos/3622`

Aggiungendo un ID numerico alla fine dell'URI, il server restituisce **solo la risorsa con quell'ID**.

**Risposta attesa:**

```json
{
  "albumId": 73,
  "id": 3622,
  "title": "necessitatibus molestiae optio",
  "url": "https://via.placeholder.com/600/6d9d4c",
  "thumbnailUrl": "https://via.placeholder.com/150/6d9d4c"
}
```

> 💡 Copia il valore di `url` e incollalo nel browser per visualizzare l'immagine placeholder.

---

## 📋 Step 3 — POST: creare un nuovo post

**Metodo:** `POST`  
**URL:** `https://jsonplaceholder.typicode.com/posts`

**Configurazione in Postman:**

1. Metodo → **POST**
2. URL → `https://jsonplaceholder.typicode.com/posts`
3. Tab **Body** → seleziona **raw** → formato **JSON**
4. Inserisci questo body:

```json
{
  "title": "mio post",
  "body": "questo è il mio primo post",
  "userId": 1
}
```

**Risposta attesa** — status `201 Created`:

```json
{
  "title": "mio post",
  "body": "questo è il mio primo post",
  "userId": 1,
  "id": 101
}
```

> Il server ha "creato" la risorsa e restituito l'oggetto con un nuovo `id` assegnato.

---

## 🏋️ Step 4 — Esercizi di approfondimento

### Esercizio 1 — GET users
Recupera la lista degli utenti e individua quello con `id = 5`.  
**Qual è la sua email?**

```
GET https://jsonplaceholder.typicode.com/users/5
```

---

### Esercizio 2 — GET posts filtrati
Recupera solo i post dell'utente 3 usando i parametri di query.  
**Quanti post ha?**

```
GET https://jsonplaceholder.typicode.com/posts?userId=3
```

---

### Esercizio 3 — PUT aggiornamento
Invia una richiesta PUT al post con `id = 1` modificandone il titolo.  
**Cosa risponde il server? Qual è lo status code?**

```
PUT https://jsonplaceholder.typicode.com/posts/1
```

Body da inviare:
```json
{
  "id": 1,
  "title": "titolo modificato da me",
  "body": "contenuto aggiornato",
  "userId": 1
}
```

---

### Esercizio 4 — DELETE
Invia una richiesta DELETE al post con `id = 5`.  
**Qual è il codice di stato della risposta? Cosa contiene il body?**

```
DELETE https://jsonplaceholder.typicode.com/posts/5
```

---

## 🔗 Collega teoria e pratica

| Concetto teorico | Come lo vedi in questo lab |
|---|---|
| **URI** | Ogni endpoint è un URI che identifica una risorsa: `/photos/3622` |
| **Metodi HTTP** | GET, POST, PUT, DELETE → operazioni CRUD sulla risorsa |
| **Status Code** | `200 OK`, `201 Created`, `404 Not Found` — li vedi nella risposta |
| **JSON** | Formato standard delle API REST: strutturato, leggibile, compatto |
| **Query parameters** | `?userId=3` filtra i risultati direttamente nell'URL |

---

## 📌 Riepilogo

- Postman e Thunder Client permettono di testare qualsiasi API REST **senza scrivere codice**
- Aggiungere un ID all'URI (`/photos/3622`) recupera una **singola risorsa**
- Il body di una POST deve contenere **JSON valido** — imposta `Content-Type: application/json`
- I query parameters (`?userId=3`) filtrano i risultati direttamente nell'URL
- Il codice di stato nella risposta indica sempre l'esito: `2xx` = successo, `4xx` = errore client, `5xx` = errore server

---

## 📚 Risorse

- 🗃️ [JSONPlaceholder — documentazione ufficiale](https://jsonplaceholder.typicode.com/)
- 📮 [Postman Learning Center — guida introduttiva](https://learning.postman.com/docs/getting-started/first-steps/get-postman/)
- ⚡ [Thunder Client — VS Code Extension](https://marketplace.visualstudio.com/items?itemName=rangav.vscode-thunder-client)
- 🦊 [MDN — Metodi HTTP](https://developer.mozilla.org/it/docs/Web/HTTP/Methods)

---

## 🔗 Risorse correlate

- 🌐 **Sito:** [profgiagnotti.it](https://profgiagnotti.it)
- ▶️ **YouTube:** [youtube.com/@profgiagnotti](https://youtube.com/@profgiagnotti)
- 💬 **Discord:** [Unisciti alla community](https://discord.gg/profgiagnotti)

---

*Materiale a scopo educativo · Licenza MIT · Prof. Giagnotti*
