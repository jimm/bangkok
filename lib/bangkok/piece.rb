require 'bangkok/square'

class Piece
  attr_reader :color, :piece, :square

  # Factory method that creates a piece of the proper subclass
  def Piece.create(board, listener, color, piece_sym, square)
    return case piece_sym
        when :K
          King.new(board, listener, color, square)
        when :Q
          Queen.new(board, listener, color, square)
        when :B
          Bishop.new(board, listener, color, square)
        when :N
          Knight.new(board, listener, color, square)
        when :R
          Rook.new(board, listener, color, square)
        when :P
          Pawn.new(board, listener, color, square)
        end
  end

  def initialize(board, listener, color, piece, square)
    @board, @listener, @color, @piece, @square =
      board, listener, color, piece, square
  end

  def move_to(square)
    puts "#{self} moving to #{square}" if $verbose
    @listener.move(self, @square, square)
    @square = square
  end

  def move_off_board
    return move_to(Square::OFF_BOARD)
  end

  # Make sure this piece can perform +move+. This implementation checks the
  # basics (the color and type of this piece and the emptiness or color of the
  # piece at the destination square); subclasses add further checks.
  def could_perform_move(move)
    p = @board.at(move.square)
    return @color == move.color && piece == move.piece &&
      (p.nil? || p.color != @color)
  end

  # Checks diagonals and straight horizontal/vertical lines. Won't work
  # correctly for anything else.
  def clear_to?(square)
    curr_file = @square.file
    end_file = square.file
    file_delta = @square.file < square.file ? 1 :
                               (@square.file == square.file ? 0 : -1)
    curr_file += file_delta unless curr_file == end_file # Skip current loc

    curr_rank = @square.rank
    end_rank = square.rank
    rank_delta = @square.rank < square.rank ? 1 :
                               (@square.rank == square.rank ? 0 : -1)
    curr_rank += rank_delta unless curr_rank == end_rank # Skip current loc

    if file_delta == 0 && rank_delta == 0
      raise "error: trying to move to same space #{file}#{rank}"
    end

    while curr_file != end_file || curr_rank != end_rank
      return false unless @board.empty_at?(Square.at(curr_file, curr_rank))
      curr_file += file_delta
      curr_rank += rank_delta
    end

    return true
  end

  def to_s
    str = "#{@color.to_s.capitalize} #@piece "
    str << "at " if @square.on_board?
    str << @square.to_s
    str
  end
end

class King < Piece
  def initialize(board, listener, color, square)
    super(board, listener, color, :K, square)
  end

  # There is no King#could_move_to method because it would only be called if
  # there were more than one King of the same color on the board, which can
  # not happen.
end

class Queen < Piece
  def initialize(board, listener, color, square)
    super(board, listener, color, :Q, square)
  end

  # There can be more than one queen on the board, thus this method must be
  # implemented.
  def could_perform_move(move)
    return false unless super

    # Check for horizontal or vertical
    square = move.square
    if @square.file == square.file || @square.rank == square.rank
      return clear_to?(square)
    end

    # Check for diagonal
    return false unless square.color == @square.color
    d_file = (@square.file - square.file).abs
    d_rank = (@square.rank - square.rank).abs
    return false unless d_file == d_rank # diagonal
    return clear_to?(square)
  end
end

class Bishop < Piece
  def initialize(board, listener, color, square)
    super(board, listener, color, :B, square)
  end

  def could_perform_move(move)
    return false unless super

    # Quick square color check
    square = move.square
    return false unless square.color == @square.color

    d_file = (@square.file - square.file).abs
    d_rank = (@square.rank - square.rank).abs
    return false unless d_file == d_rank # diagonal
    return clear_to?(square)
  end
end

class Knight < Piece
  def initialize(board, listener, color, square)
    super(board, listener, color, :N, square)
  end

  def could_perform_move(move)
    return false unless super

    square = move.square
    d_file = (@square.file - square.file).abs
    d_rank = (@square.rank - square.rank).abs
    return (d_file == 2 && d_rank == 1) || (d_file == 1 && d_rank == 2)
  end
end

class Rook < Piece
  def initialize(board, listener, color, square)
    super(board, listener, color, :R, square)
  end

  def could_perform_move(move)
    return false unless super

    square = move.square
    return false if square.file != @square.file && square.rank != @square.rank
    return clear_to?(square)
  end
end

class Pawn < Piece
  attr_reader :moved

  def initialize(board, listener, color, square)
    super(board, listener, color, :P, square)
    @moved = false
  end

  def move_to(square)
    @moved = true
    return super
  end

  def could_perform_move(move)
    return false unless super

    square = move.square
    if @color == :white
      if square.file == @square.file && square.rank == @square.rank + 1
        # single step forwards
        return @board.empty_at?(square)
      elsif square.file + 1 == @square.file && square.rank == @square.rank + 1
        # take a piece queenside
        return !@board.empty_at?(square)
      elsif square.file == @square.file + 1 && square.rank == @square.rank + 1
        # take a piece kingside
        return !@board.empty_at?(square)
      elsif !@moved && square.file == @square.file &&
                       square.rank == @square.rank + 2
        # first move: 2 squares forward
        return @board.empty_at?(Square.at(@square.file, @square.rank + 1)) &&
          @board.empty_at?(square)

# TODO Implement en passant checking. The following code was wrong. 

#       elsif !@moved && square.file + 1 == @square.file &&
#                        square.rank == @square.rank + 2
#         # e.p. queenside
#         return !@board.empty_at?(square)
#       elsif !@moved && square.file == @square.file + 1 &&
#                        square.rank == @square.rank + 2
#         # e.p. kingside
#         return !@board.empty_at?(square)

      end
    else
      # black
      if square.file == @square.file && square.rank == @square.rank - 1
        # single step forwards
        return @board.empty_at?(square)
      elsif square.file + 1 == @square.file && square.rank == @square.rank - 1
        # take a piece queenside
        return !@board.empty_at?(square)
      elsif square.file == @square.file + 1 && square.rank == @square.rank - 1
        # take a piece kingside
        return !@board.empty_at?(square)
      elsif !@moved && square.file == @square.file &&
                       square.rank == @square.rank - 2
        # first move: 2 spaces forward
        return @board.empty_at?(Square.at(@square.file, @square.rank - 1)) &&
          @board.empty_at?(square)

# TODO Implement en passant checking. The following code was wrong. 

#       elsif !@moved && square.file + 1 == @square.file &&
#                        square.rank == @square.rank - 2
#         # en passant queenside
#         return !@board.empty_at?(square)
#       elsif !@moved && square.file == @square.file + 1 &&
#                        square.rank == @square.rank - 2
#         # en passant kingside
#         return !@board.empty_at?(square)

      end
    end
  end
end
