require_relative 'route'

module Garlix
  class Router
    attr_reader :routes

    def initialize
      @routes = Hash.new { |h,k| h[k] = [] }
      @namespaces = []
    end

    def find(env)
      path   = env['PATH_INFO'].gsub(/\/^/, '')
      method = env['REQUEST_METHOD'].downcase

      route = routes[method].find do |route|
        route.parse(path).match?
      end

      return route if route
    end

    def define(&block)
      instance_eval &block
    end

    %w(get post put delete patch).each do |verb|
      define_method verb do |path, options = {}|
        options[:controller] ||= @controller

        path  = fix_path(path)
        route = Route.new(verb, "#{@namespaces.join}#{path}", options)

        @routes[verb] << route
      end
    end

    %i(resource resources).each do |method_name|
      define_method method_name do |resource, options = {}, &block|
        resourcify method_name, resource, options, &block
      end
    end

    def member(&block)
      namespace '/:id', &block
    end

    def collection(&block)
      instance_eval &block
    end

    def namespace(path, options = {}, &block)
      @namespaces << fix_path(path)
      if controller = options[:controller]
        previous, @controller = @controller, controller
      end
      instance_eval &block
      @controller = previous if controller
      @namespaces.pop
    end

    def controller(controller, &block)
      @controller = controller
      instance_eval &block
      @controller = nil
    end

    def root(to:)
      get '/', to: to
    end

    def to_s
      output = "\n"
      routes.keys.each do |verb|
        routes[verb].each do |route|
          output << "#{route.controller}##{route.action} => #{route.verb.upcase} #{route.path}\n"
        end
        output << "-" * 20 + "\n"
      end
      output << "\n"
    end

    private

    def resourcify(type, resource, options, &block)
      options[:only] ||= %i(index show create update destroy)
      path = get_path(type, resource)

      @parent = [ type, resource ]
      @controller = options[:controller] || resource

      namespace path, options do
        crud type, resource, options[:only]
        instance_eval &block if block
      end

      @parent, @controller = nil, nil
    end

    def crud(type, resource, actions)
      path = get_resource_path(type)

      actions.delete(:index) if type == :resource

      actions.each do |action|
        case action
        when :index
          get '', to: "#{resource}#index"
        when :create
          post '', to: "#{resource}#create"
        when :show
          get path, to: "#{resource}#show"
        when :update
          patch path, to: "#{resource}#update"
        when :destroy
          delete path, to: "#{resource}#destroy"
        end
      end
    end

    def get_path(type, resource)
      return "/:#{singularize(@parent.last)}_id/#{resource}"              if type == :resources && parent_is?(:resources)
      return "/:#{singularize(@parent.last)}_id/#{singularize(resource)}" if type == :resource  && parent_is?(:resources)
      return "/#{singularize(resource)}"                                  if type == :resource  && parent_is?(:resource)
      return "/#{resource}"
    end

    def parent_is?(type)
      @parent && @parent.first == type
    end

    def get_resource_path(type)
      return type == :resources ? '/:id' : ''
    end

    def fix_path(path)
      if path.is_a?(Symbol) || path[0] != '/' && path != ''
        "/#{path}"
      else
        path
      end
    end

    def singularize(word)
      Garlix.inflector.singularize(word)
    end
  end
end
