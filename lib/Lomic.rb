class LomicParser
  
  def initialize
    @globals = Globals.new
  end
  
  def rule(number)
    # TODO: ensure number is int
    @rule = Rule.new(number)
    yield @rule
  ensure
    @rules.add(@rule)
  end
  
  def self.load_source(filename)
    dsl = new
    dsl.instance_eval(File.read(filename),filename)
    dsl
  end
end

class Rule
  def initialize(number)
    @number = number
  end
end

### This class helps clean up class definitions
class Lomic
  class << self
    public :define_method
  end
  
  def self.var(symbols)
    class_eval "@@inits ||= {}"
    symbols.each { |name,init_val|
      self.new_var(name,init_val)
    }
  end
  
  def self.new_var(name,init_val=nil)
    self.define_method name do
      @val = instance_variable_get "@#{name}"
      if @val.nil? && (self.class.class_eval "@@inits['#{name}'].nil?") == false
        @val = self.class.class_eval "@@inits['#{name}']"
        instance_variable_set("@#{name}", @val)
        self.class.class_eval "@@inits.delete('#{name}')"
        return @val
      end
      return @val
    end
    
    self.define_method "#{name}=" do |new_val|
      instance_variable_set("@#{name}", new_val)
      self.class.class_eval "@@inits.delete('#{name}')"
    end
    class_eval "@@inits['#{name}'] = #{init_val}"
  end
  
  # TODO: resource
  #def resource
end

class Globals < Lomic
  def initialize
    @rules = {}
  end
end
