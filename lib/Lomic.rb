$:.push File.expand_path(File.dirname(__FILE__) + '/lib')
require 'lomic/Event'
require 'lomic/EventEngine'
require 'lomic/GameState'
require 'lomic/Lomic'
require 'lomic/Rule'
require 'lomic/LomicParser'

module Lomic
  VERSION = '0.0.1'
  
  def self.parse(filename, start_event="game:start")
    gstate = LomicParser.load_source(filename)
    gstate.emit start_event
  end
end
