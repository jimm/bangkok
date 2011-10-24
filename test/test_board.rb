require 'test/unit'
require 'stringio'
$LOAD_PATH[0, 0] = File.dirname(__FILE__)
$LOAD_PATH[0, 0] = File.join(File.dirname(__FILE__), '..', 'lib')
require 'bangkok/piece'
require 'bangkok/square'
require 'bangkok/move'
require 'bangkok/board'
require 'bangkok/chessgame'
require 'mock_game_listener'

class BoardTest < Test::Unit::TestCase

  def setup
    @listener = MockGameListener.new
    @board = Board.new(@listener)
  end

  def test_setup
    8.times { | i |
      assert_instance_of(Pawn, @board.at(Square.at(i, 1)))
      assert_instance_of(Pawn, @board.at(Square.at(i, 6)))
    }
    [:R, :N, :B, :Q, :K, :B, :N, :R].each_with_index { | sym, file |
      assert_equal(sym, @board.at(Square.at(file, 0)).piece)
      assert_equal(sym, @board.at(Square.at(file, 7)).piece)
    }
    8.times { | file |
      4.times { | rank |
	assert_nil(@board.at(Square.at(file, rank + 2)))
      }
    }
  end

  def test_listener_calls
    game = ChessGame.new(@listener)
    game_text = <<EOS
[Event "?"]
1. f4 Nf6 2. Nf3 c5 3. e3 d5 4. d4 Bf5 5. c3 e6 6. Bd3 Bxd3 7. Qxd3 Nc6 
EOS
    game.read_moves(StringIO.new(game_text))

    out = StringIO.new
    game.play(out)
    assert(@listener.called(:start_game))
    assert(@listener.called(:end_game))
    assert(@listener.called(:move))
  end

  def test_midi_output
    game = ChessGame.new	# default GameListener created
    game_text = <<EOS
[Event "?"]
1. f4 Nf6 2. Nf3 c5 3. e3 d5 4. d4 Bf5 5. c3 e6 6. Bd3 Bxd3 7. Qxd3 Nc6 
EOS
    game.read_moves(StringIO.new(game_text))

    out = StringIO.new
    game.play(out)
    assert(out.string.length > 0)
  end
end
