
rule 101 do |g|
  event "game:start" do
    puts 'Game starting'
    listen 'path:left', 'path:right'
  end
  
  event "path:left" do
    puts 'Took the LEFT path!'
  end
  
  event "path:right" do
    puts 'Took the RIGHT path!'
  end
end