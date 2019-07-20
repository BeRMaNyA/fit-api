require_relative 'parser'
require_relative 'params'
require_relative 'controller'

module Garlix
  class Route
    attr_reader :verb, :path, :controller, :action

    def initialize(verb, path, options = {})
      @verb       = verb
      @path       = path
      @controller = get_controller(options)
      @action     = get_action(options)
    end

    def parse(path)
      Parser.new(@path, path)
    end

    def call(env)
      request      = Rack::Request.new(env)
      route_params = parse(request.path).params
      params       = Params.new(request.params.merge(route_params))
      controller   = @controller.new(request, params)

      controller.send @action
    rescue Halt
      controller.response
    end

    private

    def get_controller(options)
      if options[:controller]
        Object.const_get("#{options[:controller]}Controller")
      else
        Object.const_get("#{options[:to].split('#').first.capitalize}Controller")
      end
    end

    def get_action(options)
      return options[:action] if options[:action]
      return options[:to].split('#').last if options[:to]
      path[/\w+$/]
    end
  end
end
