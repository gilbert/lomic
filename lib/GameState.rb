require 'Set'

class GameState
  def initialize
    @globals = Globals.new
    @rules = []
    @em = EventEngine.new
  end
  
  def addRule(rule)
    @rules.push(rule)
  end
  
  def emit(event_name)
    @em.run(event_name)
  end
end
