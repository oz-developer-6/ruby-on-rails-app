Rails.application.routes.draw do
  root to: "dashboard#index"

  get "up" => "rails/health#show", as: :rails_health_check

  resources :schools
  resources :students
  resources :homeworks do
    member do
      post :assign_all
    end
  end
  resources :markings do
    member do
      patch :quick_mark
    end
  end
end
