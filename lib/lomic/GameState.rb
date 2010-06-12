module Lomic

require 'Set'

class GameState
  def initialize
    super
    @globals
    @rules = []
    @em = EventEngine.new
  end
  
  def globals
    @globals
  end
  
  def globals=(globals_obj)
    return if @globals.nil? == false
    @globals = globals_obj
    klass = @globals.class
    
    klass.new_var :rules => []
    @globals.rules = @rules
  end
  
  def addRule(rule)
    @rules.push(rule)
  end
  
  def emit(event_name)
    @em.run(event_name,@globals.rules)
  end
end

end # module
