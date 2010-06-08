class Player < Lomic
  var :example => 0
  var :ex1 => 3, :ex2 => 5
end

# global data: all lomic functions search exclusively in this class for global variables
class Globals < Lomic
  var :currentRule # Rule is a built-in class type
  var :ruleChangeType =>  ""

  var :players => []
  var :currentPlayer

  var :turnCounter => 0, :ruleCounter => 301
  
  var :playersVoted => Set.new
  var :unanimous => false
end

# Rules

# Rules recieve events in the order of their priority *for that event* (standard is 5)
# If two rules have the same priority, the lowest rule number goes first

# A failed cond will cause the rule to ignore the event, passing it on to the next rule
# A failed assert will cause the rule to kill the event entirely

# both cond and assert failures will cause the rule to stop executing



rule 102 do
  ### Initially the rules in the 100's are immutable and rules in
  ### the 200's are mutable. Rules subsequently enacted or transmuted 
  ### (that is, changed from immutable to mutable or vice versa) may be
  ### immutable or mutable regardless of their numbers, and rules in the
  ### Initial Set may be transmuted regardless of their numbers
  event "game::start" do
    rules.each do |r| # rules is a reserved global array
      if r.id >= 100 and r.id < 200
        r.immutable = true
      end
    end
  end

  event "rule::change" do
    assert currentRule.immutable == false
  end
end

rule 103 do
  ### A rule change is any of the following:
  ### (1) the enactment, repeal, or amendment of a mutable rule;
  ### (2) the enactment, repeal, or amendment of an amendment of a mutable rule;
  ### or (3) the transmutation of an immutable rule into a mutable rule or vice versa.
  event "rule::change" do
    if currentRule.immutable is true
      assert ruleChangeType == "transmute"
    else
      assert ruleChangeType.isEither ["repeal","amendment"]
    end
  end
end

rule 104 do
  ### All rule-changes proposed in the proper way shall be voted on.
  ### They will be adopted if and only if they receive the required number of votes.
  event "rule::voted" do
    emit "vote:unanimous?"
    assert unanimous == true
  end
end

rule 105 do
  ### Every player is an eligible voter.
  event "turn::start" do
    players.each do |p|
      p.voter? = true
    end
  end

  ### Every eligible voter must participate in every vote on rule-changes.
  event "player::vote" do
    assert currentPlayer.voter? == true
    assert not playersVoted.include? currentPlayer
    playersVoted.add(currentPlayer)

    players.each do |p|
      if p.voter?
        cond p in playersVoted
      end
    end
    emit "rule::voted"
  end
end

rule 108 do
  ### Each proposed rule-change shall be given a number for reference.
  ### The numbers shall begin with 301, and each rule-change proposed
  ### in the proper way shall receive the next successive integer,
  ### whether or not the proposal is adopted.
  event "rule::passed" do
    # store global data
    # modify source code for rule currentRule.id
    # reload source code
    # reload global data
    # emit "rule::complete" on load
  end
end

rule 201 do
  ### Players shall alternate in clockwise order, taking one whole turn apiece.
  ### Turns may not be skipped or passed, and parts of turns may not be omitted.
  ### All players begin with zero points.
  event "game::start" do
    players.each do |p|
      p.points = 0
    end
    turnCounter = 0
    emit "turn::start"
  end

  event "turn::end" do
    turnCounter += 1
    if turnCounter >= players.size
      turnCounter = 0
    end
    emit "turn::start"
  end
end

rule 202 do
  ### One turn consists of two parts in this order:
  ### (1) proposing one rule-change and having it voted on, and
  event "turn::start" do
    # prompt user for action through gui
    # set ruleChangeType to appropriate value
    emit "rule::change"
  end

  ### (2) throwing one die once and adding the number of points on its face to one's score.
  event "rule::complete", :priority => 1 do  # note that 1 is lower priority than the default 5
    emit "player::dice roll"
  end

  event "player::dice roll" do
    currentPlayer.points += ran(6)
  end
end

rule 203 do
  ### A rule-change is adopted if and only if the vote is unanimous among the eligible voters.
  event "vote::unanimous?" do
    votesUnanimous = true
    votedPlayers.each do |p|
      if p.vote = false
        votesUnanimous = false
      end
    end
  end
end

rule 208 do
  ### The winner is the first player to achieve 100 (positive) points.
  event "player::dice roll", :priority => 1 do
    if currentPlayer.points >= 100
      emit "player::win by points"
      assert false
    else
      emit "turn::end"
    end
  end
end
