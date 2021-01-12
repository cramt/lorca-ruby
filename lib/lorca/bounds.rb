# frozen_string_literal: true

require 'json'

module Lorca
  class Bounds
    attr_accessor :left, :top, :width, :height, :window_state

    def initialize(left, top, width, height, window_state)
      @left = left
      @top = top
      @width = width
      @height = height
      @window_state = window_state
    end

    def to_h
      {
        left: left,
        top: top,
        width: width,
        height: height,
        windowState: window_state
      }
    end

    def to_json(*_args)
      to_h.to_json
    end

    def self.from_json(str)
      hash = JSON.parse str, symbolize_names: true
      unless %w[normal maximized minimized fullscreen].include? hash[:windowState]
        raise('windowState enum isnt valid, its ' + hash[:windowState].to_s)
      end

      Bounds.new hash[:left], hash[:top], hash[:width], hash[:height], hash[:windowState].to_sym
    end

    def self.normal
      :normal
    end

    def self.maximized
      :maximized
    end

    def self.minimized
      :minimized
    end

    def self.fullscreen
      :fullscreen
    end
  end
end
