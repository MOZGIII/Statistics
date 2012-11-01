module Task10

  def self.temp_dir
    "."
  end

  def self.data_graph(data, file_name)
    File.open("#{temp_dir}/#{file_name}.dat", "w") do |f|
      for i in 0...data.size
        f.puts "#{i+1} #{data[i]}"
      end
    end
    
    m = data.inject(0){|sum,n| sum += n}/data.size
    
    File.open("#{temp_dir}/#{file_name}.gnu", "w") do |g|
      g.puts "reset"
      g.puts "set key off"
      g.puts "set xrange [0:10]"
      g.puts "set xtics 0, 1"
      g.puts "set terminal postscript eps"
      g.puts "set output \"#{DEST_FOLDER}/#{file_name}.eps\""
      #g.puts "set terminal png giant size 480,360"
      #g.puts "set output \"#{"img/"+file_name+".png"}\""
      g.puts "plot \"#{file_name+".dat"}\" with linespoints lc -1 pt 7,\
          #{m} lc -1"
    end
  end

  def self.data_cor(data, file_name1, file_name2)
    m = data.inject(0){|sum,n| sum += n}/data.size
    a = Array.new
    
    File.open("#{temp_dir}/#{file_name1}.dat", "w") do |f|
      for l in 0...data.size
        sum = 0
        for i in 0...data.size-l
          sum += (data[i]-m)*(data[i+l]-m)
        end
        f.puts "#{l} #{sum/(data.size-l)}"
        a << sum/(data.size-l)
      end
    end
    
    File.open("#{temp_dir}/#{file_name1}.gnu", "w") do |g|
      g.puts "reset"
      g.puts "set key off"
      g.puts "set zeroaxis ls -1"
      g.puts "set xtics axis"
      g.puts "set xrange [0:9]"
      g.puts "set xtics 0, 1"
      g.puts "set format y \"%.0f\""
      g.puts "set terminal postscript eps"
      g.puts "set output \"#{DEST_FOLDER}/#{file_name1}.eps\""
      #g.puts "set terminal png giant size 480,360"
      #g.puts "set output \"#{"img/"+file_name1+".png"}\""
      g.puts "plot \"#{file_name1+".dat"}\" with linespoints lc -1 pt 7"
    end
    
    File.open("#{temp_dir}/#{file_name2}.dat", "w") do |f|
      for l in 0...data.size
        f.puts "#{l} #{a[l]/a[0].to_f}"
      end
    end
    
    File.open("#{temp_dir}/#{file_name2}.gnu", "w") do |g|
      g.puts "reset"
      g.puts "set key off"
      g.puts "set zeroaxis ls -1"
      g.puts "set xtics axis"
      g.puts "set xrange [0:9]"
      g.puts "set xtics 0, 1"
      g.puts "set terminal postscript eps"
      g.puts "set output \"#{DEST_FOLDER}/#{file_name2}.eps\""
      #g.puts "set terminal png giant size 480,360"
      #g.puts "set output \"#{"img/"+file_name2+".png"}\""
      g.puts "plot \"#{file_name2+".dat"}\" with linespoints lc -1 pt 7"
    end
  end
  
end
