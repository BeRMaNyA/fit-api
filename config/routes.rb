Garlix::Router.define do
  get '/test/:name', to: 'test#show'

  post '/test', to: 'test#create'

  not_found 'test#error'

  root to: 'test#index'
end
