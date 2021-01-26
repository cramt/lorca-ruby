# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)
require 'lorca'

path = File.join(__dir__, 'index.html')
ui = Lorca::UI.new path, 480, 480, [], ''
ui.set_bindings({
                  say_hello: proc do |x|
                    s = 'hello ' + x.first
                    puts s
                    s
                  end
                })
ui.eval('console.log(document.readyState)')
ui.join
