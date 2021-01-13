# frozen_string_literal: true

module Lorca
  class Document
    LISTENER_IDENTIFIERS = %i[scroll visibilitychange wheel animationcancel animationend animationiteration animationstart copy cut paste drag dragend dragenter dragleave dragover dragstart drop fullscreenchange fullscreenerror keydown keypress keyup DOMContentLoaded readystatechange gotpointercapture lostpointercapture pointercancel pointerdown pointerenter pointerleave pointerlockchange pointerlockerror pointermove pointerout pointerover pointerup selectionchange selectstart touchcancel touchend touchmove touchstart transitioncancel transitionend transitionrun transitionstart].freeze

    def self.listener_identifiers
      LISTENER_IDENTIFIERS
    end

    def self.on_listen_method_name_gen(name)
      ('on_' + name.to_s).to_sym
    end

    def self.emit_listen_method_name_gen(name)
      ('emit_' + name.to_s).to_sym
    end

    def self.instance_variable_name_gen(name)
      ('@' + name.to_s + '_listeners').to_sym
    end

    LISTENER_IDENTIFIERS.each do |name|
      on_listen = on_listen_method_name_gen(name)
      instance_var = instance_variable_name_gen(name)
      emit_listen = emit_listen_method_name_gen(name)
      define_method on_listen do |&block|
        instance_variable_get(instance_var).push block
      end

      define_method emit_listen do |x|
        emit name, x
      end
    end

    def initialize
      LISTENER_IDENTIFIERS.each do |name|
        instance_variable_set(self.class.instance_variable_name_gen(name), [])
      end
    end

    def emit(symbol, args)
      arr = instance_variable_get(self.class.instance_variable_name_gen(symbol))
      arr.each do |y|
        y.call args
      end
    end

    def on_any(&block)
      LISTENER_IDENTIFIERS.each do |x|
        public_send(self.class.on_listen_method_name_gen(x), &block)
      end
    end
  end
end
