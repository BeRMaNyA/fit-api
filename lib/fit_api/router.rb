# frozen_string_literal: true

require "fit_api/router/mapper"

module FitApi
  module Router
    module_function

    def call(env)
      method, path = env["REQUEST_METHOD"], env["PATH_INFO"]
      is_root = path == "/"

      if route = find(method, path, !is_root)
        return route.invoke(env)
      end

      status = is_root ? 200 : 404
      res    = is_root ? "fit-api is working!" : "Action not found"

      [ status, { "Content-Type" => "application/json" }, [ res.to_json ] ]
    end

    def find(method, path, fetch_not_found = true)
      route = mapper.routes[method.downcase].find { |route| route.match? path }
      return route if route

      if fetch_not_found
        not_found = find("get", "/404", false)
        return not_found if not_found
      end
    end

    def auto_load_path(path = nil)
      return @auto_load_path unless path
      @auto_load_path = path
    end

    def define(&block)
      mapper.instance_eval &block
    end

    def mapper
      @mapper ||= Mapper.new
    end
  end
end
