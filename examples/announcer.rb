#! /usr/bin/env ruby

require 'getoptlong'
begin
  require 'bangkok/chessgame'
rescue LoadError
  require 'rubygems'
  require 'bangkok/chessgame'
end

class Announcer
  def start_game(io)
    @out = io
    @out.puts 'Start of game'
  end

  def end_game
    @out.puts 'End of game'
  end

  def move(piece, from, to)
    @out.puts "Piece #{piece} moving to #{to}"
  end

  def capture(attacker, loser)
    @out.puts "#{attacker} captures #{loser}"
  end

  def check
    @out.puts "Check"
  end

  def checkmate
    @out.puts "Checkmate"
  end

  def pawn_to_queen(pawn)
    @out.puts "#{pawn} has been turned into a queen"
  end
end

def usage
  $stderr.puts <<EOS
usage: announcer [-v] chessgame.pgn ...
  -v   Verbose (prints each move)
  -h   This message

For each chess game, prints each event to stdout.
EOS
  
  exit 1
end

$verbose = false
g = GetoptLong.new(['-v', '--verbose', GetoptLong::NO_ARGUMENT],
		   ['-h', '--help', GetoptLong::NO_ARGUMENT])
g.each { | opt, arg |
  case opt
  when '-v'
    $verbose = true
  else
    usage
  end
}
usage if ARGV.length == 0

ARGV.each { | fname |
  game = ChessGame.new(Announcer.new)
  File.open(fname, 'r') { | f | game.read_moves(f) }
  game.play($stdout)
}
