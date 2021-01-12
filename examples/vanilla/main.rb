$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)
require "lorca/main"

path = "file:///" + File.join(__dir__, 'index.html')
ui = Lorca::UI.new path, "", 480, 480
ui.set_bindings({
                  say_hello: Proc.new do |x|
                    s = "hello " + x.first
                    puts s
                    s
                  end
                })

ui.join
