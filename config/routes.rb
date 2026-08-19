Rails.application.routes.draw do
  resources :check_ins, only: [] do
    member do
      post :mark_ready
    end
  end
end
