# Design: Sistema Esercizi con Questions e Condivisione

**Data:** 2025-12-27
**Stato:** Approvato
**Scope:** Refactoring completo sistema esercizi

## Obiettivo

Refactoring del sistema esercizi per:
- Eliminare il vecchio sistema JSON `content["operations"]`
- Usare solo `Question` con DelegatedType
- Aggiungere sistema di pubblicazione a livelli (Publishable)
- Aggiungere condivisione flessibile con destinatari multipli (Share)
- UI nuova con Turbo/Stimulus

## Architettura Concerns

```
┌─────────────────────────────────────────────────────────────┐
│                      CONCERNS                                │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Publishable              Shareable (esistente)             │
│  ├─ status enum           ├─ share_token                    │
│  │  (draft/private/       ├─ shareable_url                  │
│  │   shared/published)    └─ find_by_share_token            │
│  ├─ published_at                                            │
│  ├─ publish!/unpublish!   Questionable (esistente)          │
│  └─ scopes                ├─ has_one :question              │
│                           └─ to_renderer                    │
└─────────────────────────────────────────────────────────────┘
```

**Publishable** gestisce 4 stati:
- `draft` - Solo il creatore lo vede
- `private` - Salvato ma non condiviso
- `shared` - Visibile a destinatari specifici (via Share)
- `published` - Pubblico, accessibile via share_token

## Database e Models

```
┌─────────────────────────────────────────────────────────────┐
│ ESERCIZIO                                                    │
│ include Publishable, Shareable                              │
├─────────────────────────────────────────────────────────────┤
│ title, slug, description, category, difficulty              │
│ status (enum), published_at, share_token                    │
│ account_id, creator_id                                      │
│ has_many :questions                                         │
│ has_many :shares, as: :shareable                           │
└─────────────────────────────────────────────────────────────┘
          │
          │ has_many :questions
          ▼
┌─────────────────────────────────────────────────────────────┐
│ QUESTION                                                     │
│ include Publishable (opzionale per riuso)                   │
├─────────────────────────────────────────────────────────────┤
│ esercizio_id, position, points, difficulty                  │
│ questionable_type, questionable_id (delegated_type)         │
│ status, account_id, creator_id                              │
│                                                              │
│ delegated_type :questionable,                               │
│   types: [Addizione, Sottrazione, Moltiplicazione,          │
│           Divisione, Abaco]                                  │
└─────────────────────────────────────────────────────────────┘
          │
          │ delegated_type :questionable
          ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│ Addizione    │ │ Sottrazione  │ │ Moltiplic... │ ...
│ data (json)  │ │ data (json)  │ │ data (json)  │
│ to_renderer  │ │ to_renderer  │ │ to_renderer  │
└──────────────┘ └──────────────┘ └──────────────┘
```

### Tabella shares (nuova)

```
┌─────────────────────────────────────────────────────────────┐
│ SHARE                                                        │
├─────────────────────────────────────────────────────────────┤
│ shareable_type, shareable_id  → cosa condivido              │
│   (Esercizio, Question)                                      │
│                                                              │
│ recipient_type, recipient_id  → con chi (delegated_type)    │
│   (Account, User, + futuri: Classe, Gruppo)                 │
│                                                              │
│ permission (enum: view/edit/admin)                          │
│ granted_by_id, expires_at                                   │
└─────────────────────────────────────────────────────────────┘
```

### Migration: create_shares

```ruby
create_table :shares do |t|
  # Cosa viene condiviso (polimorfico)
  t.references :shareable, polymorphic: true, null: false

  # Con chi (delegated_type)
  t.string :recipient_type, null: false
  t.bigint :recipient_id, null: false

  # Permessi e metadata
  t.integer :permission, default: 0  # enum: view/edit/admin
  t.references :granted_by, foreign_key: { to_table: :users }
  t.datetime :expires_at

  t.timestamps
end

add_index :shares, [:recipient_type, :recipient_id]
add_index :shares, [:shareable_type, :shareable_id, :recipient_type, :recipient_id],
          unique: true, name: 'index_shares_unique'
```

### Migration: add_status_to_esercizi

```ruby
add_column :esercizi, :status, :integer, default: 0, null: false
add_index :esercizi, :status
```

## Models

### app/models/concerns/publishable.rb

```ruby
module Publishable
  extend ActiveSupport::Concern

  included do
    enum :status, { draft: 0, private: 1, shared: 2, published: 3 }, default: :draft

    scope :visible_to, ->(user) {
      where(status: :published)
        .or(where(creator_id: user.id))
        .or(where(id: Share.where(recipient: user).select(:shareable_id)))
        .or(where(id: Share.where(recipient: user.account).select(:shareable_id)))
    }
  end

  def publish!
    update!(status: :published, published_at: Time.current)
  end

  def unpublish!
    update!(status: :draft, published_at: nil)
  end

  def visible_to?(user)
    return true if published?
    return true if creator_id == user.id
    return true if shares.exists?(recipient: user)
    return true if shares.exists?(recipient: user.account)
    false
  end
end
```

### app/models/share.rb

```ruby
class Share < ApplicationRecord
  belongs_to :shareable, polymorphic: true
  belongs_to :granted_by, class_name: "User", optional: true

  delegated_type :recipient, types: %w[Account User]

  enum :permission, { view: 0, edit: 1, admin: 2 }, default: :view

  validates :recipient_type, :recipient_id, presence: true
  validates :shareable_id, uniqueness: {
    scope: [:shareable_type, :recipient_type, :recipient_id],
    message: "già condiviso con questo destinatario"
  }

  scope :active, -> { where("expires_at IS NULL OR expires_at > ?", Time.current) }
  scope :expired, -> { where("expires_at <= ?", Time.current) }
end
```

### app/models/esercizio.rb (modificato)

```ruby
class Esercizio < ApplicationRecord
  include Publishable
  include Shareable
  include Searchable

  serialize :tags, coder: JSON, type: Array

  belongs_to :account, optional: true
  belongs_to :creator, class_name: "User", optional: true

  has_many :questions, -> { ordered }, dependent: :destroy
  has_many :shares, as: :shareable, dependent: :destroy
  has_many :esercizio_attempts, dependent: :destroy

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug, on: :create

  # RIMOSSO: serialize :content, metodi operations, add_operation, etc.
end
```

## Routes

```ruby
namespace :dashboard do
  resources :esercizi do
    member do
      post :publish
      post :unpublish
      post :duplicate
    end
    resources :questions, only: [:create, :update, :destroy] do
      post :reorder, on: :collection
    end
    resources :shares, only: [:index, :create, :destroy]
  end
end

# Pubblico (esistente)
get "e/:share_token", to: "public_esercizi#show", as: :public_esercizio
```

## Controllers

### app/controllers/dashboard/questions_controller.rb

```ruby
class Dashboard::QuestionsController < ApplicationController
  require_teacher
  before_action :set_esercizio
  before_action :set_question, only: [:update, :destroy]

  def create
    @question = @esercizio.questions.build(question_params)
    @question.questionable = build_questionable
    @question.creator = Current.user
    @question.account = Current.account

    if @question.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to edit_dashboard_esercizio_path(@esercizio) }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @question.update(question_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to edit_dashboard_esercizio_path(@esercizio) }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @question.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@question) }
      format.html { redirect_to edit_dashboard_esercizio_path(@esercizio) }
    end
  end

  def reorder
    params[:question_ids].each_with_index do |id, index|
      @esercizio.questions.find(id).update_column(:position, index)
    end
    head :ok
  end

  private

  def set_esercizio
    @esercizio = Esercizio.find(params[:esercizio_id])
  end

  def set_question
    @question = @esercizio.questions.find(params[:id])
  end

  def question_params
    params.require(:question).permit(:position, :points, :difficulty)
  end

  def build_questionable
    type = params[:question][:questionable_type]
    data = params[:question][:data]&.to_unsafe_h || {}
    type.constantize.create!(data: data)
  end
end
```

### app/controllers/dashboard/shares_controller.rb

```ruby
class Dashboard::SharesController < ApplicationController
  require_teacher
  before_action :set_esercizio

  def index
    @shares = @esercizio.shares.includes(:recipient)
  end

  def create
    @share = @esercizio.shares.build(share_params)
    @share.granted_by = Current.user

    if @share.save
      @esercizio.update(status: :shared) if @esercizio.draft? || @esercizio.private?
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to edit_dashboard_esercizio_path(@esercizio) }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @share = @esercizio.shares.find(params[:id])
    @share.destroy

    # Torna a private se non ci sono più share
    @esercizio.update(status: :private) if @esercizio.shared? && @esercizio.shares.empty?

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@share) }
      format.html { redirect_to edit_dashboard_esercizio_path(@esercizio) }
    end
  end

  private

  def set_esercizio
    @esercizio = Esercizio.find(params[:esercizio_id])
  end

  def share_params
    params.require(:share).permit(:recipient_type, :recipient_id, :permission, :expires_at)
  end
end
```

## UI

```
┌─────────────────────────────────────────────────────────────┐
│ EDIT ESERCIZIO                                               │
├─────────────────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Titolo: [Campo input________________]                   │ │
│ │ Descrizione: [Textarea______________]                   │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                              │
│ ┌─ QUESTIONS ─────────────────────────────────────────────┐ │
│ │                                                          │ │
│ │  ☰ 1. Addizione: 234 + 567           [modifica][elimina]│ │
│ │  ☰ 2. Sottrazione: 500 - 123         [modifica][elimina]│ │
│ │  ☰ 3. Moltiplicazione: 12 × 5        [modifica][elimina]│ │
│ │                                                          │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                              │
│ ┌─ AGGIUNGI QUESTION ─────────────────────────────────────┐ │
│ │  [+ Addizione] [+ Sottrazione] [+ Moltiplic.] [+ ...]   │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                              │
│ ┌─ STATO ─────────────────────────────────────────────────┐ │
│ │  ○ Bozza  ○ Privato  ○ Condiviso  ● Pubblico            │ │
│ │                                                          │ │
│ │  Link pubblico: https://app.com/e/abc123  [copia]       │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                              │
│                              [Salva] [Anteprima] [Elimina]  │
└─────────────────────────────────────────────────────────────┘
```

## Stimulus Controllers

### questions_controller.js
- `add(type)` → POST /questions → Turbo Stream append
- `remove(id)` → DELETE /questions/:id → Turbo Stream remove
- `reorder()` → POST /questions/reorder → aggiorna posizioni
- `edit(id)` → mostra form inline

### sortable_controller.js
- Usa Sortable.js
- Chiama questions#reorder on drop

### share_controller.js
- `copy()` → copia link negli appunti
- `toggle(status)` → PATCH esercizio con nuovo status

## Piano di Implementazione

### File da creare

1. `db/migrate/XXXX_create_shares.rb`
2. `db/migrate/XXXX_add_status_to_esercizi.rb`
3. `app/models/concerns/publishable.rb`
4. `app/models/share.rb`
5. `app/controllers/dashboard/questions_controller.rb`
6. `app/controllers/dashboard/shares_controller.rb`
7. `app/views/dashboard/esercizi/edit.html.erb` (nuova UI)
8. `app/views/dashboard/questions/_question.html.erb`
9. `app/views/dashboard/questions/create.turbo_stream.erb`
10. `app/views/dashboard/questions/update.turbo_stream.erb`
11. `app/javascript/controllers/questions_controller.js`
12. `app/javascript/controllers/sortable_controller.js`

### File da modificare

1. `app/models/esercizio.rb` - rimuovere content/operations, aggiungere Publishable
2. `app/models/question.rb` - aggiungere Publishable (opzionale)
3. `app/controllers/dashboard/esercizi_controller.rb` - semplificare
4. `app/controllers/public_esercizi_controller.rb` - usare questions
5. `config/routes.rb` - aggiungere nested resources

### File da eliminare/pulire

1. Metodi `add_operation`, `remove_operation`, `reorder_operations` da Esercizio
2. Metodi `operations`, `content["operations"]` da controller
3. Partials vecchi per operations

### Ordine operazioni

1. Concern Publishable
2. Migration + Model Share
3. Migration status su Esercizio
4. Modifica Esercizio (status, rimuovi content)
5. Controller Questions (CRUD)
6. Controller Shares (CRUD)
7. Semplifica EserciziController
8. Nuova UI edit con Turbo/Stimulus
9. Aggiorna PublicEserciziController
10. Test e cleanup
