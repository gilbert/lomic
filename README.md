# Lomic

Lomic is a Domain Specific Language (DSL) intended to be used for Pomic, a programming version of the game Nomic.

## What does Lomic look like?

Lomic is designed to be expressive in declaring rules for the game Nomic:

    class Globals < Lomic
      var :players => []
      var :currentPlayer
    end
    
    class Player < Lomic
      resource :hp => 15 # resources have a max and min value
    end

    rule 101 do |g| # g refers to globals
      ### The game begins with 4 players.
      ### Each player is assigned a unique number.
      event "game:start" do
        Player.new_var :number => 0
        4.times do |i|
          p = Player.new
          p.number = i
          g.players.push(p)
        end
      end
    end
    
    rule 102 do |g|
      ### At the beginning of each player's turn,
      ### that player takes 3 damage
      event "turn:start" do
        currentPlayer.hp -= 3
      end
    end

## Getting Started

Download the source and run an example:

    $ git clone git://github.com/mindeavor/Lomic.git
    $ cd Lomic
    $ ruby parse.rb examples/simple.rb

Check out the `examples/` folder to see what Lomic is supposed to look like, and `parse.rb` to see how to use Lomic (in its current, underdeveloped state)

## Contributing

Lomic is currently in the concept and development stage. To discuss contributing, syntax, goals, or implementation, join us at #lomic on irc.freenode, or email me at gilbertbgarza aT gmail
