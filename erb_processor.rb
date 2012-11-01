#!/usr/bin/env ruby

require "erb"

module ERBProcessor
  module Sandbox
  end

  def self.process(src, dest)
    template = ERB.new(File.read(src))
    
    File.open(dest, "w") do |f|
      f << template.result(fetch_sandbox_binding)
    end
  end
  
  def self.add_module(module_const)
    Sandbox.extend module_const
  end
  
  private
  
  def self.fetch_sandbox_binding
    Sandbox.instance_eval do
      binding
    end
  end
end

if __FILE__ == $0
  ERBProcessor.process(ARGV[0], ARGV[1])
end
