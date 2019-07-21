module FitApi
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
      response.add_header 'Content-Type', 'application/json'
      response.add_header 'Date', Rack::Utils.rfc2822(Time.now)

      headers.each &response.method(:add_header)
    end

    private

    def json(hash, status: 200)
      self.response = 
        Rack::Response.new(hash.to_json, status)
    end

    def halt(status = 400, error)
      json(error, status: status)
      raise Halt
    end
  end
end
