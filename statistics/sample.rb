module Statistics
  class Sample
    attr_reader :data
    attr_accessor :hist_step, :hist_start
 
    @@global_steps = 6

    def initialize(data)
      @data = data.dup
      @hist_step = (@data.max - @data.min).to_f/@@global_steps
      @hist_start = @data.min
    end

    def mean
      @data.reduce(:+).to_f/@data.size
    end

    alias :m :mean

    def variance
      val_mean = mean
      squares_sum/@data.size - val_mean*val_mean
    end

    alias :S2 :variance

    def deviation
      Math.sqrt(variance)
    end

    alias :S :deviation

    def corrected_variance
      val_mean = mean
      (squares_sum - val_mean*val_mean*@data.size)/(@data.size - 1)
    end

    alias :S2_star :corrected_variance

    def corrected_deviation
      Math.sqrt(corrected_variance)
    end

    alias :S_star :corrected_deviation

    def exponential_distribution?
      return false if @data.min < 0.0
      return distribution.kind_of?(Statistic::Exponential)
    end

    alias :exp_dist? :exponential_distribution?

    def grouping
      h = Hash.new

      x = hist_start
      last = @data.max

      while x <= last
        h[x] = @data.select do |val|
          val >= x and val < (x + hist_step) 
        end.size
        x += hist_step
      end

      return h
    end

    alias :m_j :grouping

    def histogram
      h = Hash.new

      grouping.each do |key, val|
        h[key] = val.to_f / @data.size / hist_step
      end

      return h
    end

    alias :hist :histogram

    def frequencies
      h = Hash.new

      grouping.each do |key, val|
        h[key] = val.to_f / @data.size
      end

      return h
    end

    def distribution
      types = [ Uniform::new(self), 
                Normal::new(self), 
                Exponential::new(self) ]
      diff = types.map { |dist| dist.approx_diff }
      types[diff.index(diff.min)]
    end

    def ranks
      s = Array.new
      r = Array.new
      
      @data.each_with_index do |val, i|
        s << [val, i]
      end
      
      s.sort_by{ |a| a.first }.each_with_index do |a, i|
        r[a.last] = i + 1
      end
      
      return r
    end
    
    def ranks_sample
      Sample.new(ranks)
    end

    def to_s
      "Sample(#{@data.join(", ")})"
    end

    def method_missing(name, *args) 
      @data.send(name, *args)
    end

    private

    def squares_sum
      @data.map{ |val| val*val }.reduce(:+).to_f
    end

  end
end