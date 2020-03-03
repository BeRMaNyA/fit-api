# frozen_string_literal: true

module FitApi
  module Router
    class Parser
      attr_reader :params

      def initialize(route, path)
        @route = route
        @path  = path.gsub(/\/$/, "")
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

        params.each_index do |i|
          @params[params[i]] = 
            result[i].match(/^\d+$/) ? result[i].to_i : URI.decode_www_form_component(result[i])
        end
      end

      def regexp
        @route.gsub(/\:\w+/, "([^\/]*)")
      end
    end
  end
end
