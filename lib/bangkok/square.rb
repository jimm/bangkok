# Represents a location on the board. Immutable.
class Square
  attr_reader :file, :rank      # Always 0-7
  attr_reader :color            # :white or :black

  def Square.at(file, rank)
    SQUARES[file][rank]
  end

  def initialize(*args)
    @file = @rank = @color = nil
    case args[0]
    when Square                 # copy values from another Square
      @file = args[0].file
      @rank = args[0].rank
      @color = args[0].color
    when Numeric                # (file number, rank number)
      @file = args[0].to_i      # If floating point, make integer
      @rank = args[1].to_i
      @color = (((@file & 1) == (@rank & 1)) ? :black : :white) if on_board?
    when /[a-h][1-8]/           # a3, d8
      @file = args[0][0] - ?a
      @rank = args[0][1,1].to_i - 1
      @color = ((@file & 1) == (@rank & 1)) ? :black : :white
    when /[a-h]/                # Either (file letter, rank) or a file 'a'
      @file = args[0][0] - ?a
      @rank = (args[1].to_i - 1) if args[1]
    when /[1-8]/                # 1, 5
      @rank = args[0].to_i - 1
    when nil
      # both file and rank are nil
    else
      raise "don't understand Square ctor args (#{args.join(',')})"
    end
  end

  def ==(square)
    @file == square.file && @rank == square.rank
  end

  def on_board?
    return @file && @rank
  end

  # Return the distance between this square and the other. Returns nil of
  # eithr square is off the board.
  def distance_to(square)
    return nil unless on_board? && square.on_board?
    d_file = square.file - @file
    d_rank = square.rank - @rank
    return Math.sqrt(d_file * d_file + d_rank * d_rank)
  end

  def to_s
    return "<off-board>" if @file.nil? || @rank.nil?
    return "#{@file ? (?a + file).chr : ''}#{@rank + 1}"
  end

  SQUARES = []
  8.times { | file |
    SQUARES[file] = []
    8.times { | rank | SQUARES[file][rank] = Square.new(file, rank) }
  }

  OFF_BOARD = Square.new
end
