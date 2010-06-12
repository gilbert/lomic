class Globals < Lomic
  var :didiwin => 'No...'
end

rule 101 do |g| # g refers to globals
  event "game:test" do
    puts '[Example: simple.rb]'
    g.didiwin = 'Yes!'
    set_next "game:test2"
  end

  event "game:test2" do
    puts "Did I win? #{g.didiwin}"
  end
end
