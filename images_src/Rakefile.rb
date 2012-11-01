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
TMP_FILE = 'tmp'

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

task :default do 
  puts "Run: rake { all | <mpfile> }"
  puts "Available tasks: all, clean, veryclean"
end

rule( Regexp.new("^#{Regexp.escape(DEST_FOLDER)}/[\\w\\.]+\\.eps$") => 
      [lambda{ |task_name| task_name.sub("#{DEST_FOLDER}/", "") }] ) do |t|
  puts "rule #{t.name}" 
  #result_name = t.name.dup
  #result_name[result_name =~ /\.\d+/] = '_'
  sh "mv #{t.source} #{t.name}"
end

rule '.mp' => '.mp.erb' do |t|
  ERBProcessor.process(t.source, t.name)
end

rule( /^[^\/]+\.eps$/ => [lambda{ |task_name| task_name.sub(/\.eps$/, "") }]) do |t|
  File.open("#{TMP_FILE}.tex", "w") do |file|
    file << (%{
      \\input{#{PREHEADER}}
      \\DeclareGraphicsRule{*}{eps}{*}{}
      \\nofiles
      \\begin{document}
      \\thispagestyle{empty}
      \\includegraphics{#{t.source}}
      \\end{document}
    })
  end

  sh "#{LATEX} #{TMP_FILE}"
  sh "#{DVIPS} -E -o #{t.name} #{TMP_FILE}"
  rm Dir["#{TMP_FILE}.*"]
end

task :clean do
  masks = %w{
    mpx*
    *~
    *.log
    *.mpx
    *.mp
  }
  files = masks.map{ |mask| Dir[mask] }.flatten
  rm files unless files.empty?

  Dir["#{TMP_FILE}.*"].tap { |f| rm f unless f.empty?}
  
  rm_rf DEST_FOLDER if File.exists?(DEST_FOLDER)
  mkdir DEST_FOLDER
end

directory DEST_FOLDER

MPTASKS = YAML.load_file(IMAGE_LIST_YAML)

# Зависимости для mpost-картинок.
# По одной для каждого числа из beginfig

MPTASKS.each do |mptask|
  for i in 1 .. mptask['image_cnt']
    file( "#{mptask['file']}.#{i}" => (mptask['dependences'] << DEST_FOLDER << "#{mptask['file']}.mp" << "#{PREHEADER}.tex")) do
      sh "#{MPOST} #{mptask['file']}.mp"
    end
  end
end

MPTASKS.each do |mptask|
  depend = (1 .. mptask['image_cnt']).map do |i| 
    "#{DEST_FOLDER}/#{mptask['file']}.#{i}.eps" 
  end
  if mptask['erb']
    depend << "#{mptask['file']}.mp.erb"
  end 
  task mptask['file'] => depend 
end

task :gnuplot do
  file_names = ["money", "cor2", "cor_norm"]

  Task10.data_graph(DataProvider.data[8]['data'], file_names[0])
  Task10.data_cor(DataProvider.data[8]['data'], file_names[1], file_names[2])

  sh "gnuplot *.gnu"
end

task :all => [:veryclean, :gnuplot] + MPTASKS.map{ |mptask| mptask['file'] }

task :veryclean => :clean do
  files = []
  MPTASKS.each do |mptask| 
    (1 .. mptask['image_cnt']).each do |i| 
      files << "#{mptask['file']}.#{i}" 
    end
  end
  
  Dir[*files].tap { |f| rm f unless f.empty? }
end
