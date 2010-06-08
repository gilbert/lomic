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
    public :define_method, :remove_method
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
  
  def self.resource(symbols)
    class_eval "@@inits ||= {}"
    symbols.each { |name,init_val|
      self.new_resource(name,init_val)
    }
  end
  
  def self.new_resource(name,init_val)
    if init_val.instance_of? Array
      min,max,init = case init_val.size
        when 1 then [0,init_val[0],init_val[0]]
        when 2 then [init_val[0],init_val[1],init_val[1]]
        else [init_val[0],init_val[1],init_val[2]]
      end
    else
      min,max,init = [0,init_val,init_val]
    end
    self.new_var(name,init)
    self.new_var("#{name}min",min)
    self.new_var("#{name}max",max)
    
    # redefine the set method to enforce resource limits
    self.remove_method "#{name}="
    self.define_method "#{name}=" do |new_val|
      min = eval "self.#{name}min"
      max = eval "self.#{name}max"
      new_val = new_val < min ? min : (new_val > max ? max : new_val)
      
      instance_variable_set("@#{name}", new_val)
      self.class.class_eval "@@inits.delete('#{name}')"
    end
  end
end

class Globals < Lomic
  def initialize
    @rules = {}
  end
end
