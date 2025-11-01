Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Exercise routes
  get "exercises/pag008", to: "exercises#pag008", as: "pag008"
  get "exercises/pag010", to: "exercises#pag010", as: "pag010"
  get "exercises/pag010gen", to: "exercises#pag010gen", as: "pag010gen"
  get "exercises/pag022", to: "exercises#pag022", as: "pag022"
  get "exercises/pag023", to: "exercises#pag023", as: "pag023"
  get "exercises/pag041", to: "exercises#pag041", as: "pag041"
  get "exercises/pag043", to: "exercises#pag043", as: "pag043"
  get "exercises/pag050", to: "exercises#pag050", as: "pag050"
  get "exercises/pag051", to: "exercises#pag051", as: "pag051"
  get "exercises/pag167", to: "exercises#pag167", as: "pag167"
  get "exercises/sussi_pag_5", to: "exercises#sussi_pag_5", as: "sussi_pag_5"
  get "exercises/sussi_pag_14", to: "exercises#sussi_pag_14", as: "sussi_pag_14"
  get "exercises/nvl_4_gr_pag008", to: "exercises#nvl_4_gr_pag008", as: "nvl_4_gr_pag008"
  get "exercises/nvl_4_gr_pag009", to: "exercises#nvl_4_gr_pag009", as: "nvl_4_gr_pag009"
  get "exercises/nvl_4_gr_pag014", to: "exercises#nvl_4_gr_pag014", as: "nvl_4_gr_pag014"
  get "exercises/nvl_4_gr_pag015", to: "exercises#nvl_4_gr_pag015", as: "nvl_4_gr_pag015"
  get "exercises/bus3_mat_p025", to: "exercises#bus3_mat_p025", as: "bus3_mat_p025"
  get "exercises/bus3_mat_p144", to: "exercises#bus3_mat_p144", as: "bus3_mat_p144"

  # Defines the root path route ("/")
  root "exercises#pag010"
end
