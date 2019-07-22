require 'fit_api/router/mapper'

module FitApi
  module Router
    def self.call(env)
      method, path = env['REQUEST_METHOD'], env['PATH_INFO']
      route = find method, path, path != '/'

      return route.invoke(env) if route

      res = path == '/' ? { message: 'fit-api is working!' } : { error: 'action not found' }

      [ res[:error] ? 404 : 200, { 'Content-Type' => 'application/json'}, [ res.to_json ] ]
    end

    def self.find(method, path, find_error = true)
      routes = mapper.routes[method.downcase]
      route = routes.find { |route| route.match? path }

      return route if route

      if find_error 
        not_found = find('get', '/404', false)
        return not_found if not_found
      end
    end

    def self.define(&block)
      mapper.instance_eval &block
    end

    def self.mapper
      @mapper ||= Mapper.new
    end
  end
end
