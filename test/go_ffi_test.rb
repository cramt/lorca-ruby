# frozen_string_literal: true

require_relative './test_helper'
require 'lorca/main'
require 'ffi'

module Lorca
  class GoFFITest < Minitest::Spec
    after :all do
      Lorca::UI.get_all.map(&:close)
    end

    def test_that_ffi_works
      assert_equal 4, Lorca::GoFFI.my_add(2, 2)
      assert_equal 'hello', Lorca::GoFFI.bounce_string('hello')
      assert_equal 'hello world', Lorca::GoFFI.add_hello_to_start('world')
      assert_equal 2, Lorca::GoFFI.call_func(FFI::Function.new(:int, []) do
        2
      end)
    end

    def test_that_window_opens
      Lorca::GoFFI.lorca_new_window('', '', 480, 320, '["--headless"]')
    end

    def test_that_window_can_eval
      id = Lorca::GoFFI.lorca_new_window('', '', 480, 320, '["--headless"]')
      assert_equal '4', Lorca::GoFFI.lorca_window_eval(id, '2+2')
      assert_equal '"22"', Lorca::GoFFI.lorca_window_eval(id, "'2'+2")
      assert_equal '{"b":2}', Lorca::GoFFI.lorca_window_eval(id, '{"b":2}')
      assert_equal '[2,3]', Lorca::GoFFI.lorca_window_eval(id, '[2,3]')
    end
  end
end
