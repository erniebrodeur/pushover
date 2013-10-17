class Hash
  def first_pair
    self.each do |k,v|
    	return {k => v}
    end
  end
end
