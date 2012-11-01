module DataProvider
  module Memory
    def self.data
      @data ||= {}
    end
  end

  def global
    Memory.data[:global]
  end
    
  def data
    Memory.data[:data]
  end
  
  def self.global
    Memory.data[:global]
  end
    
  def self.data
    Memory.data[:data]
  end
  
  def self.global=(value)
    Memory.data[:global] = value
  end
  
  def self.data=(value)
    Memory.data[:data] = value
  end
end
