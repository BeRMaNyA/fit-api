# frozen_string_literal: true

module FitApi
  class Halt < StandardError; end

  class Controller
    attr_accessor :response, :action
    attr_reader :request, :params, :headers

    def initialize(request, params)
      @request = request
      @params  = params

      set_default_headers

      @response = [ 501, @headers, [ 'Not implemented' ] ]
    end

    class << self
      def actions
        @actions ||= Hash.new { |h,k| h[k] = [] }
      end

      %i(before after).each do |callback_type|
        define_method "#{callback_type}_action" do |*callbacks|
          options = callbacks.last.is_a?(Hash) ? callbacks.last : {}

          callbacks.each do |method|
            next if method.is_a?(Hash) 
            actions[callback_type] << { method: method }.merge(options)
          end
        end
      end
    end

    def json(status = 200, data)
      data = data.to_h unless data.is_a?(Hash) && data.is_a?(String)
      json = JSON.pretty_generate(data)
      @response = [ status, headers, [ json ] ]
    end

    def halt(*args)
      is_int = args.first.is_a?(Integer)
      status = is_int ? args.first : 400
      error  = is_int ? (args.count > 1 ? args.last : "") : args.first

      json(status, error.to_h)
      raise Halt
    end

    def invoke(action)
      return unless respond_to?(action)
      self.action = action.to_sym
      trigger_callbacks(:before, action)
      send(action)
      trigger_callbacks(:after, action)
      @response
    end

    private

    def set_default_headers
      @headers = {
        "Date"         => Rack::Utils.rfc2822(Time.now),
        "Content-Type" => "application/json"
      }
    end

    def trigger_callbacks(type, action)
      klass = self.class
      while klass != Object
        actions = klass.actions[type].each do |rule|
          send(rule[:method]) if run?(rule, action.to_sym)
        end
        klass = klass.superclass
      end
    end

    def run?(rule, action)
      except, only = Array(rule[:except]), Array(rule[:only])

      except.any? && !except.include?(action) ||
        only.any? && only.include?(action) ||
          only.empty? && except.empty?
    end
  end
end
