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
        define_method "#{callback_type}_action" do |*methods|
          only = methods.last.is_a?(Hash) ? methods.last[:only] : nil
          methods.each do |method|
            unless method.is_a?(Hash) 
              actions[callback_type] << { method: method, only: only }
            end
          end
        end
      end
    end

    def set_response_headers
      headers['Date'] = Rack::Utils.rfc2822(Time.now)
      headers['Content-Type'] = 'application/json'

      headers.each &response.method(:add_header)
    end

    private

    def json(hash, status: 200)
      self.response = Rack::Response.new(hash.to_json, status)
    end

    def halt(*args)
      is_integer = args.first.is_a?(Integer)
      status = is_integer ? args.first : 400
      error = is_integer ? (args.count > 1 ? args.last : '') : args.first 
      json(error, status: status)
      raise Halt
    end
  end
end
