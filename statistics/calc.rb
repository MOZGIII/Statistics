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

    def gamma(arg)
      p = [  1.000000000190015,
            76.18009172947146,
          -86.50532032941677,
            24.01409824083091,
            -1.231739572450155,
            1.208650973866179e-3,
            -5.395239384953e-6 ]
      sum = p[0] + p[1..-1].inject([0, 1]) do |res, coef|
        [res.first + coef/(arg + res.last), res.last + 1]
      end.first
    
      Math.sqrt(2*Math::PI)/arg * sum * (arg + 5.5)**(arg + 0.5) * Math.exp(-(arg + 5.5))
    end

    module_function :gamma

    def chi_square(x, n, steps = nil)
      unless steps
        steps = 1 << 12 
      end

      h = x.to_f/steps
      
      xn, yn = 0.0, 0.0
      constant = 1.0 / (gamma(0.5*n) * 2.0**(0.5*n))
      power = 0.5*n - 1.0
      half_step = 0.5*h
      steps.times do
        fn = constant * xn**power * Math.exp(-0.5*xn)
        xn += h
        fn2 = constant * xn**power * Math.exp(-0.5*xn)
        yn += half_step*(fn + fn2)
      end

      return yn
    end

    module_function :chi_square

    def inv_chi_square(y, n, steps = nil)
      unless steps
        steps = 1 << 16
      end

      h = (y.to_f - chi_square(n, n))/steps
      
      xn, tn = n.to_f, 0.0
      constant = gamma(0.5*n) * 2.0**(0.5*n)
      power = 1.0 - 0.5*n
      half_step = 0.5*h
      steps.times do
        fn = constant * xn**power * Math.exp(0.5*xn)
        tn = xn + h*fn
        fn2 = constant * tn**power * Math.exp(0.5*tn)
        xn += half_step*(fn + fn2)    
      end

      return xn
    end
    
    module_function :inv_chi_square

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
