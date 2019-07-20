require 'forwardable'

module Garlix
  class Controller
    extend Forwardable

    attr_accessor :response
    attr_reader :request, :params

    def_delegators :response, :add_header

    def initialize(request, params)
      @request = request
      @params = params
    end

    def json(hash, status: 200)
      self.response = Rack::Response.new(hash.to_json, status)
      set_default_headers
      response
    end

    def halt(status, error)
      json(error, status: status)
      raise Halt
    end

    private

    def set_default_headers
      add_header 'Content-Type', 'application/json'
      add_header 'Date', Rack::Utils.rfc2822(Time.now)
    end
  end
end
