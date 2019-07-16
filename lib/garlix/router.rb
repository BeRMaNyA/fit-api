require_relative 'route'
require_relative 'resource'

module Garlix
  class Router
    attr_reader :routes
    attr_accessor :namespace, :controller

    def initialize
      @routes = Hash.new { |h,k| h[k] = [] }
      @namespace = ''
    end

    def find(env)
      path   = env['PATH_INFO']
      method = env['REQUEST_METHOD'].downcase.to_sym

      route = routes[method].find { |route| route.match?(path) }

      return route if route
    end

    def define(&block)
      instance_eval &block
    end

    %i(get post put delete patch).each do |verb|
      define_method "#{verb}" do |path, options = {}|
        options[:controller] ||= self.controller
        @routes[verb] << Route.new(verb, "#{self.namespace}#{path}", options)
      end
    end

    def resources(resource, options = {}, &block)
      resource = Resource.new(resource, options)
      resource.instance_eval &block

      resource.routes.each do |route|
        @routes[route.verb] << route
      end
    end

    def namespace(path, options = {}, &block)
    end

    def to_s
      output = "\n"
      routes.keys.each do |verb|
        routes[verb].each do |route|
          output << "#{route.verb.upcase} #{route.path}\n"
        end
        output << "-" * 20 + "\n"
      end
      output << "\n"
    end
  end
end
