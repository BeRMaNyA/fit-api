module Garlix
  class Resource
    attr_reader :routes, :resource, :options
    attr_accessor :namespace_type, :children

    def initialize(resource, options)
      @routes = []
      @resource = resource

      set_defaults options
      crud resource, options[:only]
    end

    def resources(resource, options = {}, &block)
      child = Resource.new(resource, options.merge(parent: self))
      child.instance_eval &block if block

      child.routes.each do |route|
        @routes << route
      end
    end

    %i(get post put delete patch).each do |verb|
      define_method verb do |path, options = {}|
        path = "/#{path}" if path.is_a?(Symbol)
        @routes << Route.new(verb, "#{namespace}#{path}", options.merge(verb: verb))
      end
    end

    %i(collection member).each do |type|
      define_method type do |&block|
        self.namespace_type = type
        instance_eval &block
        self.namespace_type = nil
      end
    end
 
    private

    def set_defaults(options)
      @options = options
      @options[:only] ||= %w(index show create update destroy)
      @options[:controller] ||= resource.capitalize.to_s
    end

    def namespace
      resource = "/#{self.resource}"
      resource << "/:id" if namespace_type == :member
      namespace = [ resource ]

      options = self.options

      while options[:parent]
        namespace << [ "/#{options[:parent].resource}/:id" ]
        options = options[:parent].options
      end
  
      namespace.reverse.join('')
    end

    def crud(resource, actions)
      actions.each do |action|
        case action
        when 'index'
          get '', to: "#{resource}#index"
        when 'create'
          post '', to: "#{resource}#create"
        when 'show'
          get "/:id", to: "#{resource}#show"
        when 'update'
          patch "/:id", to: "#{resource}#update"
        when 'destroy'
          delete "/:id", to: "#{resource}#destroy"
        end
      end
    end
  end
end
