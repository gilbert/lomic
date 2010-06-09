class Rule
  def initialize(number)
    @number = number
    @event_bag = {} # event_name => [{:priority,:block}]
  end

  
  def event(event_name, options={}, &block)
    options[:priority] ||= 5
    
    @event = {:priority => options[:priority], :block => block}
    if @event_bag[event_name].nil?
      @event_bag[event_name] = [@event]
    else
      # insert into sorted spot
      arr = @event_bag[event_name]
      for i in (0...arr.size-1)
        if @event[:priority] > arr[i][:priority]
          arr.insert(i,@event)
          break
        elsif i == arr.size-1
          arr.insert(i+1,@event)
        end
      end
    end
    puts "Added event {#{event_name}} with priority #{options[:priority]}"
  end
  
  def inspect
    "Rule #{@number}: #{@event_bag.inspect}"
  end
end
