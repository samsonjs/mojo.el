require 'rubygems'

desc "Default task (builds mojo.el)"
task :default => [:build]

desc "Build mojo.el"
task :build do
  Dir.chdir 'src'
  require 'assemble'
  begin
    Assembler.go!
    puts "XD"
  rescue RuntimeError => e
    puts ":("
    raise e.inspect
  end
end
