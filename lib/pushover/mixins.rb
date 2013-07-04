class Hash
  def first
    self.each do |k,v|
    	return {k => v}
    end
  end
end
