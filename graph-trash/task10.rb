def data_graph(data, file_name)
  f = File.new("graph/data/"+file_name+".dat", "w")
  for i in 0...data.size
    f.puts "#{i+1} #{data[i]}"
  end
  f.close
  
  m = data.inject(0){|sum,n| sum += n}/data.size
  
  g = File.new("graph/"+file_name+".gnu", "w")
  g.puts "reset"
  g.puts "set key off"
  g.puts "set xrange [0:10]"
  g.puts "set xtics 0, 1"
  g.puts "set terminal postscript eps"
  g.puts "set output \"#{"img/"+file_name+".eps"}\""
  #g.puts "set terminal png giant size 480,360"
  #g.puts "set output \"#{"img/"+file_name+".png"}\""
  g.puts "plot \"#{"data/"+file_name+".dat"}\" with linespoints lc -1 pt 7,\
      #{m} lc -1"
  g.close
end

def data_cor(data, file_name1, file_name2)
  m = data.inject(0){|sum,n| sum += n}/data.size
  a = Array.new
  
  f = File.new("graph/data/"+file_name1+".dat", "w")
  for l in 0...data.size
    sum = 0
    for i in 0...data.size-l
      sum += (data[i]-m)*(data[i+l]-m)
    end
    f.puts "#{l} #{sum/(data.size-l)}"
    a << sum/(data.size-l)
  end
  f.close
  
  g = File.new("graph/"+file_name1+".gnu", "w")
  g.puts "reset"
  g.puts "set key off"
  g.puts "set zeroaxis ls -1"
  g.puts "set xtics axis"
  g.puts "set xrange [0:9]"
  g.puts "set xtics 0, 1"
  g.puts "set format y \"%.0f\""
  g.puts "set terminal postscript eps"
  g.puts "set output \"#{"img/"+file_name1+".eps"}\""
  #g.puts "set terminal png giant size 480,360"
  #g.puts "set output \"#{"img/"+file_name1+".png"}\""
  g.puts "plot \"#{"data/"+file_name1+".dat"}\" with linespoints lc -1 pt 7"
  g.close
  
  
  max = a.max
  f = File.new("graph/data/"+file_name2+".dat", "w")
  for l in 0...data.size
    f.puts "#{l} #{a[l]/max}"
  end
  f.close
  
  g = File.new("graph/"+file_name2+".gnu", "w")
  g.puts "reset"
  g.puts "set key off"
  g.puts "set zeroaxis ls -1"
  g.puts "set xtics axis"
  g.puts "set xrange [0:9]"
  g.puts "set xtics 0, 1"
  g.puts "set terminal postscript eps"
  g.puts "set output \"#{"img/"+file_name2+".eps"}\""
  #g.puts "set terminal png giant size 480,360"
  #g.puts "set output \"#{"img/"+file_name2+".png"}\""
  g.puts "plot \"#{"data/"+file_name2+".dat"}\" with linespoints lc -1 pt 7"
  g.close
end

file_names = ["task10", "money", "cor2", "cor_norm"]
data = File.new("data/#{file_names[0]}.dat").readlines.map{|n| n.to_f}

data_graph(data, file_names[1])
data_cor(data, file_names[2], file_names[3])
