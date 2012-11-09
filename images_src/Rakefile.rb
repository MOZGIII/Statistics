#!/usr/bin/env rake
# coding: utf-8
Encoding.default_external = "UTF-8"
Encoding.default_internal = "UTF-8"

$: << "." # fix load paths

require "yaml"

# Hop to upper dir for config
Dir.chdir ".." do
  require "erb_processor"
  require "data_provider"
  require "latex_helper"
  require "statistics/calc"
  require "statistics/sample"
  require "statistics/distribution"

  # Load data
  DataProvider.global = YAML.load_file("data/global.yml")
  DataProvider.data = YAML.load_file("data/#{DataProvider.global["variant"]}.yml")
  
  # Extend sandbox with helpers
  ERBProcessor.add_module DataProvider
  ERBProcessor.add_module LatexHelper
  ERBProcessor.add_module Statistics
end

require 'task10'

# yaml-файл с описанием mp-файлов картинок
#
# содержит массив хэшей следующего вида: 
# {file: <имя_mp_файла>, image_cnt: <кол-во_изображений>, dependences: [<файл1>, <файл2>, ...]}
#   
#  Например файл <make.lst.yml> :
#  >  ---
#  >    - {file: "sorternet", image_cnt: 23, dependences: ["sndefs.mp"]}
#  >    - {file: "funcelem",  image_cnt: 2,  dependences: ["funcelemdefs.mp"]}
#  >
IMAGE_LIST_YAML = 'make.lst.yml'

# имя временного файла для создания иллюстаций
TMP_FILE = 'st'

# файл latex заголовка, в нем указаны используемые пакеты
#   Например файл <preheader.tex> :
#   >  \documentclass[12pt]{amsart}
#   >  \usepackage{anysize,amssymb,amsthm,verbatim,epsfig,graphics,longtable}
#   >  \usepackage[unicode]{hyperref}
#   >  \endinput
#   >
PREHEADER = 'preheader'

# папка куда будут складываться сгенерированные картинки
DEST_FOLDER = '../tmp/images'

# программы
LATEX = 'latex -interaction=nonstopmode'
MPOST = 'mpost -interaction=nonstopmode --tex=latex'
DVIPS = 'dvips'
EPSTOOL = 'epstool'

task :default do 
  puts "Run: rake { all | <mpfile> }"
  puts "Available tasks: all, clean, veryclean"
end

task :clean do
  masks = %w{
    mpx*
    *~
    *.log
    *.mpx
    *.mp
    *.dat
    *.gnu
  }
  files = masks.map{ |mask| Dir[mask] }.flatten
  rm files unless files.empty?

  # Dir["#{TMP_FILE}.*"].tap { |f| rm f unless f.empty?}
end

task :init_dirs do
  rm_rf DEST_FOLDER if File.exists?(DEST_FOLDER)
  mkdir DEST_FOLDER
end

MPTASKS = YAML.load_file(IMAGE_LIST_YAML)

task :metapost do
  MPTASKS.each do |mptask|
    if File.exists?("#{mptask['file']}.mp.erb")
      puts "Processing #{mptask['file']}.mp.erb"
      begin
        ERBProcessor.process("#{mptask['file']}.mp.erb", "#{mptask['file']}.mp")
      rescue
        puts " ...failed"
      end
    end
    
    sh "#{MPOST} #{mptask['file']}.mp"
    (1 .. mptask['image_cnt']).each do |i|
      filename = "#{mptask['file']}-#{i}"
      
      File.open("#{filename}.tex", "w") do |file|
      # \\DeclareGraphicsRule{*}{eps}{*}{}
        file << (%{
          \\input{#{PREHEADER}}
          \\nofiles
          \\begin{document}
          \\thispagestyle{empty}
          \\includegraphics{#{filename}.mps}
          \\end{document}
        })
      end
      
      sh "#{LATEX} #{filename}"
      sh "#{DVIPS} -o #{filename}.ps #{filename}"
      sh "ps2eps --ignoreBB #{filename}.ps"

=begin
      sh "pdfcrop #{filename}.pdf"
      sh "pdftops -f 1 -l 1 -eps #{filename}-crop.pdf" 
      rm "#{filename}-crop.pdf"
      sh "mv #{filename}-crop.eps #{filename}.eps"
=end
      sh "mv #{filename}.eps #{DEST_FOLDER}"

    end
  end
end

task :gnuplot do
  file_names = ["money", "cor2", "cor_norm"]

  Task10.data_graph(DataProvider.global['task10data'], file_names[0])
  Task10.data_cor(DataProvider.global['task10data'], file_names[1], file_names[2])

  sh "gnuplot *.gnu"
end

task :all => [:init_dirs, :gnuplot, :metapost]

task :veryclean => [:clean] do
  files = []
  MPTASKS.each do |mptask|
    files += Dir["#{mptask['file']}.*"]
    (1 .. mptask['image_cnt']).each do |i| 
      files += Dir["#{mptask['file']}-#{i}.*"]
    end
    files -= ["#{mptask['file']}.mp.erb"]
  end
  
  Dir[*files].tap { |f| rm f unless f.empty? }
end
