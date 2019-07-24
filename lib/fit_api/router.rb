require 'fit_api/router/mapper'

module FitApi
  module Router
    def self.call(env)
      method, path = env['REQUEST_METHOD'], env['PATH_INFO']
      is_root = path == '/'

      if route = Router.find(method, path, !is_root)
        route.invoke(env)
      else
        status = is_root ? 200 : 404
        res    = is_root ? 'fit-api is working!' : 'Action not found'

        [ status, { 'Content-Type' => 'application/json'}, [ res.to_json ] ]
      end
    end

    def self.find(method, path, find_not_found_action = true)
      routes = mapper.routes[method.downcase]
      route = routes.find { |route| route.match? path }

      return route if route

      if find_not_found_action
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
