class Globals < Lomic
  var :number => 100
end

rule 101 do |g| # g refers to globals
  event "game:test" do
    puts '[Example: priority.rb]'
    g.number = 99
    set_next "route:right"
  end

  # A lower priority number means it runs closer to the end.
  # The default priority is 5, thus this event block
  # runs last, having the last effect on set_next and g.number
  event "game:test", :priority => 1 do
    g.number = 77
    set_next "route:left"
  end
  
  event "game:test" do
    g.number = 55
    set_next "route:right"
  end
  
  event "route:left" do
    puts "The number is: #{g.number}"
    puts "You went left!"
  end
  
  event "route:right" do
    puts "The number is: #{g.number}"
    puts "You went right!"
  end
end

