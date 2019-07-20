module Garlix
  class Parser
    attr_reader :params

    def initialize(route, path)
      @route = route
      @path  = path
      @match = false
      @params = {}

      parse
    end

    def match?
      @match
    end

    private

    def parse
      result = @path.scan(/^#{regexp}$/)
      set_params(result.flatten) if result.any?
    end

    def set_params(result)
      @match = true 
      params = @route.scan(/\/\:+(\w+)/).flatten

      if params.any?
        params.each_index do |i|
          @params[params[i]] = get_value(result[i])
        end
      end
    end

    def get_value(value)
      value.match(/^\d+$/) ? value.to_i : value
    end

    def regexp
      @route.gsub(/\:\w+/, '([^\/]*)')
    end
  end
end
