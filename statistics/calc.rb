require "distribution" # Load distribution gem

module Statistics
  module Calc
    def laplace_function(x)
      return 0.5*Math.erf(x/Math.sqrt(2))
    end

    module_function :laplace_function
  
    def inv_laplace_function(y, steps = nil)
      unless steps
        steps = 1024 
        [0.12, 0.2, 0.32, 0.45, 0.47, 0.49].each do |val|
          steps <<= 1 if y.abs > val
        end
      end

      h = y.to_f/steps

      xn, tn = 0.0, 0.0
      sq2pi = Math.sqrt(2*Math::PI)
      steps.times do
        fn = sq2pi*Math.exp(xn*xn*0.5)
        tn = xn + h*fn
        fn2 = sq2pi*Math.exp(tn*tn*0.5)
        xn += 0.5*h*(fn + fn2)
      end

      return xn
    end
    
    module_function :inv_laplace_function

    def chi_square_critical(a, n)
      ::Distribution::ChiSquare.pchi2(n, a)
    end
    
    module_function :chi_square_critical

    def minimal_square_method(points)
      x_med = points.map{ |e| e.first }.reduce(:+).to_f / points.size
      y_med = points.map{ |e| e.last }.reduce(:+).to_f / points.size
      xx_med = points.map{ |e| e.first*e.first }.reduce(:+).to_f / points.size
      xy_med = points.map{ |e| e.first*e.last }.reduce(:+).to_f / points.size
      det = xx_med - x_med*x_med
      b = (xx_med*y_med - x_med*xy_med)/det
      a = (xy_med - x_med*y_med)/det
      return [a, b]
    end

    module_function :minimal_square_method

    def exponential_linnear_approximation(points)
      xx_med = points.map{ |e| e.first*e.first }.reduce(:+).to_f / points.size
      xy_med = points.map{ |e| e.first*e.last }.reduce(:+).to_f / points.size
      a = xy_med / xx_med
      return [a, 0.0]
    end

    module_function :exponential_linnear_approximation
  end
end
