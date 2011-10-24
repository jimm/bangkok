require 'bangkok/square'
require 'bangkok/piece'

class Board

  def initialize(listener)
    @listener = listener
    @pieces = []
    [:R, :N, :B, :Q, :K, :B, :N, :R].each_with_index { | sym, file |
      @pieces << Piece.create(self, listener, :white, sym, Square.at(file, 0))
      @pieces << Piece.create(self, listener, :black, sym, Square.at(file, 7))
    }
    8.times { | file |
      @pieces << Piece.create(self, listener, :white, :P, Square.at(file, 1))
      @pieces << Piece.create(self, listener, :black, :P, Square.at(file, 6))
    }
  end

  def apply(move)
    if move.castle?
      apply_castle(move)
    else
      piece = find_piece(move)
      other_piece = at(move.square) unless move.castle?
      piece.move_to(move.square)
      if other_piece              # capture
        unless move.capture?
          raise "error: piece found at target (#{other_piece}) but move" +
            " #{move} is not a capture"
        end
        @listener.capture(piece, other_piece)
        remove_from_board(other_piece)
      end

      if move.pawn_promotion?
        raise "error: trying to promote a non-pawn" unless piece.piece == :P

        @listener.pawn_to_queen(piece)
        color = piece.color
        remove_from_board(piece) # will also trigger the listener
        @pieces << Piece.create(self, color, :Q, move.square)
      end
    end
  end

  def apply_castle(move)
    new_king_file = nil
    new_rook_file = nil
    king = @pieces.detect { | p | p.piece == :K && p.color == move.color }
    rook = nil

    if move.queenside_castle?
      new_king_file = king.square.square.file - 2
      rook = @pieces.detect { | p |
        p.piece == :R && p.color == move.color && p.square.file == 0
      }
      new_rook_file = rook.square.file + 3
    else # kingside castle
      new_king_file = king.square.file + 2
      rook = @pieces.detect { | p |
        p.piece == :R && p.color == move.color && p.square.file == 7
      }
      new_rook_file = rook.square.file - 2
    end

    king.move_to(Square.at(new_king_file, king.square.rank))
    rook.move_to(Square.at(new_rook_file, rook.square.rank))
  end

  def remove_from_board(piece)
    @pieces.delete(piece)
    piece.move_off_board()
  end

  def empty_at?(square)
    return at(square).nil?
  end

  def at(square)
    return @pieces.detect { | p | p.square == square }
  end

  def find_piece(move)
    candidates = @pieces.find_all { | p | p.could_perform_move(move) }
    case candidates.length
    when 0
      raise "error: no pieces found for move #{move}"
    when 1
      return candidates[0]
    else                        # Disambiguate using move's orig. rank or file
      if move.from_rank_or_file.rank.nil? # file is non-nil
        candidates = candidates.find_all { | p |
          p.square.file == move.from_rank_or_file.file
        }
      else
        candidates = candidates.find_all { | p |
          p.square.rank == move.from_rank_or_file.rank
        }
      end
      case candidates.length
      when 0
        raise "error: disambiguation found no pieces for #{move}"
      when 1
        return candidates[0]
      else
        raise "error: too many pieces match #{move}"
      end
    end
  end
end
