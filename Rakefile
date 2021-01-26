# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
$LOAD_PATH.unshift File.expand_path('./lib', __dir__)

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task :setup do
  if go_installed
    puts 'installing lorca go package'
    puts `go get github.com/zserge/lorca`
    puts 'compiling internal go ffi binary'
    compile_internal_go_ffi
  else
    puts 'go not installed'
  end
end

task :compile do
  compile_internal_go_ffi
end

def compile_internal_go_ffi
  require_relative './build'
end

def go_installed
  installed = true
  begin
    `go version`
  rescue Errno::ENOENT
    installed = false
  end
  installed
end
