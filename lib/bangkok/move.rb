require 'bangkok/square'


# A Move is a single piece's move in a chess match. There are two Move objects
# created for each chess match move: one for white and one for black.
class Move
  attr_reader :color, :piece, :square, :from_rank_or_file, :modifier

  # Parse the chess piece move +text+ and set piece, square, and modifier.
  def initialize(color, text)
    @color = color              # :white or :black
    @orig_text = text

    # Note: I don't have to worry about "e.p." en passant notation; the data
    # files do not use that.
    case text
    when 'O-O-O', 'O-O', '0-0-0', '0-0'
      @modifier = text.gsub(/0/, 'O') # zeroes to capital o's
      @piece = 'K'
      @square = Square::OFF_BOARD # Not really, of course; square is never used
    when /^([KQRBNa-h1-8])x([a-h][1-8])(.*)$/
      piece_or_from_rank_or_file, file_and_rank, @modifier = $1, $2, $3
      @square = Square.new(file_and_rank)
      case piece_or_from_rank_or_file
      when /[a-h1-8]/           # first char is file or rank; it's a pawn
        @piece = 'P'
        @from_rank_or_file = Square.new(piece_or_from_rank_or_file)
      else                      # first char is piece name
        @piece = piece_or_from_rank_or_file
      end
      @modifier ||= ''
      @modifier << 'x'
    when /^([KQRBN]?)([a-h1-8]?)([a-h][1-8])(.*)$/
      @piece, from_rank_or_file, file_and_rank, @modifier = $1, $2, $3, $4
      @square = Square.new(file_and_rank)
      unless from_rank_or_file.empty?
        @from_rank_or_file = Square.new(from_rank_or_file) 
      end
    else
      raise "I can't understand the move \"#{@orig_text}\""
    end

    @piece = 'P' if @piece.empty?
    @piece = @piece.intern
  end

  def to_s
    return @orig_text
  end

  # Returns true if @modifier is not null and includes +str+.
  def has_modifier?(str)
    return false unless @modifier
    return @modifier.include?(str)
  end

  # Returns true if this is a capture
  def capture?
    has_modifier?('x')
  end

  # Returns true if this is a castle (either side)
  def castle?
    has_modifier?('O-O')	# Also true if O-O-O
  end

  # Returns true if this is a queenside castle
  def queenside_castle?
    has_modifier?('O-O-O')
  end

  # Returns true if this is a kingside castle
  def kingside_castle?
    has_modifier?('O-O') && !queenside_castle?
  end

  # Returns true if this move results in a pawn promotion
  def pawn_promotion?
    has_modifier?('Q')
  end

  # Returns true if this move results in a check
  def check?
    has_modifier?('+')
  end

  # Returns true if this move results in a checkmate
  def checkmate?
    has_modifier?('#')
  end

  # Returns true if this move was a good one
  def good_move?
    has_modifier?('!')
  end

  # Returns true if this move was a bad one
  def bad_move?
    has_modifier?('?') && !blunder?
  end

  # Returns true if this move was a blunder
  def blunder?
    has_modifier?('??')
  end
end
