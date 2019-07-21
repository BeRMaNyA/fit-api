require 'fit_api/router'

module FitApi
  class App
    def call(env)
      Router.call(env)
    end
  end
end
