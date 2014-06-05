class Array
  def average
    sum / size.to_f
  end
  
  def sum
    inject(0,:+)
  end
end
