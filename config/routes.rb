Garlix::App.router.define do
  get '/test/:name', to: 'test#show'

  resources :users do
    resource :avatar do
      resources :comments
    end
  end
  root to: 'test#index'
end
