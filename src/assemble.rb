#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require 'blankslate'

class Assembler

  # When you insert lambdas into a LazyHash they are automatically executed
  # when the value is retrieved, and the result is cached in place of the
  # original lambda value.
  class LazyHash < Hash
    alias_method :original_get, :[]
    def [](key)
      if value = original_get(key)
        if value.respond_to?(:call)
          self[key] = value.call
          original_get(key)
        else
          value
        end
      end
    end
  end

  class AssemblerDelegate < BlankSlate
    attr_reader :app, :files
    def initialize(app, files)
      @app = app
      @files = files
    end
    def timestamp
      Time.now.strftime('%Y-%m-%d %H:%M:%S')
    end
    def process(string)
      eval(string)
    end
  end

  attr_reader :app, :files, :delegate

  def self.go!
    new.write_output!
  end

  def initialize
    @app = JSON.parse(File.read('info.json'))
    @files = Dir['*'].select {|f| File.file?(f)}.
                      inject(LazyHash.new) {|h,f|
                        h[f] = lambda { read_file(f) };h
                      }
    @delegate = AssemblerDelegate.new(@app, @files)
  end
  
  def read_file(f)
    if f[-3,3] == '.el'
      File.read(f)
    else
      File.readlines(f).map{|l| ";; #{l}"}.join
    end
  end
  
  def write_output!
    output = File.read(app['template']).
                  gsub(/#\{[^}]+\}/) {|m| @delegate.process(m[2..-2])}
    File.open(app['filename'], 'w') {|f| f.puts(output)}
  end
  
end

if __FILE__ == $0
  begin
    Assembler.go!
    puts "XD"
  rescue RuntimeError => e
    puts e.inspect
    puts ":("
  end
end