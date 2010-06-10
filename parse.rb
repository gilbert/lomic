require './lib/Event'
require './lib/Globals'
require './lib/Rule'
require './lib/EventEngine'
require './lib/GameState'
require './lib/Lomic'
require './lib/LomicParser'

gstate = LomicParser.load_source(ARGV.shift) # put the DSL filename on the command line
p gstate.inspect
p gstate.instance_variables
