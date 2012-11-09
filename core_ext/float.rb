class Float
  # Use russian locale
  alias :to_s_old :to_s
  
  def to_s
    to_s_old.gsub(".", "{,}")
  end
end
