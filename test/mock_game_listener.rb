class MockGameListener
  def initialize
    @called = []
  end

  def start_game(io)
    @called << :start_game
  end

  def end_game
    @called << :end_game
  end

  def move(piece, from, to)
    @called << :move
  end

  def capture(attacker, loser)
    @called << :capture
  end

  def check
    @called << :check
  end

  def checkmate
    @called << :checkmate
  end

  def pawn_to_queen(pawn)
    @called << :pawn_to_queen
  end

  def called(sym)
    @called.include?(sym)
  end
end
