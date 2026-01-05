# Permissions Refactor Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implementare il filtraggio dei contenuti didattici basato su permessi, con supporto per pagine pubbliche.

**Architecture:** I modelli già hanno `accessible_by` e `accessible_by?`. Mancano: (1) enforcement nei controller, (2) campo `public` su Pagina, (3) filtraggio nella homepage, (4) sub-condivisione per owner.

**Tech Stack:** Rails 8.1, Ruby 3.2, SQLite, Tailwind CSS 4

---

## Task 1: Migration per campo public su Pagina

**Files:**
- Create: `db/migrate/XXXXXX_add_public_to_pagine.rb`

**Step 1: Genera la migration**

```bash
bin/rails generate migration AddPublicToPagine public:boolean
```

**Step 2: Modifica la migration per default e null**

```ruby
# db/migrate/XXXXXX_add_public_to_pagine.rb
class AddPublicToPagine < ActiveRecord::Migration[8.0]
  def change
    add_column :pagine, :public, :boolean, default: false, null: false
    add_index :pagine, :public
  end
end
```

**Step 3: Esegui la migration**

```bash
bin/rails db:migrate
```

**Step 4: Verifica**

```bash
bin/rails runner "puts Pagina.column_names.include?('public')"
```
Expected: `true`

**Step 5: Commit**

```bash
git add db/
git commit -m "feat: add public field to pagine table"
```

---

## Task 2: Aggiorna modello Pagina con scope pubbliche

**Files:**
- Modify: `app/models/pagina.rb`

**Step 1: Aggiungi scope :pubbliche e aggiorna accessible_by**

In `app/models/pagina.rb`, aggiungi dopo `default_scope`:

```ruby
scope :pubbliche, -> { where(public: true) }
```

**Step 2: Modifica lo scope accessible_by per includere pagine pubbliche**

Sostituisci l'intero scope `accessible_by` con:

```ruby
scope :accessible_by, ->(user) {
  public_pages = where(public: true)

  return all if user&.admin?
  return public_pages if user.nil?

  user_recipients = [ user, user.account ]

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
```

**Step 3: Modifica accessible_by? per check public**

Sostituisci il metodo `accessible_by?` con:

```ruby
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
```

**Step 4: Verifica sintassi**

```bash
ruby -c app/models/pagina.rb
```
Expected: `Syntax OK`

**Step 5: Commit**

```bash
git add app/models/pagina.rb
git commit -m "feat: add pubbliche scope and public page support to Pagina"
```

---

## Task 3: Aggiungi scope with_public_pages a Corso

**Files:**
- Modify: `app/models/corso.rb`

**Step 1: Aggiungi lo scope**

Dopo lo scope `accessible_by`, aggiungi:

```ruby
scope :with_public_pages, -> {
  joins(volumi: { discipline: :pagine })
    .where(pagine: { public: true })
    .distinct
}
```

**Step 2: Verifica sintassi**

```bash
ruby -c app/models/corso.rb
```
Expected: `Syntax OK`

**Step 3: Commit**

```bash
git add app/models/corso.rb
git commit -m "feat: add with_public_pages scope to Corso"
```

---

## Task 4: Crea concern ResourceAuthorization

**Files:**
- Create: `app/controllers/concerns/resource_authorization.rb`

**Step 1: Crea il file**

```ruby
# frozen_string_literal: true

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

**Step 2: Verifica sintassi**

```bash
ruby -c app/controllers/concerns/resource_authorization.rb
```
Expected: `Syntax OK`

**Step 3: Commit**

```bash
git add app/controllers/concerns/resource_authorization.rb
git commit -m "feat: add ResourceAuthorization concern"
```

---

## Task 5: Crea modello Guest

**Files:**
- Create: `app/models/guest.rb`

**Step 1: Crea il file**

```ruby
# frozen_string_literal: true

class Guest
  def admin?
    false
  end

  def account
    nil
  end

  def id
    nil
  end
end
```

**Step 2: Verifica sintassi**

```bash
ruby -c app/models/guest.rb
```
Expected: `Syntax OK`

**Step 3: Commit**

```bash
git add app/models/guest.rb
git commit -m "feat: add Guest model for unauthenticated users"
```

---

## Task 6: Aggiorna CorsiController con filtraggio

**Files:**
- Modify: `app/controllers/corsi_controller.rb`

**Step 1: Leggi il file corrente e modifica**

Sostituisci l'intero file con:

```ruby
class CorsiController < ApplicationController
  include ResourceAuthorization
  allow_any_account_scope

  def index
    @corsi = if admin?
      Corso.all.includes(:volumi)
    elsif Current.user
      Corso.accessible_by(Current.user).includes(:volumi)
    else
      Corso.with_public_pages.includes(:volumi)
    end
  end

  def show
    @corso = Corso.find(params[:id])
    authorize_resource!(@corso)
    @volumi = if admin?
      @corso.volumi.includes(:discipline)
    else
      @corso.volumi.accessible_by(current_user_or_guest).includes(:discipline)
    end
  end
end
```

**Step 2: Verifica sintassi**

```bash
ruby -c app/controllers/corsi_controller.rb
```
Expected: `Syntax OK`

**Step 3: Commit**

```bash
git add app/controllers/corsi_controller.rb
git commit -m "feat: add permission filtering to CorsiController"
```

---

## Task 7: Aggiorna VolumiController con filtraggio

**Files:**
- Modify: `app/controllers/volumi_controller.rb`

**Step 1: Sostituisci l'intero file**

```ruby
class VolumiController < ApplicationController
  include ResourceAuthorization
  allow_any_account_scope

  def index
    @volumi = if admin?
      Volume.all.includes(:corso, discipline: :pagine)
    elsif Current.user
      Volume.accessible_by(Current.user).includes(:corso, discipline: :pagine)
    else
      Volume.with_public_pages.includes(:corso, discipline: :pagine)
    end
  end

  def show
    @volume = Volume.find(params[:id])
    authorize_resource!(@volume)
    @discipline = if admin?
      @volume.discipline.includes(:pagine)
    else
      @volume.discipline.accessible_by(current_user_or_guest).includes(:pagine)
    end
  end
end
```

**Step 2: Verifica sintassi**

```bash
ruby -c app/controllers/volumi_controller.rb
```
Expected: `Syntax OK`

**Step 3: Commit**

```bash
git add app/controllers/volumi_controller.rb
git commit -m "feat: add permission filtering to VolumiController"
```

---

## Task 8: Aggiungi scope with_public_pages a Volume

**Files:**
- Modify: `app/models/volume.rb`

**Step 1: Aggiungi lo scope dopo accessible_by**

```ruby
scope :with_public_pages, -> {
  joins(discipline: :pagine)
    .where(pagine: { public: true })
    .distinct
}
```

**Step 2: Verifica sintassi**

```bash
ruby -c app/models/volume.rb
```
Expected: `Syntax OK`

**Step 3: Commit**

```bash
git add app/models/volume.rb
git commit -m "feat: add with_public_pages scope to Volume"
```

---

## Task 9: Aggiorna DisciplineController con filtraggio

**Files:**
- Modify: `app/controllers/discipline_controller.rb`

**Step 1: Sostituisci l'intero file**

```ruby
class DisciplineController < ApplicationController
  include ResourceAuthorization
  allow_any_account_scope

  def show
    @disciplina = Disciplina.find(params[:id])
    authorize_resource!(@disciplina)
    @pagine = if admin?
      @disciplina.pagine
    else
      @disciplina.pagine.accessible_by(current_user_or_guest)
    end
  end
end
```

**Step 2: Verifica sintassi**

```bash
ruby -c app/controllers/discipline_controller.rb
```
Expected: `Syntax OK`

**Step 3: Commit**

```bash
git add app/controllers/discipline_controller.rb
git commit -m "feat: add permission filtering to DisciplineController"
```

---

## Task 10: Aggiorna PagineController per check public

**Files:**
- Modify: `app/controllers/pagine_controller.rb`

**Step 1: Modifica il metodo pagina_accessible?**

Trova il metodo `pagina_accessible?` e sostituiscilo con:

```ruby
def pagina_accessible?
  return true if @pagina.public?
  return true if admin_identity?

  Current.user && @pagina.accessible_by?(Current.user)
end
```

**Step 2: Verifica sintassi**

```bash
ruby -c app/controllers/pagine_controller.rb
```
Expected: `Syntax OK`

**Step 3: Commit**

```bash
git add app/controllers/pagine_controller.rb
git commit -m "feat: add public page check to PagineController"
```

---

## Task 11: Aggiungi scope with_public_pages a Disciplina

**Files:**
- Modify: `app/models/disciplina.rb`

**Step 1: Aggiungi lo scope dopo accessible_by**

```ruby
scope :with_public_pages, -> {
  joins(:pagine)
    .where(pagine: { public: true })
    .distinct
}
```

**Step 2: Verifica sintassi**

```bash
ruby -c app/models/disciplina.rb
```
Expected: `Syntax OK`

**Step 3: Commit**

```bash
git add app/models/disciplina.rb
git commit -m "feat: add with_public_pages scope to Disciplina"
```

---

## Task 12: Crea Account::SharesController per sub-condivisione

**Files:**
- Create: `app/controllers/account/shares_controller.rb`

**Step 1: Crea il file**

```ruby
# frozen_string_literal: true

module Account
  class SharesController < ApplicationController
    before_action :require_owner

    def index
      @shares = Share.where(granted_by: Current.user)
                     .where(recipient_type: "User")
                     .where(recipient_id: Current.account.users.select(:id))
                     .includes(:shareable, :recipient)
                     .order(created_at: :desc)
    end

    def new
      @share = Share.new
      @available_resources = available_resources
      @users = Current.account.users.active.where.not(id: Current.user.id)
    end

    def create
      @share = Share.new(share_params)
      @share.granted_by = Current.user
      @share.permission = :view

      unless resource_accessible_to_account?(@share.shareable)
        return redirect_to account_shares_path, alert: "Non puoi condividere questa risorsa"
      end

      unless valid_recipient?(@share.recipient)
        return redirect_to account_shares_path, alert: "Destinatario non valido"
      end

      if @share.save
        redirect_to account_shares_path, notice: "Accesso assegnato"
      else
        @available_resources = available_resources
        @users = Current.account.users.active.where.not(id: Current.user.id)
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      @share = Share.find(params[:id])

      unless @share.granted_by == Current.user
        return redirect_to account_shares_path, alert: "Non puoi rimuovere questa condivisione"
      end

      @share.destroy
      redirect_to account_shares_path, notice: "Accesso revocato"
    end

    private

    def require_owner
      redirect_to root_path, alert: "Accesso riservato" unless Current.user&.owner?
    end

    def share_params
      params.require(:share).permit(
        :shareable_type, :shareable_id,
        :recipient_id
      ).merge(recipient_type: "User")
    end

    def available_resources
      {
        corsi: Corso.accessible_by(Current.user),
        volumi: Volume.accessible_by(Current.user),
        discipline: Disciplina.accessible_by(Current.user),
        pagine: Pagina.accessible_by(Current.user)
      }
    end

    def resource_accessible_to_account?(resource)
      return false unless resource

      resource.accessible_by?(Current.user)
    end

    def valid_recipient?(recipient)
      return false unless recipient.is_a?(User)

      recipient.account == Current.account && recipient != Current.user
    end
  end
end
```

**Step 2: Verifica sintassi**

```bash
ruby -c app/controllers/account/shares_controller.rb
```
Expected: `Syntax OK`

**Step 3: Commit**

```bash
git add app/controllers/account/shares_controller.rb
git commit -m "feat: add Account::SharesController for sub-sharing"
```

---

## Task 13: Aggiungi routes per account/shares

**Files:**
- Modify: `config/routes.rb`

**Step 1: Aggiungi la route nel namespace account esistente**

Trova il primo blocco `namespace :account` e aggiungi `resources :shares`:

```ruby
namespace :account do
  resource :join_code
  resource :settings
  resources :shares, only: [ :index, :new, :create, :destroy ]
end
```

**Step 2: Verifica routes**

```bash
bin/rails routes | grep account/shares
```
Expected: Dovrebbe mostrare le routes index, new, create, destroy

**Step 3: Commit**

```bash
git add config/routes.rb
git commit -m "feat: add routes for account shares"
```

---

## Task 14: Crea viste Account::Shares

**Files:**
- Create: `app/views/account/shares/index.html.erb`
- Create: `app/views/account/shares/new.html.erb`

**Step 1: Crea directory**

```bash
mkdir -p app/views/account/shares
```

**Step 2: Crea index.html.erb**

```erb
<% content_for :titolo, "Gestisci Accessi" %>

<div class="max-w-4xl mx-auto px-4 py-8">
  <div class="flex items-center justify-between mb-6">
    <h1 class="text-2xl font-bold text-gray-800 dark:text-white">Gestisci Accessi</h1>
    <%= link_to "Nuovo accesso", new_account_share_path,
        class: "inline-flex items-center px-4 py-2 bg-orange-500 hover:bg-orange-600 text-white font-semibold rounded-lg transition" %>
  </div>

  <% if @shares.any? %>
    <div class="bg-white dark:bg-gray-800 rounded-xl border border-gray-200 dark:border-gray-700 overflow-hidden">
      <table class="w-full">
        <thead class="bg-gray-50 dark:bg-gray-700">
          <tr>
            <th class="px-4 py-3 text-left text-sm font-semibold text-gray-600 dark:text-gray-300">Risorsa</th>
            <th class="px-4 py-3 text-left text-sm font-semibold text-gray-600 dark:text-gray-300">Utente</th>
            <th class="px-4 py-3 text-left text-sm font-semibold text-gray-600 dark:text-gray-300">Data</th>
            <th class="px-4 py-3 text-right text-sm font-semibold text-gray-600 dark:text-gray-300">Azioni</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
          <% @shares.each do |share| %>
            <tr>
              <td class="px-4 py-3 text-gray-800 dark:text-gray-200">
                <span class="text-xs text-gray-500 dark:text-gray-400"><%= share.shareable_type %></span><br>
                <%= share.shareable&.respond_to?(:nome) ? share.shareable.nome : share.shareable&.titolo %>
              </td>
              <td class="px-4 py-3 text-gray-800 dark:text-gray-200">
                <%= share.recipient&.name %>
              </td>
              <td class="px-4 py-3 text-gray-500 dark:text-gray-400 text-sm">
                <%= l share.created_at, format: :short %>
              </td>
              <td class="px-4 py-3 text-right">
                <%= button_to "Revoca", account_share_path(share),
                    method: :delete,
                    class: "text-red-600 hover:text-red-800 dark:text-red-400 dark:hover:text-red-300 text-sm font-medium",
                    data: { turbo_confirm: "Sei sicuro di voler revocare questo accesso?" } %>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
  <% else %>
    <div class="text-center py-12 bg-gray-50 dark:bg-gray-800 rounded-xl">
      <p class="text-gray-500 dark:text-gray-400">Nessun accesso condiviso con gli utenti del tuo account.</p>
    </div>
  <% end %>
</div>
```

**Step 3: Crea new.html.erb**

```erb
<% content_for :titolo, "Nuovo Accesso" %>

<div class="max-w-2xl mx-auto px-4 py-8">
  <h1 class="text-2xl font-bold text-gray-800 dark:text-white mb-6">Assegna Accesso</h1>

  <%= form_with model: @share, url: account_shares_path, class: "space-y-6" do |f| %>
    <% if @share.errors.any? %>
      <div class="bg-red-50 dark:bg-red-900/30 border border-red-200 dark:border-red-800 rounded-lg p-4">
        <ul class="list-disc list-inside text-red-600 dark:text-red-400 text-sm">
          <% @share.errors.full_messages.each do |message| %>
            <li><%= message %></li>
          <% end %>
        </ul>
      </div>
    <% end %>

    <div>
      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Tipo Risorsa</label>
      <%= f.select :shareable_type,
          [["Corso", "Corso"], ["Volume", "Volume"], ["Disciplina", "Disciplina"], ["Pagina", "Pagina"]],
          { prompt: "Seleziona tipo..." },
          class: "w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white",
          data: { controller: "resource-select", action: "change->resource-select#typeChanged" } %>
    </div>

    <div>
      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Risorsa</label>
      <%= f.select :shareable_id,
          options_for_select([]),
          { prompt: "Prima seleziona il tipo..." },
          class: "w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white",
          data: { resource_select_target: "resourceSelect" } %>

      <!-- Hidden data for JS -->
      <script type="application/json" data-resource-select-target="corsi">
        <%= raw @available_resources[:corsi].map { |c| { id: c.id, name: c.nome } }.to_json %>
      </script>
      <script type="application/json" data-resource-select-target="volumi">
        <%= raw @available_resources[:volumi].map { |v| { id: v.id, name: "#{v.corso.nome} - #{v.nome}" } }.to_json %>
      </script>
      <script type="application/json" data-resource-select-target="discipline">
        <%= raw @available_resources[:discipline].map { |d| { id: d.id, name: "#{d.volume.nome} - #{d.nome}" } }.to_json %>
      </script>
      <script type="application/json" data-resource-select-target="pagine">
        <%= raw @available_resources[:pagine].map { |p| { id: p.id, name: "#{p.disciplina.nome} - p.#{p.numero}" } }.to_json %>
      </script>
    </div>

    <div>
      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Utente</label>
      <%= f.select :recipient_id,
          @users.map { |u| [u.name, u.id] },
          { prompt: "Seleziona utente..." },
          class: "w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white" %>
    </div>

    <div class="flex gap-4">
      <%= f.submit "Assegna Accesso",
          class: "px-6 py-2 bg-orange-500 hover:bg-orange-600 text-white font-semibold rounded-lg transition cursor-pointer" %>
      <%= link_to "Annulla", account_shares_path,
          class: "px-6 py-2 bg-gray-200 hover:bg-gray-300 dark:bg-gray-700 dark:hover:bg-gray-600 text-gray-700 dark:text-gray-200 font-semibold rounded-lg transition" %>
    </div>
  <% end %>
</div>
```

**Step 4: Commit**

```bash
git add app/views/account/shares/
git commit -m "feat: add views for account shares management"
```

---

## Task 15: Crea Stimulus controller per select dinamico

**Files:**
- Create: `app/javascript/controllers/resource_select_controller.js`

**Step 1: Crea il file**

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["resourceSelect", "corsi", "volumi", "discipline", "pagine"]

  typeChanged(event) {
    const type = event.target.value.toLowerCase()
    const select = this.resourceSelectTarget

    select.innerHTML = '<option value="">Seleziona...</option>'

    if (!type) return

    const dataTarget = this[`${type}Target`]
    if (!dataTarget) return

    const items = JSON.parse(dataTarget.textContent)
    items.forEach(item => {
      const option = document.createElement('option')
      option.value = item.id
      option.textContent = item.name
      select.appendChild(option)
    })
  }
}
```

**Step 2: Commit**

```bash
git add app/javascript/controllers/resource_select_controller.js
git commit -m "feat: add Stimulus controller for dynamic resource select"
```

---

## Task 16: Aggiorna viste admin/shares per bottone Condividi

**Files:**
- Modify: `app/views/admin/shares/new.html.erb`

**Step 1: Leggi il file corrente**

```bash
cat app/views/admin/shares/new.html.erb
```

**Step 2: Assicurati che supporti i parametri precompilati**

Se la form non supporta già i parametri `shareable_type` e `shareable_id` precompilati, aggiorna il form per usarli.

**Step 3: Commit se modificato**

```bash
git add app/views/admin/shares/new.html.erb
git commit -m "fix: support preselected resource in admin shares form"
```

---

## Task 17: Aggiungi bottone Condividi nelle viste show (solo admin)

**Files:**
- Modify: `app/views/corsi/show.html.erb`
- Modify: `app/views/volumi/show.html.erb`
- Modify: `app/views/discipline/show.html.erb`

**Step 1: Leggi ogni file e aggiungi il bottone Condividi**

Aggiungi questo snippet dove appropriato (nella sezione header/actions) di ogni vista:

```erb
<% if admin? %>
  <%= link_to new_admin_share_path(shareable_type: "Corso", shareable_id: @corso.id),
      class: "inline-flex items-center gap-2 px-3 py-1.5 text-sm font-medium text-gray-600 dark:text-gray-300 bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600 rounded-lg transition" do %>
    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.368 2.684 3 3 0 00-5.368-2.684z"/>
    </svg>
    Condividi
  <% end %>
<% end %>
```

(Modifica `shareable_type` e l'oggetto per ogni vista)

**Step 2: Aggiungi helper admin? in ApplicationController**

Se non esiste, aggiungi in `app/controllers/application_controller.rb`:

```ruby
helper_method :admin?

def admin?
  return false unless Current.identity
  admin_emails = Rails.application.credentials.admin_emails || []
  admin_emails.include?(Current.identity.email_address)
end
```

**Step 3: Commit**

```bash
git add app/views/corsi/show.html.erb app/views/volumi/show.html.erb app/views/discipline/show.html.erb app/controllers/application_controller.rb
git commit -m "feat: add share button in resource show views for admin"
```

---

## Task 18: Aggiungi link Gestisci Accessi nel menu account

**Files:**
- Modify: `app/views/shared/nav_menu/_jump.html.erb` (o file menu appropriato)

**Step 1: Trova il file del menu account**

**Step 2: Aggiungi link per owner**

```erb
<% if Current.user&.owner? %>
  <%= link_to account_shares_path, class: "..." do %>
    Gestisci Accessi
  <% end %>
<% end %>
```

**Step 3: Commit**

```bash
git add app/views/shared/nav_menu/
git commit -m "feat: add manage shares link in account menu for owner"
```

---

## Task 19: Test manuale e verifica

**Step 1: Avvia il server**

```bash
bin/rails server
```

**Step 2: Testa come admin**

- Vai su `/corsi` - dovresti vedere tutti i corsi
- Vai su `/admin/shares` - crea una condivisione
- Verifica che il bottone "Condividi" appaia sulle viste show

**Step 3: Testa come utente normale (non admin)**

- Crea un utente di test senza share
- Vai su `/corsi` - dovresti vedere lista vuota
- Crea una share per quell'utente su un corso
- Vai su `/corsi` - dovresti vedere solo quel corso

**Step 4: Testa pagine pubbliche**

- Come admin, marca una pagina come pubblica (via console: `Pagina.first.update(public: true)`)
- Logout
- Vai sulla pagina pubblica - dovresti poterla vedere

**Step 5: Commit finale**

```bash
git add -A
git commit -m "feat: complete permissions refactor implementation"
```

---

## Summary

- **Tasks 1-5**: Setup (migration, modelli, concern, Guest)
- **Tasks 6-11**: Controller con filtraggio
- **Tasks 12-15**: Sub-condivisione owner
- **Tasks 16-18**: UI (bottoni condividi, menu)
- **Task 19**: Verifica

Ogni task è indipendente e committabile separatamente.
