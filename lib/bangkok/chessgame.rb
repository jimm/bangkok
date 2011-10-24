require 'bangkok/gamelistener'
require 'bangkok/board'
require 'bangkok/move'

# ChessGame takes a listener in its constructor and creates a Board. The
# method ChessGame#read_moves reads game data. Calling ChessGame#play moves
# the pieces, which in turn sends messages to the listener so it can react.
class ChessGame

  def initialize(listener = GameListener.new)
    @listener = listener
  end

  # Read the chess game and turn it into Moves.
  def read_moves(io)
    game_text = read(io)
    @moves = []
    game_text.scan(/\d+\.\s+(\S+)\s+(\S+)/).each { | white, black |
      @moves << Move.new(:white, white)
      @moves << Move.new(:black, black) unless black == '1-0' || black == '0-1'
    }
  end

  # Read the chess game. Set player names and return a string containing the
  # chess moves ("1. f4 Nf6 2. Nf3 c5...").
  def read(io)
    game_text = ''
    io.each { | line |
      line.chomp!
      case line
      when /\[(.*)\]/           # New games starting (if multi-game file)
      when /^\s*$/
      else
        game_text << ' '
        game_text << line
      end
    }
    game_text
  end

  # Writes a MIDI file.
  def play(io)
    @listener.start_game(io)
    board = Board.new(@listener)
    @moves.each { | move | board.apply(move) }
    @listener.end_game
  end

end
