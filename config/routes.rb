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
  get 'exercises/pag50', to: 'exercises#pag50', as: 'pag50'
  get 'exercises/pag51', to: 'exercises#pag51', as: 'pag51'

  # Defines the root path route ("/")
  root "exercises#phonetic_exercise"
end
