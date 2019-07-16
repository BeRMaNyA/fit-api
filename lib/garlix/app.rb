require_relative 'router'

module Garlix
  class App
    class << self; attr_reader :router end
    @router = Router.new

    def call(env)
      route = self.class.router.find(env)
      return route.call(env) if route

      [ 404, { 'Content-Type' => 'application/json'}, [ { error: 'Not found' }.to_json ] ]
    end
  end
end
