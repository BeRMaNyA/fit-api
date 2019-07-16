module Garlix
  class Route
    attr_reader :verb, :path, :options

    def initialize(verb, path, options = {})
      @verb = verb
      @path = path
      @options = options
    end

    def match?(request_path)
      match = path.gsub(/\:\w+/, '(\w+)')
      request_path.match?(/^#{match}$/)
    end

    def controller
      return options[:controller] if options[:controller]
      options[:to].split('#').first
    end

    def action
      return options[:action] if options[:action]
      return options[:to].split('#').last if options[:to]
      path[/\w+$/]
    end
  end
end
