module FitApi
  class Halt < StandardError; end

  class Controller
    attr_accessor :response
    attr_reader :request, :params, :headers

    def initialize(request, params)
      @request = request
      @params  = params
      @headers = {}
    end

    class << self
      def actions
        @actions ||= Hash.new { |h,k| h[k] = [] }
      end

      %i(before after).each do |callback_type|
        define_method "#{callback_type}_action" do |*callbacks|
          executable_actions = callbacks.last.is_a?(Hash) ? callbacks.last : {}

          callbacks.each do |method|
            unless method.is_a?(Hash) 
              actions[callback_type] << { method: method }.merge(executable_actions)
            end
          end
        end
      end
    end

    def set_response_headers
      headers['Date'] ||= Rack::Utils.rfc2822(Time.now)
      headers['Content-Type'] ||= 'application/json'

      headers.each &response.method(:add_header)
    end

    def json(hash, status = 200)
      self.response = Rack::Response.new(JSON.pretty_generate(hash), status)
    end

    def halt(*args)
      is_int = args.first.is_a?(Integer)
      status = is_int ? args.first : 400
      error  = is_int ? (args.count > 1 ? args.last : '') : args.first

      json(error, status)
      raise Halt
    end
  end
end
