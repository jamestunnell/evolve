class Array
  def average
    inject(0,:+) / size.to_f
  end
end
