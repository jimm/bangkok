require 'test/unit'
$LOAD_PATH[0, 0] = File.dirname(__FILE__)
$LOAD_PATH[0, 0] = File.join(File.dirname(__FILE__), '..', 'lib')
require 'bangkok/piece'
require 'bangkok/square'
require 'bangkok/move'
require 'bangkok/board'
require 'mock_game_listener'

class PieceTest < Test::Unit::TestCase

  def setup
    @listener = MockGameListener.new
    @board = Board.new(@listener)
    @w_pawn = @board.at(Square.new('a2'))
    @b_pawn = @board.at(Square.new('e7'))
  end

  def test_create
    assert_instance_of(King, Piece.create(@board, @listener, :white, :K,
                                          Square::OFF_BOARD))
    assert_instance_of(Queen, Piece.create(@board, @listener, :white, :Q,
                                          Square::OFF_BOARD))
    assert_instance_of(Bishop, Piece.create(@board, @listener, :white, :B,
                                          Square::OFF_BOARD))
    assert_instance_of(Knight, Piece.create(@board, @listener, :white, :N,
                                          Square::OFF_BOARD))
    assert_instance_of(Rook, Piece.create(@board, @listener, :white, :R,
                                          Square::OFF_BOARD))
    assert_instance_of(Pawn, Piece.create(@board, @listener, :white, :P,
                                          Square::OFF_BOARD))
    assert_nil(Piece.create(@board, @listener, :white, nil, Square::OFF_BOARD))
  end

  def test_moved
    assert(!@w_pawn.moved)
    @w_pawn.move_to(Square.new('a4'))
    assert(@w_pawn.moved)
  end

  def test_move_to
    assert_equal(Square.new('a2'), @w_pawn.square)

    dest = Square.new('b3')
    @w_pawn.move_to(dest)
    assert_equal(dest, @w_pawn.square)

    dest = Square::OFF_BOARD
    @w_pawn.move_off_board
    assert_equal(dest, @w_pawn.square)
  end

  def test_pawn_could_move_to
    assert(@w_pawn.could_perform_move(Move.new(:white, 'a3')))
    assert(@w_pawn.could_perform_move(Move.new(:white, 'a4')))

    diag = Move.new(:white, 'b3')
    assert(!@w_pawn.could_perform_move(diag)) # no piece there

    # put a black piece there so we can capture it
    @board.at(Square.new('d8')).move_to(Square.new('b3'))
    assert(@w_pawn.could_perform_move(diag)) # now we can capture it

    assert(@b_pawn.could_perform_move(Move.new(:black, 'e6')))
    assert(@b_pawn.could_perform_move(Move.new(:black, 'e5')))

    diag = Move.new(:black, 'd6')
    assert(!@b_pawn.could_perform_move(diag)) # no piece there

    # put a white piece there so we can capture it
    @board.at(Square.new('d1')).move_to(Square.new('d6'))
    assert(@b_pawn.could_perform_move(diag)) # now we can capture it
  end

  def test_pawn_en_passant
    # TODO
    # Warning: en passant is not handled yet by the code
  end

  def test_rook_could_move_to
    rook = @board.at(Square.new('a8')) # black rook
    assert(!rook.could_perform_move(Move.new(:black, 'Ra7')))
    @board.at(Square.new('a7')).move_off_board # remove pawn in front
    (3..7).each { | rank |
      assert(rook.could_perform_move(Move.new(:black, 'Ra' + rank.to_s)))
    }

    assert_not_nil(@board.at(Square.new('a2')))
    assert(rook.could_perform_move(Move.new(:black, 'Ra2'))) # can capture

    assert_not_nil(@board.at(Square.new('a1')))
    assert(!rook.could_perform_move(Move.new(:black, 'Ra1'))) # can't get there
  end

  def test_knight_could_move_to
    knight = @board.at(Square.new('b1')) # white knight
    assert_equal(:N, knight.piece)
    assert(knight.could_perform_move(Move.new(:white, 'Nc3')))
    assert(knight.could_perform_move(Move.new(:white, 'Na3')))
    assert(!knight.could_perform_move(Move.new(:white, 'Nb3')))

    knight = @board.at(Square.new('b8')) # black knight
    knight.move_to(Square.new('d4'))
    assert_not_nil(@board.at(Square.new('c2')))
    assert_not_nil(@board.at(Square.new('e2')))
    %w(c2 e2 c6 e6 b3 b5 f3 f5).each { | sq |
      assert(knight.could_perform_move(Move.new(:black, 'N' + sq)))
    }
  end

  def test_bishop_could_move_to
    bishop = @board.at(Square.new('c1'))
  end

  def test_queen_could_move_to
  end

  def test_king_could_move_to
  end

end
