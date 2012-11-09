#!/usr/bin/env rake
# coding: utf-8
Encoding.default_external = "UTF-8"
Encoding.default_internal = "UTF-8"

$: << "." # fix load paths

require "yaml"
require "erb_processor"
require "data_provider"
require "latex_helper"
require "statistics/calc"
require "statistics/sample"
require "statistics/distribution"

TEX_DIR = "tex"
RESULT = "term_paper.pdf"

# Load data
DataProvider.global = YAML.load_file("data/global.yml")
DataProvider.data = YAML.load_file("data/#{DataProvider.global["variant"]}.yml")

# Extend sandbox with helpers
ERBProcessor.add_module DataProvider
ERBProcessor.add_module LatexHelper
ERBProcessor.add_module Statistics

task :default => [:termpaper]

task :help do
  puts "If you want build term paper, type: rake termpaper"
  puts "If you want look at this help, type: rake help"
end

task :images do
  Dir.chdir("images_src") do
    sh "rake veryclean"
    sh "rake all"
    sh "rake veryclean"
  end
end

task :process_files do
  Dir["#{TEX_DIR}/*"].sort.each do |filename|
    if filename =~ /\.erb\z/
      puts "Processing #{filename}"
      begin
        ERBProcessor.process filename, "tmp/#{File.basename(filename).sub(/\.erb\z/, "")}"
      rescue
        puts " ...failed"
      end
    else
      cp filename, "tmp"
    end
  end
end

task :termpaper => [:clean, :process_files, :images] do
  Dir.chdir "tmp" do
    3.times do
      sh "latex main.tex"
    end
    sh "dvips -o main.ps main.dvi"
    sh "ps2pdf main.ps"
  end
  mv "tmp/main.pdf", RESULT
end

task :clean do
  masks = %w{
    *~
    *.log
    *.aux
    *.toc
    *.out
    *.pdf
    *.ps
    *.dvi
    *.tmp
  }
  files = masks.map{ |mask| Dir[mask] }.flatten
  rm files unless files.empty?

  all_files = Dir["*"]
  all_files.each do |file|
    rm file if all_files.include?("#{file}.erb")
  end
  
  rm_rf "tmp"
  mkdir "tmp"
end

