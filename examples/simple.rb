class Globals < LomicBase
  var :didiwin => 'No...'
end

rule 101 do |g| # g refers to globals
  event "game:start" do
    puts '[Example: simple.rb]'
    g.didiwin = 'Yes!'
    set_next "game:test1"
  end

  event "game:test1" do
    puts "Did I win? #{g.didiwin}"
  end
end
