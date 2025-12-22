# Piano: Sistema di Ruoli per Esercizi (stile Fizzy)

## Obiettivo
Implementare un sistema di autenticazione e autorizzazione multi-tenant per l'applicazione esercizi, ispirato ai pattern di Fizzy.

## Configurazione Scelta
- **Auth**: Magic link (passwordless)
- **Ruoli**: Owner / Teacher / Student
- **Multi-tenant**: Sì (scuole/organizzazioni isolate)
- **Classi**: Sì, studenti organizzati in classi gestite dai teacher
- **Onboarding**: Join code + invito email

---

## File Creati

### Database Migrations
```
db/migrate/20251222075047_create_identities.rb
db/migrate/20251222075048_create_accounts.rb
db/migrate/20251222075049_create_users.rb
db/migrate/20251222075050_create_sessions.rb
db/migrate/20251222075051_create_magic_links.rb
db/migrate/20251222075052_create_account_join_codes.rb
db/migrate/20251222075053_create_classi.rb
db/migrate/20251222075054_create_classe_memberships.rb
db/migrate/20251222075055_add_account_to_existing_models.rb
```

### Models
```
app/models/current.rb                    # Context thread-local
app/models/code.rb                       # Generatore codici base32
app/models/identity.rb                   # Utente globale (email)
app/models/identity/joinable.rb          # Concern per join account
app/models/session.rb                    # Sessioni DB
app/models/magic_link.rb                 # Link magici 6 char
app/models/account.rb                    # Tenant/scuola
app/models/user.rb                       # Utente scoped con ruolo
app/models/user/role.rb                  # Gerarchia ruoli
app/models/account/join_code.rb          # Codici invito
app/models/classe.rb                     # Classi scolastiche
app/models/classe_membership.rb          # Join studenti-classi
```

### Controllers
```
app/controllers/sessions_controller.rb
app/controllers/sessions/magic_links_controller.rb
app/controllers/sessions/menus_controller.rb
app/controllers/signups_controller.rb
app/controllers/join_codes_controller.rb
app/controllers/concerns/authentication.rb
app/controllers/concerns/authorization.rb
app/controllers/strumenti/base_controller.rb
```

### Middleware
```
config/initializers/account_slug.rb      # Multi-tenancy URL-based
```

### Mailer
```
app/mailers/magic_link_mailer.rb
app/views/magic_link_mailer/sign_in_instructions.html.erb
app/views/magic_link_mailer/sign_in_instructions.text.erb
```

### Views Auth
```
app/views/sessions/new.html.erb
app/views/sessions/magic_links/show.html.erb
app/views/sessions/menus/show.html.erb
app/views/signups/new.html.erb
app/views/join_codes/new.html.erb
app/views/join_codes/inactive.html.erb
```

---

## Schema Database

### identities
- `id`, `email_address` (unique), `timestamps`

### accounts (tenant/scuola)
- `id`, `name`, `external_account_id` (unique, 7+ digits), `timestamps`

### users (membership in account)
- `id`, `account_id`, `identity_id`, `name`, `role` (owner/teacher/student), `active`, `verified_at`, `timestamps`
- Index unique su `[account_id, identity_id]`

### sessions
- `id`, `identity_id`, `ip_address`, `user_agent`, `timestamps`

### magic_links
- `id`, `identity_id`, `code` (unique), `expires_at`, `purpose`, `timestamps`

### account_join_codes
- `id`, `account_id`, `code` (unique), `role`, `usage_count`, `usage_limit`, `timestamps`

### classi
- `id`, `account_id`, `teacher_id`, `name`, `anno_scolastico`, `timestamps`

### classe_memberships
- `id`, `classe_id`, `user_id`, `timestamps`

---

## Gerarchia Ruoli

```
Owner (proprietario scuola)
  ├── può gestire tutti gli utenti
  ├── può gestire tutti gli esercizi
  ├── può gestire join codes
  └── può modificare impostazioni account

Teacher (insegnante)
  ├── può creare/modificare propri esercizi
  ├── può creare classi
  ├── può vedere tutti i tentativi
  └── eredita permessi da Owner per proprie risorse

Student (studente)
  ├── può vedere esercizi assegnati
  ├── può completare esercizi
  └── può vedere propri risultati
```

---

## Flusso Autenticazione

1. **Login**: Utente inserisce email → riceve codice 6 caratteri via email
2. **Verifica**: Inserisce codice → sessione creata → redirect a menu account
3. **Selezione Account**: Se appartiene a più scuole, seleziona quale
4. **Dashboard**: Accede alla dashboard della scuola selezionata

### URL Multi-tenant
```
/session/new                    # Login (no account scope)
/session/magic_link             # Verifica codice
/session/menu                   # Selezione account
/1000001/dashboard/esercizi     # Dashboard scuola (con account_id in URL)
/join/ABCD-1234-EFGH           # Join con codice invito
```

---

## Pattern Fizzy Utilizzati

| Pattern | File Fizzy di Riferimento |
|---------|---------------------------|
| Current context | `fizzy/app/models/current.rb` |
| Role hierarchy | `fizzy/app/models/user/role.rb` |
| Magic link | `fizzy/app/models/magic_link.rb` |
| Code generation | `fizzy/app/models/code.rb` |
| URL multi-tenancy | `fizzy/config/initializers/tenanting/account_slug.rb` |
| Authentication | `fizzy/app/controllers/concerns/authentication.rb` |
| Authorization | `fizzy/app/controllers/concerns/authorization.rb` |

---

## Comandi Post-Implementazione

```bash
# 1. Eseguire migrazioni
bin/rails db:migrate

# 2. Creare account di test (in rails console)
identity = Identity.create!(email_address: "admin@test.com")
Account.create_with_owner(
  account: { name: "Scuola Test" },
  owner: { identity: identity, name: "Admin Test" }
)

# 3. Ottenere join codes (in rails console)
account = Account.first
account.join_codes.each { |jc| puts "#{jc.role}: #{jc.code}" }

# 4. Avviare server
bin/dev
```

---

## Note Implementazione

### Controller con accesso pubblico (allow_unauthenticated_access)
- VolumiController, CorsiController, DisciplineController, PagineController
- SearchesController, ExercisesController
- PublicEserciziController
- Tutti i controller in Strumenti::

### Controller con autenticazione richiesta
- Dashboard::EserciziController (require_teacher)
- Account::* (require_owner per gestione utenti)

### Modelli aggiornati con account_id
- Corso, Volume, Disciplina, Pagina
- Esercizio (+ creator_id)
- EsercizioAttempt (+ user_id opzionale)
