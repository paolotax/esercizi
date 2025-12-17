# Guida Deploy con Kamal - paolotax.it

## Configurazione completata:
- ✅ Server: 46.224.19.243
- ✅ Dominio: paolotax.it
- ✅ Immagine Docker: ghcr.io/paolotax/esercizi
- ✅ Registry: GitHub Container Registry (ghcr.io)

## Prerequisiti

### 1. GitHub Personal Access Token
Devi creare un Personal Access Token per pubblicare su GitHub Container Registry:

1. Vai su https://github.com/settings/tokens/new
2. Dai un nome al token (es. "Kamal Deploy - paolotax.it")
3. Seleziona la scadenza (es. "No expiration" o 90 giorni)
4. Seleziona i permessi:
   - ✅ **write:packages**
   - ✅ **read:packages**
5. Clicca su "Generate token"
6. Copia il token (inizia con ghp_...)

Poi esporta la variabile d'ambiente:
```bash
export KAMAL_REGISTRY_PASSWORD="ghp_your_github_token_here"
```

### 2. Accesso SSH al server
Verifica di poter accedere al server:
```bash
ssh root@46.224.19.243
```

Se non hai ancora configurato l'accesso con chiave SSH:
```bash
ssh-copy-id root@46.224.19.243
```

Se usi un utente diverso da root, modifica `config/deploy.yml` aggiungendo:
```yaml
ssh:
  user: tuo-username
```

### 3. DNS Configuration
Assicurati che il dominio paolotax.it punti a 46.224.19.243:
```bash
dig paolotax.it
```

## Passi per il Deploy

### 1. Setup iniziale del server
Questo installa Docker sul server e configura l'ambiente:
```bash
bin/kamal setup
```

Questo comando:
- Installa Docker sul server remoto
- Crea le directory necessarie
- Configura il proxy Traefik per SSL (Let's Encrypt)
- Avvia l'applicazione

### 2. Deploy successivi
Per aggiornamenti futuri:
```bash
bin/kamal deploy
```

## Comandi Utili

### Vedere i logs
```bash
bin/kamal logs
# oppure
bin/kamal logs -f  # follow mode
```

### Accedere alla console Rails
```bash
bin/kamal console
```

### Accedere alla shell del container
```bash
bin/kamal shell
```

### Riavviare l'applicazione
```bash
bin/kamal app restart
```

### Vedere lo stato dei container
```bash
bin/kamal app details
```

### Vedere i container in esecuzione
```bash
bin/kamal app containers
```

## Troubleshooting

### Verificare che Docker sia installato sul server
```bash
ssh root@46.224.19.243 "docker ps"
```

### Verificare il proxy Traefik
```bash
ssh root@46.224.19.243 "docker ps | grep traefik"
```

### Vedere i certificati SSL
```bash
ssh root@46.224.19.243 "ls -la /letsencrypt/certificates/"
```

### Rollback all'ultima versione funzionante
```bash
bin/kamal rollback
```

### Logs dettagliati del deploy
```bash
bin/kamal deploy --verbose
```

## Note Importanti

1. **RAILS_MASTER_KEY**: Viene letto automaticamente da `config/master.key` (vedi `.kamal/secrets`)
2. **SSL**: Traefik gestirà automaticamente i certificati SSL via Let's Encrypt
3. **Database**: L'app usa SQLite con volume persistente in `/rails/storage`
4. **Porte**: Il container espone la porta 80, Traefik gestisce 80 e 443

## Variabili d'Ambiente

Le variabili sensibili sono definite in `.kamal/secrets`:
- `KAMAL_REGISTRY_PASSWORD`: Password/token per Docker Hub
- `RAILS_MASTER_KEY`: Chiave per decifrare le credentials Rails

## File di Configurazione

- `config/deploy.yml`: Configurazione principale Kamal
- `.kamal/secrets`: Secrets e variabili d'ambiente (non committare!)
- `Dockerfile`: Definizione dell'immagine Docker

## Requisiti Server

Il server deve avere:
- Docker installato (Kamal lo installa automaticamente)
- Porte 80 e 443 aperte
- Accesso SSH configurato
- Almeno 1GB RAM (consigliato 2GB+)

