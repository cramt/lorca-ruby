# frozen_string_literal: true

require 'lorca/go_ffi'
require 'lorca/observable_hash'
require 'lorca/version'
require 'lorca/bounds'
require 'lorca/document'
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
    attr_reader :document

    def initialize(url, width, height, document_listeners = Document.listener_identifiers.dup, dir = '', *chrome_process_args, id: nil, headless: false)
      @closed = false
      @document = Document.new
      @existing_bindings = {}
      @document_listeners = document_listeners
      if id
        @inner_index = id.to_i
      else
        chrome_process_args.push('--headless') if headless
        url = 'file:///' + url if File.exist?(url)
        @inner_index = GoFFI.lorca_new_window(url.to_s, dir.to_s, width.to_i, height.to_i, chrome_process_args.to_json)
        post_load
      end
      @keep_alive_thread = Thread.new { Lorca::GoFFI.lorca_window_wait_for_done(@inner_index) }
    end

    def set_bindings(bindings = {})
      bindings = Utilities::ObservableHash.new bindings
      bindings.listen do |object, key, value|
        name = [key.to_s]
        while object
          name.unshift object.name
          object = object.parent
        end
        name = name.filter { |x| !x.empty? }.unshift 'LORCA_INTERNALS'
        create_bindings name, value
      end
      create_hash_binding bindings
      bindings
    end

    def create_bindings(name, value)
      name = name.join '.' if name.is_a?(Array)
      @existing_bindings[name] = value
      name = name.split '.'
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
      post_load
      self
    end

    def load_string(html)
      Lorca::GoFFI.lorca_load_string(@inner_index, html.to_s)
      post_load
      self
    end

    def wait_for_done(&block)
      Thread.new do
        @keep_alive_thread.join
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

    def join
      @keep_alive_thread.join
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

    def post_load
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
      h = {
        internal: {
          document: {
            listeners: @document_listeners.map do |x|
              [x, proc { |y| @document.emit x, y }]
            end.to_h
          }
        }
      }
      set_bindings(h)
      js = @document_listeners.map do |name|
        name = name.to_s
        "document.addEventListener(\"#{name}\", (...c) => Lorca.internal.document.listeners.#{name}(...c));"
      end.join('')
      js = "(()=>{#{js}})()"
      eval js
      @existing_bindings.each do |(key, val)|
        create_bindings key, val
      end
    end
  end
end
