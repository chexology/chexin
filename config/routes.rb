Rails.application.routes.draw do
  root "properties#index"

  get "properties/:slug/activity", to: "properties#activity", as: :property_activity

  resources :properties, only: [:edit, :update], param: :slug

  resources :check_ins, only: [] do
    member do
      post :mark_ready
    end
  end
end
