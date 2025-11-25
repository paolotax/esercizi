Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Navigation routes for books hierarchy
  resources :corsi, only: [ :index, :show ]
  resources :volumi, only: [ :index, :show ]
  resources :discipline, only: [ :show ]

  # Dynamic page routing by slug
  get "pagine/:slug", to: "pagine#show", as: "pagina"

  # API endpoint for dynamic column operations grid (addizioni, sottrazioni, miste, con prova)
  get "exercises/column_operations_grid", to: "exercises#column_operations_grid", as: "column_operations_grid"

  # Dashboard per costruzione esercizi
  namespace :dashboard do
    resources :esercizi do
      member do
        post :duplicate
        get :preview
        get :export_pdf
        post :add_operation
        delete :remove_operation
        patch :reorder_operations
        get :operation_properties
        patch :update_operation
      end
    end
    resources :esercizio_templates
  end

  # Area pubblica per esercizi condivisi
  get 'e/:share_token', to: 'public_esercizi#show', as: :public_esercizio
  post 'e/:share_token/attempt', to: 'public_esercizi#attempt', as: :public_esercizio_attempt
  get 'e/:share_token/results/:attempt_id', to: 'public_esercizi#results', as: :public_esercizio_results

  # Strumenti
  namespace :strumenti do
    get "addizioni", to: "addizioni#show", as: "addizioni"
    post "addizioni/generate", to: "addizioni#generate", as: "addizioni_generate"
    get "sottrazioni", to: "sottrazioni#show", as: "sottrazioni"
    post "sottrazioni/generate", to: "sottrazioni#generate", as: "sottrazioni_generate"
    get "moltiplicazioni", to: "moltiplicazioni#show", as: "moltiplicazioni"
    post "moltiplicazioni/generate", to: "moltiplicazioni#generate", as: "moltiplicazioni_generate"
    get "moltiplicazioni/examples", to: "moltiplicazioni#examples", as: "moltiplicazioni_examples"
    get "le_rime", to: "le_rime#show", as: "le_rime"
    get "abaco", to: "abaco#show", as: "abaco"
    post "abaco/generate", to: "abaco#generate", as: "abaco_generate"
    get "abaco/examples", to: "abaco#examples", as: "abaco_examples"
  end

  # Defines the root path route ("/")
  root "volumi#index"
end
