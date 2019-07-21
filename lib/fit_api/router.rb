require 'fit_api/router/mapper'

module FitApi
  module Router
    def self.call(env)
      route = find env['REQUEST_METHOD'], env['PATH_INFO']

      return route.invoke(env) if route

      [ 404, { 'Content-Type' => 'application/json'}, [ { error: 'Not found' }.to_json ] ]
    end

    def self.find(method, path, find_error = true)
      route = mapper.routes[method.downcase].find do |route|
        route.match? path
      end

      return route if route
      return not_found if find_error and not_found
    end

    def self.not_found
      @not_found ||= find('get', '/404', false)
    end

    def self.define(&block)
      mapper.instance_eval &block
    end

    def self.mapper
      @mapper ||= Mapper.new
    end
  end
end
