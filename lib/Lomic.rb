### This class helps clean up in-game class definitions
class Lomic
  class << self
    public :define_method, :remove_method
  end
  
  def self.var(symbols)
    if symbols.instance_of? Symbol
      self.new_var({symbols.to_sym => nil})
    else
      symbols.each { |name,init_val|
        self.new_var(name => init_val)
      }
    end
  end
  
  def self.new_var(symbol)
    name = symbol.keys[0]
    init_val = symbol[name]
    
    self.define_method name do
      getter = "@#{name}"
      getter += '?' if init_val.instance_of? TrueClass or init_val.instance_of? FalseClass
      val = instance_variable_get getter
      
      if val.nil? and @init_used[name].nil?
        inits = self.class.class_eval "@@__#{className}_inits__"
        val = inits[name]
        instance_variable_set("@#{name}", val)
        @init_used[name] = true
      end
      
      return val
    end
    
    self.define_method "#{name}=" do |new_val|
      instance_variable_set("@#{name}", new_val)
      @init_used[name] = true
    end

    class_eval "@@__#{self.className}_inits__ ||= {}"
    inits = class_eval "@@__#{self.className}_inits__"
    inits[name] = init_val
  end
  
  def self.resource(symbols)
    symbols.each { |name,init_val|
      self.new_resource(name => init_val)
    }
  end
  
  def self.new_resource(symbol)
    name = symbol.keys[0]
    init_val = symbol[name]
    
    if init_val.instance_of? Array
      min,max,init = case init_val.size
        when 1 then [0,init_val[0],init_val[0]]
        when 2 then [init_val[0],init_val[1],init_val[1]]
        else [init_val[0],init_val[1],init_val[2]]
      end
    else
      min,max,init = [0,init_val,init_val]
    end
    self.new_var(name => init)
    self.new_var("#{name}min" => min)
    self.new_var("#{name}max" => max)
    
    # redefine the set method to enforce resource limits
    self.remove_method "#{name}="
    self.define_method "#{name}=" do |new_val|
      min = instance_variable_get "@#{name}min"
      max = instance_variable_get "@#{name}max"
      new_val = new_val < min ? min : (new_val > max ? max : new_val)
      
      instance_variable_set("@#{name}", new_val)
    end
  end
  
  def initialize
    @init_used = {}
    inits = self.class.class_eval "@@__#{className}_inits__"
    inits.each do |var,val|
      instance_variable_set "@#{var}", val
      @init_used[var] = true
    end
  end
  
  def self.className
    if self.name.include? '::'
      self.name.split('::')[1]
    else
      self.name
    end
  end
  
  def className
    self.class.className
  end
end
