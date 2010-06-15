$:.push File.expand_path(File.dirname(__FILE__) + '/lib')
require 'lomic/Event'
require 'lomic/EventEngine'
require 'lomic/GameState'
require 'lomic/LomicBase'
require 'lomic/Rule'
require 'lomic/LomicParser'

module Lomic
  @@verbose = false
  require 'json'
  
  def self.new_game(socket,filename)
    gstate = LomicParser.load_source(filename)
    puts 'Waiting for response from server...'
    first_event = socket.gets.strip!
    puts "Received first event: #{first_event}" if verbose?
    gstate.run(first_event,socket)
  end
  
  def self.verbose?
    @@verbose
  end
  
  def self.verbose=(new_val)
    @@verbose = new_val
  end
end
