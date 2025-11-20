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

  # API endpoint for dynamic column addition grid
  get "exercises/column_addition_grid", to: "exercises#column_addition_grid", as: "column_addition_grid"

  # Strumenti
  namespace :strumenti do
    get "addizioni", to: "addizioni#show", as: "addizioni"
    get "sottrazioni", to: "sottrazioni#show", as: "sottrazioni"
    get "le_rime", to: "le_rime#show", as: "le_rime"
    get "abaco", to: "abaco#show", as: "abaco"
    get "abaco/examples", to: "abaco#examples", as: "abaco_examples"
  end

  # Defines the root path route ("/")
  root "volumi#index"
end
