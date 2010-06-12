require './lib/Event'
require './lib/EventEngine'
require './lib/GameState'
require './lib/Lomic'
require './lib/Rule'
require './lib/LomicParser'

gstate = LomicParser.load_source(ARGV.shift) # put the DSL filename on the command line
gstate.emit "game:test"
