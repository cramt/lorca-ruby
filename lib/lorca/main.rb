# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../', __dir__)
require 'lorca/go_ffi'
require 'lorca/observable_hash'
require 'lorca/version'
require 'json'
require 'securerandom'

module Lorca
  class UI
    def self.get_all
      JSON.parse(GoFFI.lorca_get_all_window_ids).map do |i|
        UI.new nil, nil, nil, nil, id: i
      end
    end

    attr_reader :closed

    def initialize(url, dir, width, height, *chrome_process_args, id: nil, headless: false)
      chrome_process_args.push('--headless') if headless
      @closed = false
      if id
        @inner_index = id.to_i
      else
        @inner_index = GoFFI.lorca_new_window(url.to_s, dir.to_s, width.to_i, height.to_i, chrome_process_args.to_json)
        eval "(()=>{
const createProxy = (ref) => {
  return new Proxy(()=>{}, {
    get: (_, value) => {
      return createProxy(ref[value])
    },
    apply: (_a, _b, args) => {
      return (async()=>JSON.parse(await ref(JSON.stringify(args))))()
    }
  })
}
window.LORCA_INTERNALS = {}
window.Lorca = createProxy(window.LORCA_INTERNALS)
window.LorcaInitialized = true
})()"
      end
    end

    def set_bindings(bindings)
      bindings = Utilities::ObservableHash.new bindings
      bindings.listen do |object, key, value|
        name = [key.to_s]
        while object
          name.unshift object.name
          object = object.parent
        end
        name = name.filter { |x| !x.empty? }
        create_bindings name, value
      end
      create_hash_binding bindings
      bindings
    end

    def create_bindings(name, value)
      name = name.split '.' if name.is_a?(String)
      id = '______' + SecureRandom.uuid.to_s.gsub('-', '_')
      GoFFI.lorca_window_bind(@inner_index, id, value.arity, FFI::Function.new(:pointer, [:string]) do |x|
        FFI::MemoryPointer.from_string(value.call(JSON.parse(x)).to_json)
      end)
      name.unshift 'window'
      (name.length - 1).times do |i|
        name[i + 1] = name[i] + '.' + name[i + 1]
      end
      last = name.pop + '=' + id
      js = name.map do |x|
        "
if(!#{x}) {
  #{x} = {}
}"
      end.join('') + last
      js = "(()=>{#{js}})()"
      self.eval(js)
      self
    end

    def eval(js)
      js = js.to_s
      json = GoFFI.lorca_window_eval(@inner_index, js)
      p json
      if json.empty?
        nil
      else
        JSON.parse json
      end
    end

    def close
      Lorca::GoFFI.lorca_close_window(@inner_index)
      @closed = true
      self
    end

    def load_file(path)
      Lorca::GoFFI.lorca_load_file(@inner_index, path.to_s)
      self
    end

    def load_string(html)
      Lorca::GoFFI.lorca_load_string(@inner_index, html.to_s)
      self
    end

    def wait_for_done(&block)
      Thread.new do
        Lorca::GoFFI.lorca_window_wait_for_done(@inner_index)
        block.call
      end
      self
    end

    def bounds=(bounds)
      Lorca::GoFFI.lorca_set_window_bounds(@inner_index, bounds.to_json)
    end

    def bounds
      Bounds.from_json Lorca::GoFFI.lorca_get_window_bounds(@inner_index).to_s
    end

    private

    def create_hash_binding(binding_hash, pre_name = ['LORCA_INTERNALS'])
      binding_hash.each do |(k, v)|
        k = pre_name.dup.push k.to_s
        if v.is_a?(Hash) || v.is_a?(Utilities::ObservableHash)
          create_hash_binding v, k
        else
          create_bindings k, v
        end
      end
    end
  end
end
