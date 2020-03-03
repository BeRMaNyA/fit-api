# frozen_string_literal: true

require "fit_api/router/parser"
require "fit_api/router/params"

module FitApi
  module Router
    class Request < Rack::Request
      def headers
        env.select { |k,v| k.start_with? "HTTP_"}.
          transform_keys { |k| k.sub(/^HTTP_/, "").split("_").map(&:capitalize).join("-") }
      end
    end

    class Route
      def initialize(verb, path, options = {})
        @verb       = verb
        @path       = path
        @controller = get_controller(options)
        @action     = get_action(options)

        require_controller
      end

      def invoke(env)
        request    = Request.new(env)
        params     = build_params(request)
        controller = Object.const_get("#{@controller.to_s.capitalize}Controller").new(request, params)

        controller.invoke(@action)
      rescue Halt
        controller.response
      end

      def match?(path)
        Parser.new(@path, path).match?
      end

      private

      def get_controller(options)
        return options[:controller] if options[:controller]
        options[:to].split("#").first
      end

      def get_action(options)
        return options[:action] if options[:action]
        return options[:to].split("#").last if options[:to]
        @path[/\w+$/]
      end

      def require_controller
        if path = Router.auto_load_path
          require "./#{path}/#{@controller}_controller"
        end
      end

      def build_params(request)
        route_params = Parser.new(@path, request.path).params
        params       = JSON.parse(request.body.read) rescue request.params

        new_params = params.merge(route_params)
        new_params.extend(Params)
        new_params.with_indifferent_access
        new_params
      end
    end
  end
end
