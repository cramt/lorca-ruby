# frozen_string_literal: true

require 'lorca/version'
require 'ffi'



module Lorca
  module GoFFI
    lib_file = File.join(File.dirname(__FILE__), 'go/lib.so')
    unless File.exist? lib_file
      require_relative '../../build'
    end
    extend FFI::Library
    ffi_lib lib_file
    attach_function :my_add, %i[int int], :int
    attach_function :bounce_string, [:string], :string
    attach_function :add_hello_to_start, [:string], :string
    attach_function :call_func, [:pointer], :int

    attach_function :lorca_new_window, %i[string string int int string], :int, blocking: true
    attach_function :lorca_window_bind, %i[int string int pointer], :void, blocking: true
    attach_function :lorca_window_eval, %i[int string], :string, blocking: true
    attach_function :lorca_get_all_window_ids, [], :string
    attach_function :lorca_close_window, [:int], :void, blocking: true
    attach_function :lorca_load_file, %i[int string], :void, blocking: true
    attach_function :lorca_load_string, %i[int string], :void, blocking: true
    attach_function :lorca_window_wait_for_done, [:int], :void, blocking: true
    attach_function :lorca_set_window_bounds, %i[int string], :void, blocking: true
    attach_function :lorca_get_window_bounds, [:int], :string, blocking: true
  end
end
