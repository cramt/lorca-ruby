# frozen_string_literal: true

require_relative './test_helper'
require 'lorca/main'
require 'ffi'
require 'lorca/bounds'

module Lorca
  class MainTest < Minitest::Spec
    include Lorca
    after :all do
      Lorca::UI.get_all.map(&:close)
    end

    def new_ui
      UI.new '', '', 280, 480, headless: true
    end

    def test_that_initialization_dont_crash
      new_ui
    end

    def test_that_eval_works
      ui = new_ui
      assert_equal 4, ui.eval('2+2')
    end

    def test_that_load_works
      ui = new_ui
      ui.load_string("
    <span id=\"thingy\">2</span>
                   ")
      sleep 0.01
      assert_equal '2', ui.eval('document.getElementById("thingy").innerHTML')
    end

    def test_that_set_bounds
      ui = UI.new '', '', 280, 480
      ui.bounds = Lorca::Bounds.new 120, 120, 140, 140, :normal
      bounds = ui.bounds
      assert_equal 120, bounds.left
      assert_equal 120, bounds.top
      assert_equal 140, bounds.width
      assert_equal 140, bounds.height
      assert_equal :normal, bounds.window_state
    end

    def test_that_bindings_work
      ui = new_ui
      ui.create_bindings 'add', proc { |_x|
        'gayass'
      }
      assert_equal '"gayass"', ui.eval('add("2")')
    end

    def test_that_bindings_objects_work
      ui = new_ui
      ui.create_bindings 'add.add', proc { |_x|
        'gayass'
      }
      assert_equal '"gayass"', ui.eval('add.add("2")')
    end

    def test_that_hash_bindings_sets_internals
      ui = new_ui
      ui.set_bindings({
                        test: proc { |_x|
                          'aaa'
                        }
                      })
      assert_equal '"aaa"', ui.eval('LORCA_INTERNALS.test("2")')
    end

    def test_that_lorca_is_initialized
      ui = new_ui
      assert_equal true, ui.eval('!!window.LorcaInitialized')
    end

    def test_that_add_function_works
      ui = new_ui
      ui.set_bindings({
                        add: proc { |x|
                          x[0] + x[1]
                        }
                      })
      assert_equal 4, ui.eval('window.Lorca.add(2,2)')
    end
  end
end
