require 'fit_api/router/route'

module FitApi
  module Router
    class Mapper
      attr_reader :routes

      def initialize
        @routes = Hash.new { |h,k| h[k] = [] }
        @namespaces = []
      end

      %w(get post put delete patch).each do |verb|
        define_method verb do |path, options = {}|
          options[:controller] ||= @controller
          route = Route.new(verb, "#{@namespaces.join}#{fix_path(path)}", options)
          @routes[verb] << route
        end
      end

      %i(resource resources).each do |resource_type|
        define_method resource_type do |resource, options = {}, &block|
          set_resource resource_type, resource, options, &block
        end
      end

      def root(to:)
        get '', to: to
      end

      def not_found(to:)
        get '/404', to: to
      end

      def member(&block)
        namespace '/:id', &block
      end

      def collection(&block)
        instance_eval &block
      end

      def namespace(path, options = {}, &block)
        @namespaces << fix_path(path)
        if controller = options[:controller] || path
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

      private

      def set_resource(type, resource, options, &block)
        options[:only] ||= %i(index show create update destroy)
        path = get_path(type, resource)

        @parent = [ type, resource ]
        @controller = options[:controller] || resource

        namespace path, options do
          set_actions type, resource, options[:only]
          instance_eval &block if block
        end

        @parent, @controller = nil, nil
      end

      def set_actions(type, resource, actions)
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
        return "/:#{s(@parent.last)}_id/#{resource}"    if type == :resources && parent_is?(:resources)
        return "/:#{s(@parent.last)}_id/#{s(resource)}" if type == :resource  && parent_is?(:resources)
        return "/#{s(resource)}"                        if type == :resource  && parent_is?(:resource)
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

      def s(word)
        FitApi.inflector.singularize(word)
      end
    end
  end
end
