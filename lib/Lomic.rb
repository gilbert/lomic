require 'Set'

class LomicParser
  
  def initialize
    @currentRule = nil
    @globals = Globals.new
    @rules = []
  end
  
  def rule(number)
    # TODO: ensure number is int
    @currentRule = Rule.new(number)
    yield
  ensure
    @rules.push(@currentRule)
    @currentRule = nil
  end
  
  def event(event_name, options={}, &block)
    @currentRule.event(event_name, options, &block)
  end
  
  def self.load_source(filename)
    dsl = new
    dsl.instance_eval(File.read(filename),filename)
    dsl
  end
end

### This class helps clean up class definitions
class Lomic
  class << self
    public :define_method, :remove_method
  end
  
  def self.var(symbols)
    class_eval "@@inits ||= {}"
    if symbols.instance_of? Symbol
      self.new_var(symbols)
    else
      symbols.each { |name,init_val|
        self.new_var({:name => name, :init_val => init_val})
      }
    end
  end
  
  def self.new_var(symbol)
    name = symbol[:name]
    init_val = symbol[:init_val]
    
    self.define_method name do
      getter = "@#{name}"
      getter += '?' if init_val.instance_of? TrueClass or init_val.instance_of? FalseClass
      val = instance_variable_get getter
      
      if val.nil? && (self.class.class_eval "@@inits['#{name}'].nil?") == false
        val = self.class.class_eval "@@inits['#{name}']"
        instance_variable_set("@#{name}", @val)
        self.class.class_eval "@@inits.delete('#{name}')"
      end
      return val
    end
    
    self.define_method "#{name}=" do |new_val|
      instance_variable_set("@#{name}", new_val)
      self.class.class_eval "@@inits.delete('#{name}')"
    end
    class_eval do
      inits = class_eval '@@inits'
      inits[name] = init_val
    end
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
