# Design: Sistema Permessi Contenuti Didattici

Data: 2026-01-05

## Obiettivo

Refactor del sistema permessi per la visualizzazione di Corsi, Volumi, Discipline e Pagine. I contenuti sono di proprietà della piattaforma (gestiti da admin) e vengono abilitati agli utenti tramite condivisione.

## Requisiti

1. **Proprietà contenuti**: Solo admin globali possiedono i contenuti
2. **Granularità condivisione**: Admin può condividere a qualsiasi livello (Corso, Volume, Disciplina, Pagina)
3. **Destinatari**: Condivisione con Account (tutti gli utenti) o User specifici
4. **Filtraggio**: Utenti vedono solo contenuti a cui hanno accesso (no contenuti "bloccati")
5. **Interfaccia admin**: Dashboard centralizzata + bottone "Condividi" su ogni risorsa
6. **Homepage**: Mostra i corsi accessibili all'utente
7. **Contenuti pubblici**: Singole pagine possono essere marcate come pubbliche (demo)
8. **Sub-condivisione**: Owner può assegnare risorse dell'account a utenti specifici

## Modello Dati

### Struttura esistente (invariata)

```
Corso → Volume → Disciplina → Pagina
         ↓
       Share (polymorphic: shareable + recipient)
```

Il modello `Share` già supporta:
- `shareable`: qualsiasi risorsa (Corso, Volume, Disciplina, Pagina)
- `recipient`: Account o User
- `permission`: view, edit, admin
- `expires_at`: scadenza opzionale
- `granted_by`: chi ha creato la condivisione

### Nuova migration

```ruby
# db/migrate/xxx_add_public_to_pagine.rb
add_column :pagine, :public, :boolean, default: false, null: false
add_index :pagine, :public
```

### Gerarchia permessi

- Admin globale → vede tutto
- Share su Corso → accesso a tutto (volumi, discipline, pagine)
- Share su Volume → accesso al volume e figli
- Share su Disciplina → accesso alla disciplina e pagine
- Share su Pagina → accesso solo a quella pagina
- Pagina `public: true` → visibile a tutti

## Controller e Autorizzazione

### Nuovo concern: ResourceAuthorization

```ruby
# app/controllers/concerns/resource_authorization.rb
module ResourceAuthorization
  extend ActiveSupport::Concern

  private

  def authorize_resource!(resource)
    unless resource_accessible?(resource)
      redirect_to root_path, alert: "Non hai accesso a questa risorsa"
    end
  end

  def resource_accessible?(resource)
    return true if admin?
    return true if resource.respond_to?(:public?) && resource.public?
    return false unless Current.user
    resource.accessible_by?(Current.user)
  end

  def current_user_or_guest
    Current.user || Guest.new
  end

  def admin?
    return false unless Current.identity
    admin_emails = Rails.application.credentials.admin_emails || []
    admin_emails.include?(Current.identity.email_address)
  end
end
```

### Guest object

```ruby
# app/models/guest.rb
class Guest
  def admin? = false
  def account = nil
  def id = nil
end
```

### Modifiche controller

**CorsiController:**
```ruby
def index
  @corsi = if admin?
    Corso.all
  elsif Current.user
    Corso.accessible_by(Current.user)
  else
    Corso.with_public_pages
  end
end

def show
  @corso = Corso.find(params[:id])
  authorize_resource!(@corso)
  @volumi = @corso.volumi.accessible_by(current_user_or_guest)
end
```

**VolumiController:**
```ruby
def index
  @volumi = if admin?
    Volume.all
  else
    Volume.accessible_by(current_user_or_guest)
  end
end

def show
  @volume = Volume.find(params[:id])
  authorize_resource!(@volume)
  @discipline = @volume.discipline.accessible_by(current_user_or_guest)
end
```

**DisciplineController:**
```ruby
def show
  @disciplina = Disciplina.find(params[:id])
  authorize_resource!(@disciplina)
  @pagine = @disciplina.pagine.accessible_by(current_user_or_guest)
end
```

**PagineController** - aggiungere check public:
```ruby
def pagina_accessible?
  return true if @pagina.public?
  return true if admin_identity?
  Current.user && @pagina.accessible_by?(Current.user)
end
```

## Homepage

**HomeController:**
```ruby
def index
  if admin?
    @recent_shares = Share.includes(:shareable, :recipient)
                          .order(created_at: :desc).limit(10)
  elsif Current.user
    @corsi = Corso.accessible_by(Current.user)
  else
    @corsi = Corso.with_public_pages
  end
end
```

**Scope su Corso:**
```ruby
scope :with_public_pages, -> {
  joins(volumi: { discipline: :pagine })
    .where(pagine: { public: true })
    .distinct
}
```

## Interfaccia Admin Condivisioni

### Routes

```ruby
namespace :admin do
  resources :shares, only: [:index, :new, :create, :destroy]
end
```

### Admin::SharesController

```ruby
class Admin::SharesController < ApplicationController
  before_action :require_admin

  def index
    @shares = Share.includes(:shareable, :recipient, :granted_by)
                   .order(created_at: :desc)
  end

  def new
    @share = Share.new(
      shareable_type: params[:shareable_type],
      shareable_id: params[:shareable_id]
    )
    @accounts = Account.all
    @users = User.includes(:account).all
  end

  def create
    @share = Share.new(share_params)
    @share.granted_by = Current.user
    if @share.save
      redirect_to admin_shares_path, notice: "Condivisione creata"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @share = Share.find(params[:id])
    @share.destroy
    redirect_to admin_shares_path, notice: "Condivisione rimossa"
  end

  private

  def share_params
    params.require(:share).permit(
      :shareable_type, :shareable_id,
      :recipient_type, :recipient_id,
      :permission, :expires_at
    )
  end

  def require_admin
    redirect_to root_path unless admin?
  end
end
```

### Bottone "Condividi" nelle viste

```erb
<% if admin? %>
  <%= link_to new_admin_share_path(
        shareable_type: "Corso",
        shareable_id: @corso.id
      ), class: "btn" do %>
    Condividi
  <% end %>
<% end %>
```

## Sub-condivisione Owner

### Routes

```ruby
namespace :account do
  resources :shares, only: [:index, :new, :create, :destroy]
end
```

### Account::SharesController

```ruby
class Account::SharesController < ApplicationController
  before_action :require_owner

  def index
    @shares = Share.where(granted_by: Current.user)
                   .where(recipient: Current.account.users)
  end

  def new
    @share = Share.new
    @available_resources = resources_shared_with_account
    @users = Current.account.users.where.not(id: Current.user.id)
  end

  def create
    @share = Share.new(share_params)
    @share.granted_by = Current.user

    unless resource_shared_with_account?(@share.shareable)
      return redirect_back fallback_location: account_shares_path,
                           alert: "Non puoi condividere questa risorsa"
    end

    unless @share.recipient_type == "User" &&
           User.find(@share.recipient_id).account == Current.account
      return redirect_back fallback_location: account_shares_path,
                           alert: "Puoi condividere solo con utenti del tuo account"
    end

    @share.permission = :view  # Owner può assegnare solo view

    if @share.save
      redirect_to account_shares_path, notice: "Condivisione creata"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @share = Share.find(params[:id])
    if @share.granted_by == Current.user
      @share.destroy
      redirect_to account_shares_path, notice: "Condivisione rimossa"
    else
      redirect_to account_shares_path, alert: "Non puoi rimuovere questa condivisione"
    end
  end

  private

  def resources_shared_with_account
    {
      corsi: Corso.accessible_by(Current.user),
      volumi: Volume.accessible_by(Current.user),
      discipline: Disciplina.accessible_by(Current.user),
      pagine: Pagina.accessible_by(Current.user)
    }
  end

  def resource_shared_with_account?(resource)
    resource.accessible_by?(Current.user)
  end
end
```

## Pagine Pubbliche

### Modello Pagina

```ruby
class Pagina < ApplicationRecord
  scope :pubbliche, -> { where(public: true) }

  scope :accessible_by, ->(user) {
    public_pages = where(public: true)

    return all if user&.admin?
    return public_pages if user.nil?

    user_recipients = [user, user.account]

    pagina_ids = Share.active.where(shareable_type: "Pagina", recipient: user_recipients).select(:shareable_id)
    disciplina_ids = Share.active.where(shareable_type: "Disciplina", recipient: user_recipients).select(:shareable_id)
    volume_ids = Share.active.where(shareable_type: "Volume", recipient: user_recipients).select(:shareable_id)
    corso_ids = Share.active.where(shareable_type: "Corso", recipient: user_recipients).select(:shareable_id)

    where(id: pagina_ids)
      .or(where(disciplina_id: disciplina_ids))
      .or(where(disciplina_id: Disciplina.where(volume_id: volume_ids)))
      .or(where(disciplina_id: Disciplina.where(volume_id: Volume.where(corso_id: corso_ids))))
      .or(public_pages)
  }

  def accessible_by?(user)
    return true if public?
    return false unless user
    return true if user.admin?
    return true if shared_with?(user)
    return true if disciplina.shared_with?(user)
    return true if disciplina.volume.shared_with?(user)
    return true if disciplina.volume.corso.shared_with?(user)
    false
  end
end
```

## File da Modificare/Creare

### Migration
- `db/migrate/xxx_add_public_to_pagine.rb`

### Modelli
- `app/models/pagina.rb` - scope `:pubbliche`, aggiornare `accessible_by`
- `app/models/corso.rb` - scope `:with_public_pages`
- `app/models/guest.rb` (nuovo)

### Concern
- `app/controllers/concerns/resource_authorization.rb` (nuovo)

### Controller (modifiche)
- `app/controllers/corsi_controller.rb`
- `app/controllers/volumi_controller.rb`
- `app/controllers/discipline_controller.rb`
- `app/controllers/pagine_controller.rb`
- `app/controllers/home_controller.rb`

### Controller (nuovi)
- `app/controllers/admin/shares_controller.rb`
- `app/controllers/account/shares_controller.rb`

### Viste (nuove)
- `app/views/admin/shares/index.html.erb`
- `app/views/admin/shares/new.html.erb`
- `app/views/account/shares/index.html.erb`
- `app/views/account/shares/new.html.erb`

### Viste (modifiche)
- `app/views/home/index.html.erb`
- `app/views/corsi/show.html.erb` - bottone Condividi
- `app/views/volumi/show.html.erb` - bottone Condividi
- `app/views/discipline/show.html.erb` - bottone Condividi
- `app/views/pagine/show.html.erb` - bottone Condividi + checkbox public

### Routes
- `config/routes.rb` - namespace admin e account con shares
