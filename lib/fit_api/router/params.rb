# frozen_string_literal: true

module FitApi
  module Router 
    module Params
      def [](key)
        value = super(key.to_s)
        if value.is_a?(Hash)
          value.extend(Params)
        end
        value
      end

      def except(*blacklist)
        blacklist.map!(&:to_s)
        build(keys - blacklist)
      end

      def permit(*whitelist)
        whitelist.map!(&:to_s)
        build(keys & whitelist)
      end

      private

      def build(new_keys)
        {}.tap do |h|
          new_keys.each { |k| h[k] = self[k] }
        end.extend(Params)
      end

      def method_missing(method_sym, *args, &block)
        attr = self.key?(method_sym) ? method_sym : method_sym.to_s
        self[attr]
      end
    end
  end
end
