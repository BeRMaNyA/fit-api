Garlix::App.router.define do
  resources :users do
    resources :contacts do
      member do
        post :hello
        get :hello_test
      end
      resources :addresses
    end
  end
end
