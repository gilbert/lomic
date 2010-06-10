class EventEngine
  
  def initialize
    @stack = []
  end
  
  def run(event_name, rules)
    add_sort_events rules
    for event in @events[event_name]
      # TODO: run the simulation
    end
  end
  
  private
  
  def add_sort_events(rules)
    # "event_name" => [Event]
    @events = {}
    rules.each do |r|
      r.event_bag.each do |name, event_arr|
        for e in event_arr do
          if @events[name].nil?
            @events[name] = [e]
            next
          end
          # insert into sorted spot
          arr = @events[name]
          for i in (0...arr.size-1)
            if e.priority > arr[i].priority
              arr.insert(i,@event)
              break
            elsif i == arr.size-1
              arr.insert(i+1,@event)
            end
          end
        end
      end
    end
  end
  
  def push(event)
    # pushes a state onto the stack
    state = {
      :event_name => event.name,
      :priority => event.priority,
      :rule_number => event.rule_number
    }
    @stack.push(state)
  end
  
end