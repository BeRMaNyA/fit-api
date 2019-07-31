require 'fit_api/router/parser'
require 'fit_api/router/params'

module FitApi
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
        controller   = Object.const_get("#{@controller.to_s.capitalize}Controller").new(request, params)

        run! controller
      rescue Halt
        controller.set_response_headers
        controller.response
      rescue Exception => ex
        error = { message: "#{ex.message} (#{ex.class})", backtrace: ex.backtrace }
        controller.json(ENV['RACK_ENV'] == 'production' ? 'An error has occured' : error, 500)
      end

      def match?(path)
        parse(path).match?
      end

      private

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
        controller.set_response_headers
        controller.response
      end

      def run_callbacks!(controller, type)
        klass = controller.class

        while klass != Object
          actions = klass.actions[type].each do |rule|
            controller.send(rule[:method]) if run?(rule)
          end
          klass = klass.superclass
        end
      end

      def run?(rule)
        except, only = rule[:except], rule[:only]

        except && !except.map(&:to_s).include?(action) ||
          only && only.map(&:to_s).include?(action) ||
            !only && !except
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
