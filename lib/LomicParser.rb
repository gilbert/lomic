class LomicParser
  
  def initialize
    # points to the Rule that is currently being parsed
    @currentRule = nil
    # The entire state of the game
    @state = GameState.new
  end
  
  def rule(number)
    # TODO: ensure number is int
    @currentRule = Rule.new(number)
    yield
  ensure
    @state.addRule(@currentRule)
    @currentRule = nil
  end
  
  def event(event_name, options={}, &block)
    @currentRule.event(event_name, options, &block)
  end
  
  def game_state
    @state
  end
  
  def self.load_source(filename)
    dsl = new
    dsl.instance_eval(File.read(filename),filename)
    dsl.game_state
  end
end