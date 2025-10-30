Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Exercise routes
  get 'exercises/phonetic', to: 'exercises#phonetic_exercise', as: 'phonetic_exercise'
  get 'exercises/phonetic2', to: 'exercises#phonetic_exercise2', as: 'phonetic_exercise2'
  get 'exercises/pag22', to: 'exercises#pag22', as: 'pag22'
  get 'exercises/pag23', to: 'exercises#pag23', as: 'pag23'
  get 'exercises/pag41', to: 'exercises#pag41', as: 'pag41'
  get 'exercises/pag43', to: 'exercises#pag43', as: 'pag43'
  get 'exercises/pag50', to: 'exercises#pag50', as: 'pag50'
  get 'exercises/pag51', to: 'exercises#pag51', as: 'pag51'
  get 'exercises/pag167', to: 'exercises#pag167', as: 'pag167'
  get 'exercises/sussi_pag_5', to: 'exercises#sussi_pag_5', as: 'sussi_pag_5'
  get 'exercises/sussi_pag_14', to: 'exercises#sussi_pag_14', as: 'sussi_pag_14'
  get 'exercises/pag08', to: 'exercises#pag08', as: 'pag08'

  # Defines the root path route ("/")
  root "exercises#phonetic_exercise"
end
