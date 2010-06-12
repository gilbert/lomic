module Lomic
  
class LomicParser
  
  def initialize
    # points to the Rule that is currently being parsed
    @currentRule = nil
    # The entire state of the game
    @state = GameState.new
    @first_rule = true
  end
  
  def rule(number)
    # TODO: ensure number is int
    @currentRule = Rule.new(number)
    if @first_rule
      @state.globals = instance_eval 'Globals.new'
      @first_rule = false
    end
    
    yield @state.globals
  ensure
    @state.addRule(@currentRule)
    @currentRule = nil
  end
  
  def event(event_name, options={}, &block)
    @currentRule.event(event_name, options, &block)
  end
  
  def gamestate
    @state
  end
  
  def self.load_source(filename)
    dsl = new
    dsl.instance_eval(File.read(filename),filename)
    # dsl.gamestate.globals = (dsl.instance_eval 'Globals.new')
    dsl.gamestate
  end
end

end # module
