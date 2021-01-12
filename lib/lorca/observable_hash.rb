# frozen_string_literal: true

module Lorca
  module Utilities
    class ObservableHash
      include Enumerable

      attr_reader :parent
      attr_reader :name
      def initialize(inner = {}, parent = nil, name = '')
        @listeners = []
        @parent = parent
        @name = name
        @inner = inner.each_with_object({}) do |(k, v), h|
          if v.is_a? Hash
            v = ObservableHash.new v, self, k.to_s
            v.listen do |object, key, value|
              notice object, key, value
            end
          end
          h[k] = v
        end
      end

      def listen(&block)
        @listeners.push block.to_proc
        self
      end

      def notice(object, key, value)
        @listeners.each { |x| x.call(object, key, value) }
        self
      end

      def [](key)
        @inner[key]
      end

      def []=(key, value)
        value = ObservableHash.new value, self, key.to_s if value.is_a?(Hash)
        notice self, key, value
        @inner[key] = value
      end

      def each(&block)
        @inner.each(&block)
      end
    end
  end
end
