require 'fit_api/router'

module Garlix
  class App
    def call(env)
      Router.call(env)
    end
  end
end
