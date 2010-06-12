module Lomic

class Event
  attr_accessor :name, :priority, :rule_number
  attr_accessor :block
  
  def initialize(attrs)
    attrs.each {|key,val| instance_variable_set "@#{key}", val }
  end
end

end # module
