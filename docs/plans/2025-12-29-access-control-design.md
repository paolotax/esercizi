# Design: Controllo Accessi Corsi, Volumi, Discipline, Pagine

**Data:** 2025-12-29
**Stato:** Approvato

## Obiettivo

Rendere Corsi, Volumi, Discipline e Pagine privati di default. Solo admin vede tutto. Insegnanti/studenti vedono solo ciò che è stato loro esplicitamente assegnato tramite Share.

## Decisioni di Design

| Aspetto | Decisione |
|---------|-----------|
| Admin | Email in `Rails.application.credentials.admin_emails` |
| Risorse assegnabili | Corso, Volume, Disciplina, Pagina (4 livelli) |
| Destinatari | User o Account (già supportato da Share) |
| Ereditarietà | Implicita: accesso a Volume = accesso a tutte le sue pagine |
| Permessi | view, edit, admin (già in Share) |

## Gerarchia Risorse

```
Corso (collana editoriale)
  └── Volume (classe)
       └── Disciplina (materia)
            └── Pagina (esercizio)
```

## Logica di Accesso

Una Pagina è accessibile se l'utente:
1. È admin, OPPURE
2. Ha Share diretto sulla Pagina, OPPURE
3. Ha Share sulla Disciplina della Pagina, OPPURE
4. Ha Share sul Volume della Disciplina, OPPURE
5. Ha Share sul Corso del Volume

Lo stesso pattern si applica risalendo la gerarchia per Disciplina, Volume e Corso.

## Componenti

### 1. Admin via Credentials

```ruby
# config/credentials.yml.enc
admin_emails:
  - paolo.tassinari@hey.com
```

```ruby
# app/models/user/admin.rb
module User::Admin
  extend ActiveSupport::Concern

  def admin?
    return false unless identity

    admin_emails = Rails.application.credentials.admin_emails || []
    admin_emails.include?(identity.email_address)
  end
end
```

### 2. Concern Shareable

```ruby
# app/models/concerns/shareable.rb
module Shareable
  extend ActiveSupport::Concern

  included do
    has_many :shares, as: :shareable, dependent: :destroy
  end

  def shared_with?(user)
    shares.active.exists?(recipient: user) ||
      shares.active.exists?(recipient: user.account)
  end
end
```

### 3. Modello Corso

```ruby
# app/models/corso.rb
class Corso < ApplicationRecord
  include Shareable

  def accessible_by?(user)
    return true if user.admin?
    shared_with?(user)
  end

  scope :accessible_by, ->(user) {
    return all if user.admin?

    user_recipients = [user, user.account]
    corso_ids = Share.active.where(shareable_type: "Corso", recipient: user_recipients).select(:shareable_id)

    where(id: corso_ids)
  }
end
```

### 4. Modello Volume

```ruby
# app/models/volume.rb
class Volume < ApplicationRecord
  include Shareable

  def accessible_by?(user)
    return true if user.admin?
    return true if shared_with?(user)
    return true if corso.shared_with?(user)

    false
  end

  scope :accessible_by, ->(user) {
    return all if user.admin?

    user_recipients = [user, user.account]

    volume_ids = Share.active.where(shareable_type: "Volume", recipient: user_recipients).select(:shareable_id)
    corso_ids = Share.active.where(shareable_type: "Corso", recipient: user_recipients).select(:shareable_id)

    where(id: volume_ids)
      .or(where(corso_id: corso_ids))
  }
end
```

### 5. Modello Disciplina

```ruby
# app/models/disciplina.rb
class Disciplina < ApplicationRecord
  include Shareable

  def accessible_by?(user)
    return true if user.admin?
    return true if shared_with?(user)
    return true if volume.shared_with?(user)
    return true if volume.corso.shared_with?(user)

    false
  end

  scope :accessible_by, ->(user) {
    return all if user.admin?

    user_recipients = [user, user.account]

    disciplina_ids = Share.active.where(shareable_type: "Disciplina", recipient: user_recipients).select(:shareable_id)
    volume_ids = Share.active.where(shareable_type: "Volume", recipient: user_recipients).select(:shareable_id)
    corso_ids = Share.active.where(shareable_type: "Corso", recipient: user_recipients).select(:shareable_id)

    where(id: disciplina_ids)
      .or(where(volume_id: volume_ids))
      .or(where(volume_id: Volume.where(corso_id: corso_ids)))
  }
end
```

### 6. Modello Pagina

```ruby
# app/models/pagina.rb
class Pagina < ApplicationRecord
  include Shareable

  def accessible_by?(user)
    return true if user.admin?
    return true if shared_with?(user)
    return true if disciplina.shared_with?(user)
    return true if disciplina.volume.shared_with?(user)
    return true if disciplina.volume.corso.shared_with?(user)

    false
  end

  scope :accessible_by, ->(user) {
    return all if user.admin?

    user_recipients = [user, user.account]

    pagina_ids = Share.active.where(shareable_type: "Pagina", recipient: user_recipients).select(:shareable_id)
    disciplina_ids = Share.active.where(shareable_type: "Disciplina", recipient: user_recipients).select(:shareable_id)
    volume_ids = Share.active.where(shareable_type: "Volume", recipient: user_recipients).select(:shareable_id)
    corso_ids = Share.active.where(shareable_type: "Corso", recipient: user_recipients).select(:shareable_id)

    where(id: pagina_ids)
      .or(where(disciplina_id: disciplina_ids))
      .or(where(disciplina_id: Disciplina.where(volume_id: volume_ids)))
      .or(where(disciplina_id: Disciplina.where(volume_id: Volume.where(corso_id: corso_ids))))
  }
end
```

### 7. Controller Protection

```ruby
# app/controllers/admin/base_controller.rb
module Admin
  class BaseController < ApplicationController
    before_action :require_admin!

    private

    def require_admin!
      unless Current.user&.admin?
        redirect_to root_path, alert: "Accesso riservato"
      end
    end
  end
end
```

```ruby
# app/controllers/pagine_controller.rb (aggiungere)
before_action :authorize_pagina!

def authorize_pagina!
  unless @pagina.accessible_by?(Current.user)
    redirect_to root_path, alert: "Non hai accesso a questa pagina"
  end
end
```

### 8. Admin Shares Controller

```ruby
# app/controllers/admin/shares_controller.rb
module Admin
  class SharesController < BaseController
    def index
      @shares = Share.includes(:shareable, :recipient).order(created_at: :desc)
    end

    def new
      @share = Share.new
    end

    def create
      @share = Share.new(share_params)
      @share.granted_by = Current.user

      if @share.save
        redirect_to admin_shares_path, notice: "Accesso assegnato"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      @share = Share.find(params[:id])
      @share.destroy
      redirect_to admin_shares_path, notice: "Accesso revocato"
    end

    private

    def share_params
      params.require(:share).permit(
        :shareable_type, :shareable_id,
        :recipient_type, :recipient_id,
        :permission, :expires_at
      )
    end
  end
end
```

### 9. Routes

```ruby
# config/routes.rb (aggiungere)
namespace :admin do
  resources :shares, only: [:index, :new, :create, :destroy]
end
```

## File da Modificare

| File | Azione |
|------|--------|
| `config/credentials.yml.enc` | Aggiungere `admin_emails` |
| `app/models/concerns/shareable.rb` | Creare |
| `app/models/user/admin.rb` | Creare |
| `app/models/user.rb` | Aggiungere `include Admin` |
| `app/models/corso.rb` | Aggiungere `include Shareable` + scope + metodo |
| `app/models/volume.rb` | Aggiungere `include Shareable` + scope + metodo |
| `app/models/disciplina.rb` | Aggiungere `include Shareable` + scope + metodo |
| `app/models/pagina.rb` | Aggiungere `include Shareable` + scope + metodo |
| `app/controllers/pagine_controller.rb` | Aggiungere autorizzazione |
| `app/controllers/admin/base_controller.rb` | Creare |
| `app/controllers/admin/shares_controller.rb` | Creare |
| `config/routes.rb` | Aggiungere namespace admin |
| `app/views/admin/shares/*` | Creare viste |

## Test

- `test/models/concerns/shareable_test.rb`
- `test/models/pagina_access_test.rb`
- `test/models/user/admin_test.rb`
- `test/controllers/admin/shares_controller_test.rb`
