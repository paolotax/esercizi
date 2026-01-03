Rails.application.routes.draw do
  root "volumi#index"

  namespace :account do
    resource :join_code
    resource :settings
  end

  # Account management (owner only)
  namespace :account do
    resource :settings, only: [ :show, :update ]
    resources :users, only: [ :index, :show, :edit, :update, :destroy ]
    resources :join_codes, only: [ :index, :show, :update ]
  end


  resource :session, only: [ :new, :create, :destroy ] do
    scope module: :sessions do
      resource :magic_link, only: [ :show, :create ]
      resource :menu, only: :show
    end
  end

  resource :signup, only: [ :new, :create ]

  get "join/:code", to: "join_codes#new", as: :join
  post "join/:code", to: "join_codes#create"

  # ============================================
  # Public routes (no auth required)
  # ============================================

  # Area pubblica per esercizi condivisi
  get "e/:share_token", to: "public_esercizi#show", as: :public_esercizio
  post "e/:share_token/attempt", to: "public_esercizi#attempt", as: :public_esercizio_attempt
  get "e/:share_token/results/:attempt_id", to: "public_esercizi#results", as: :public_esercizio_results

  # Strumenti (public tools) - RESTful resources
  namespace :strumenti do
    resource :addizioni, only: [ :show, :create ], controller: "addizioni" do
      get :preview, on: :collection
    end
    resource :sottrazioni, only: [ :show, :create ], controller: "sottrazioni" do
      get :preview, on: :collection
    end
    resource :moltiplicazioni, only: [ :show, :create ], controller: "moltiplicazioni" do
      get :preview, on: :collection
    end
    resource :divisioni, only: [ :show, :create ], controller: "divisioni" do
      get :preview, on: :collection
    end
    resource :abaco, only: [ :show, :create ], controller: "abaco" do
      get :preview, on: :collection
      get :examples, on: :collection
    end
    get "le_rime", to: "le_rime#show", as: "le_rime"
  end

  # API endpoint for quaderno grid (single operation for sidebar)
  get "exercises/quaderno_grid", to: "exercises#quaderno_grid", as: "quaderno_grid"
  # Unified API endpoint for operation grids (supports all types and layouts)
  get "exercises/operation_grid", to: "exercises#operation_grid", as: "operation_grid"

  # ============================================
  # Authenticated routes (within account scope)
  # ============================================

  # Navigation routes for books hierarchy
  resources :corsi, only: [ :index, :show ]
  resources :volumi, only: [ :index, :show ]
  resources :discipline, only: [ :show ]

  # Dynamic page routing by slug
  get "pagine/:slug", to: "pagine#show", as: "pagina"

  # Ricerca
  resource :search, only: :show

  # Dashboard per costruzione esercizi (teacher only)
  namespace :dashboard do
    resources :esercizi do
      # Risorse RESTful (pattern Fizzy)
      resource :publish, only: [ :create, :destroy ], controller: "esercizi/publishes"
      resource :preview, only: [ :show ], controller: "esercizi/previews"
      resource :bulk_questions, only: [ :create ], controller: "esercizi/bulk_questions"

      member do
        post :duplicate
      end
      resources :questions, only: [ :create, :edit, :update, :destroy ] do
        post :reorder, on: :collection
      end
      resources :shares, only: [ :index, :create, :destroy ]
    end
    resources :esercizio_templates

    # Classi management (teacher only)
    resources :classi do
      resources :students, only: [ :index, :create, :destroy ], controller: "classi/students"
    end

    # Attempts overview (teacher only)
    resources :attempts, only: [ :index, :show ]
  end

  # Admin management (admin only)
  namespace :admin do
    resources :shares, only: [ :index, :new, :create, :destroy ]
  end

  resources :users do
    scope module: :users do
      resource :avatar
      resource :role
      resource :events

      resources :push_subscriptions

      resources :email_addresses, param: :token do
        resource :confirmation, module: :email_addresses
      end
    end
  end

  namespace :users do
    resources :verifications, only: [ :new, :create ]
  end


  resources :qr_codes, only: :show

  # PWA routes
  get "up", to: "rails/health#show", as: :rails_health_check
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "pwa#service_worker"
end
