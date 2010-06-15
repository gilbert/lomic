class Player < LomicBase
  var :number
end

# global data: all lomic functions search exclusively in this class for global variables
class Globals < LomicBase
  var :currentRule # Rule is a built-in class type
  var :ruleChangeType =>  ""

  var :players => []
  var :currentPlayer
  
  var :num => 99

  var :turnCounter => 0, :ruleCounter => 301
  
  var :playersVoted => Set.new
  var :votesUnanimous => false # since this is a boolean, it's accessed with: votesUnanimous?
end

# Rules

# Rules recieve events in the order of their priority *for that event* (standard is 5)
# If two rules have the same priority, the lowest rule number goes first

# A failed cond will cause the rule to ignore the event
# A failed assert will cause the rule to kill the event entirely and
#   set the next event to "assert:fail" with failed_event containing
#   the name of the failed event

# Both cond and assert failures will cause the rule to stop executing.

rule 102 do |g|
  ### Initially the rules in the 100's are immutable and rules in
  ### the 200's are mutable. Rules subsequently enacted or transmuted
  ### (that is, changed from immutable to mutable or vice versa) may be
  ### immutable or mutable regardless of their numbers, and rules in the
  ### Initial Set may be transmuted regardless of their numbers
  event "game:start" do
    # create a new accessible variable in the Rule class initialized to false
    Rule.new_var :immutable => false
    # rules is a reserved global array
    g.rules.each do |r|
      r.immutable = true if r.number >= 100 and r.number < 200
    end
  end

  event "rule:change", :priority => 1 do
    cond g.ruleChangeType == "transmute"
    assert g.currentRule.immutable == false
  end
end

rule 103 do |g|
  ### A rule change is any of the following:
  ### (1) the enactment, repeal, or amendment of a mutable rule;
  ### (2) the enactment, repeal, or amendment of an amendment of a mutable rule;
  ### or (3) the transmutation of an immutable rule into a mutable rule or vice versa.
  event "rule:change" do
    assert g.ruleChangeType.isEither ["repeal","amendment","transmute"]
  end
end

rule 104 do |g|
  ### All rule-changes proposed in the proper way shall be voted on.
  event "rule:change" do
    set_next "players:vote"
  end
  
  ### They will be adopted if and only if they receive the required number of votes.  
  event "rule:voted" do
    set_next "vote:unanimous?"
  end
end

rule 105 do |g|
  ### Every player is an eligible voter.
  event "game:start" do
    Player.new_var 'voter' => true
    Player.new_var 'votedYes' => false
  end

  ### Every eligible voter must participate in every vote on rule-changes.
  event "players:vote" do
    # This will send JSON data over the network to the external manager
    # that is managing this instance of Lomic
    send "request:votes"
    # This will listen for a message from the external manager and treat it an event
    listen "player:vote"
  end
  
  event "player:vote" do
    # start listening before the assertions in case one of them fails
    # listening, like next_event, takes place after the code block is done executing
    listen "player:vote"
    
    assert g.currentPlayer.voter? == true
    assert g.playersVoted.include? currentPlayer == false
    playersVoted.add(currentPlayer)

    allVoted = true
    g.players.each do |p|
      allVoted = false if p.voter? and g.playersVoted.include? p == false
    end
    
    if allVoted
      listen :cancel # necessary because listening has higher priority over next_event
      set_next "rule:voted"
    end
  end
end

rule 108 do |g|
  ### Each proposed rule-change shall be given a number for reference.
  ### The numbers shall begin with 301, and each rule-change proposed
  ### in the proper way shall receive the next successive integer,
  ### whether or not the proposal is adopted.
  event "rule:passed" do
    # store global data
    # modify source code for rule currentRule.number
    # reload source code
    # reload global data
    # set_next "rule:complete" on load
  end
end

rule 201 do |g|
  ### Players shall alternate in clockwise order, taking one whole turn apiece.
  ### Turns may not be skipped or passed, and parts of turns may not be omitted.
  ### All players begin with zero points.
  event "game:start" do
    Player.new_var 'points', 0
    g.turnCounter = 0
    g.currentPlayer = players[0]
    set_next "turn:start"
  end

  event "turn:end" do
    g.turnCounter += 1
    g.currentPlayer = g.players[g.turnCounter % g.players.size]
    set_next "turn:start"
  end
end

rule 202 do |g|
  ### One turn consists of two parts in this order:
  ### (1) proposing one rule-change and having it voted on, and
  event "turn:start" do
    # prompt external manager for action
    send :event => "request:action", :player => g.currentPlayer.number
    g.ruleChangeType = listen "response:action"
    
    set_next "rule:change"
  end

  ### (2) throwing one die once and adding the number of points on its face to one's score.
  event "rule:complete" do
    set_next "player:dice roll"
  end

  event "player:dice roll" do
    g.currentPlayer.points += ran(6)
  end
end

rule 203 do |g|
  ### A rule-change is adopted if and only if the vote is unanimous among the eligible voters.
  event "vote:unanimous?" do
    g.votesUnanimous = true
    g.votedPlayers.each { |p| g.votesUnanimous = false if p.votedYes? == false }
    assert g.votesUnanimous?
  end
end

rule 208 do |g|
  ### The winner is the first player to achieve 100 (positive) points.
  event "player:dice roll", :priority => 1 do
    if g.currentPlayer.points >= 100
      set_next "player:win by points"
    else
      set_next "turn:end"
    end
  end
end
