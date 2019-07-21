module Garlix
  module Router 
    class Params
      def initialize(hash)
        @hash = hash
      end

      def to_json
        @hash.to_json
      end

      def [](key)
        value = @hash[key.to_s]

        if value.is_a?(Hash)
          self.class.new(value) 
        else
          value
        end
      end

      def []=(key, value)
        @hash[key.to_s] = value
      end

      def method_missing(method_sym, *arguments, &block)
        if @hash.include? method_sym.to_s
          send('[]', method_sym.to_s)
        else
          nil
        end
      end

      def except(*blacklist)
        {}.tap do |h|
          (@hash.keys - blacklist).each { |k| h[k] = @hash[k] }
        end
      end

      def permit(*whitelist)
        {}.tap do |h|
          (@hash.keys & whitelist).each { |k| h[k] = @hash[k] }
        end
      end
    end
  end
end