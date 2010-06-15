module Lomic

class EventEngine
  
  def initialize
    @stack = []
    @counter = 0 # the number of event code blocks executed
  end
  
  def run(event_name, rules, socket)
    @socket = socket
    add_sort_events rules
    @next_event = event_name

    begin
      event_name = @next_event
      @next_event = nil
      for event in @events[event_name]
        # event code blocks can set @next_event through set_next
        instance_eval &event.block
      end
    end while @next_event.nil? == false
  end
  
  def listen(*valid_events)
    puts "Listening for valid events: #{valid_events.inspect}" if Lomic.verbose?
    res = @socket.gets.strip!
    if not valid_events.include? res
      result = {:status => 'fail', :reason => 'invalid event'}.to_json
      @socket.puts result
    else
      result = {:status => 'ok'}.to_json
      @socket.puts result
    end
    set_next res
  end
  
  def set_next(event_name)
    @next_event = event_name
  end
  
  def next_event
    @next_event
  end
  
  def counter
    @counter
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
          i = 0
          arr.each do |arr_e|
            if e.priority > arr_e.priority
              arr.insert(i,e)
              break
            elsif i == arr.size-1
              arr.insert(i+1,e)
              break
            end
            i += 1
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

end # module
