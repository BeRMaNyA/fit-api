require 'fit_api/router/parser'
require 'fit_api/router/params'

module Garlix
  module Router
    class Route
      attr_reader :verb, :path, :controller, :action

      def initialize(verb, path, options = {})
        @verb       = verb
        @path       = path
        @controller = get_controller(options)
        @action     = get_action(options)
      end

      def invoke(env)
        request      = Request.new(env)
        route_params = parse(request.path).params
        json_params  = JSON.parse(request.body.read) rescue {}
        params       = Params.new(request.params.merge(route_params).merge(json_params))
        controller   = Object.const_get("#{@controller.capitalize}Controller").new(request, params)

        run! controller
      rescue Halt
        controller.response
      end

      def match?(path)
        parse(path).match?
      end

      private

      def json_params



      end
      def get_controller(options)
        return options[:controller] if options[:controller]
        options[:to].split('#').first
      end

      def get_action(options)
        return options[:action] if options[:action]
        return options[:to].split('#').last if options[:to]
        path[/\w+$/]
      end

      def parse(path)
        Parser.new(@path, path)
      end

      def run!(controller)
        run_callbacks! controller, :before
        controller.send action
        run_callbacks! controller, :after
        controller.response
      ensure
        controller.set_response_headers
      end

      def run_callbacks!(controller, type)
        controller.class.actions[type].each do |action|
          if action[:only].nil? || action[:only].include?(@action.to_sym)
            controller.send action[:method]
          end
        end
      end
    end

    class Request < Rack::Request
      def headers
        env.select { |k,v| k.start_with? 'HTTP_'}.
          transform_keys { |k| k.sub(/^HTTP_/, '').split('_').map(&:capitalize).join('-') }
      end
    end
  end
end
