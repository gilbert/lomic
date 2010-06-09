require './lib/Globals.rb'
require './lib/Rule.rb'
require './lib/Lomic'

my_dsl = LomicParser.load_source(ARGV.shift) # put the DSL filename on the command line
p my_dsl
p my_dsl.instance_variables
