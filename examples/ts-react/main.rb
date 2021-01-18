# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)
require 'lorca'

path = File.join(__dir__, 'dist/index.html')
ui = Lorca::UI.new "", 480, 480, []
ui.load_string("<html>
<head>
<title>loading</title>
</head>
<body>
<div>loading</div>
</body>
</html>")

Thread.new do
  f = IO.popen("node builder.js")
  f.each do |x|
    if x.start_with?("webpack finished compiling")
      ui.load_file path
    else
      raise x
    end
  end
end

ui.join
