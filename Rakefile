# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
$LOAD_PATH.unshift File.expand_path('./lib', __dir__)

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task :compile do
  `go build -o lib/lorca/go/lib.so -buildmode=c-shared lib/lorca/go/main.go`
end
