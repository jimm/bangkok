begin
  require 'midilib'
rescue LoadError
  require 'rubygems'
  require_gem 'midilib'
end
include MIDI

# The pieces and board call methods on an instance of GameListener, which
# turns those events into MIDI events.
class GameListener

  PIECE_NAMES = {
    :P => "Pawn",
    :R => "Rook",
    :N => "Night",
    :B => "Bishop",
    :Q => "Queen",
    :K => "King"
  }

  # Build notes to play for ranks
  RANK_TO_NOTE = {}
  RANK_TO_NOTE[:white] = [64, 66, 68, 69, 71, 73, 75, 76]
  RANK_TO_NOTE[:black] = RANK_TO_NOTE[:white].reverse

  PIECE_MIDI_INFO = {}
  PIECE_MIDI_INFO[:white] = {}
  PIECE_MIDI_INFO[:black] = {}

  # Used by config files to set the program change value for a piece.
  def GameListener.white(piece_sym, program_change)
    PIECE_MIDI_INFO[:white][piece_sym] = program_change
  end

  # Used by config files to set the program change value for a piece.
  def GameListener.black(piece_sym, program_change)
    GameListener::PIECE_MIDI_INFO[:black][piece_sym] = program_change
  end

  # Fill in some default values, in case the user does not specify any new
  # ones.
  black :K, 0
  black :Q, 8
  black :R, 16
  black :B, 24
  black :N, 32
  black :P, 4
  white :K, 4
  white :Q, 12
  white :R, 20
  white :B, 28
  white :N, 36
  white :P, 44

  attr_reader :seq              # MIDI::Sequence

  def initialize(config_file_path=nil)
    read_config(config_file_path) if config_file_path
  end

  def read_config(config_file_path)
    IO.readlines(config_file_path).each { | line |
      line.chomp!
      class_eval(line)
    }
  end

  def track_of(piece)
    i = [:white, :black].index(piece.color) * 6 +
      [:P, :R, :N, :B, :Q, :K].index(piece.piece)
    @seq.tracks[i + 1]          # 0'th track is temp track
  end

  def channel_of(piece)
    [:white, :black].index(piece.color) * 8 +
      [:P, :R, :N, :B, :Q, :K].index(piece.piece)
  end

  # --
  # ================================================================
  # Listener interface
  # ================================================================
  # ++

  def start_game(io)
    @io = io
    @seq = Sequence.new
    track = Track.new(@seq)     # Tempo track
    track.name = "Tempo track"
    @seq.tracks << track

    @first_note_delta = @seq.note_to_delta('32nd')
    @portamento_start = @seq.note_to_delta('64th')
    @max_delta =
	@seq.length_to_delta(Square.at(0, 0).distance_to(Square.at(7, 7)))

    create_tracks()
    @time_from_start = 0
  end

  def end_game
    # When we created events, we set their start times, not their delta times.
    # Now is the time to fix that. Sort sorts by start times then calls
    # recalc_delta_from_times.
    @seq.tracks.each { | t | t.sort }
    @seq.write(@io)
  end

  # Move +piece+ +from+ one space +to+ another. Generate two notes and sets
  # CC_PORTAMENTO_TIME so there is a glide from the first note to the second.
  # Also output multiple volume and pan values, moving smoothly from the
  # original to the new value.
  def move(piece, from, to)
    raise "from #{from} may not be off the board" unless from.on_board?

    # Do nothing if the piece moves off the board, because either capture()
    # or pawn_to_queen() will be called.
    return unless to.on_board?

    track = track_of(piece)
    channel = channel_of(piece)

    dist = from.distance_to(to)
    total_delta = @seq.length_to_delta(dist) # quarter note per space

    generate_notes(track, channel, total_delta, piece, from, to)
    generate_portamento(track, channel, total_delta)

    steps = interpolate(16, 64, 0, @max_delta, total_delta).to_i
    delta = (total_delta / steps).to_i
    start = @time_from_start

    steps.times { | step |
      val = rank_to_volume(interpolate(from.rank, to.rank, 0, steps-1, step))
      generate_volume(track, channel, start, val)
      
      val = file_to_pan(interpolate(from.file, to.file, 0, steps-1, step))
      generate_pan(track, channel, start, val)

      start += delta
    }

    @time_from_start += total_delta
  end

  def capture(attacker, loser)
  end

  def check
  end

  def checkmate
  end

  def pawn_to_queen(pawn)
  end

  # --
  # ================================================================
  # End of listener interface
  # ================================================================
  # ++

  def create_tracks
    [:white, :black].each_with_index { | color, chan_base_offset |
      [:P, :R, :N, :B, :Q, :K].each_with_index { | piece_sym, chan_offset |
        track = Track.new(@seq)
        @seq.tracks << track

        track.name = "#{color.to_s.capitalize} #{PIECE_NAMES[piece_sym]}"

        program_num = PIECE_MIDI_INFO[color][piece_sym]
        track.instrument = GM_PATCH_NAMES[program_num]
        track.events << ProgramChange.new(chan_base_offset * 8 + chan_offset,
                                          program_num)
      }
    }
  end

  # Returns a value between range_min and range_max inclusive that is
  # proportional to +value+'s place between value_min and value_max. The
  # returned value may be floating point. If range_min and range_max or
  # value_min and value_max are out of order, they are swapped.
  def interpolate(range_min, range_max, value_min, value_max, value)
    range_min, range_max = range_max, range_min if range_min > range_max
    value_min, value_max = value_max, value_min if value_min > value_max
    return range_min if value == value_min
    frac = (value_max.to_f - value_min.to_f) / (value.to_f - value_min.to_f)
    return range_min + (range_max.to_f - range_min.to_f) / frac
  end

  # Generate two notes, one at the current start time that is only a 32nd note
  # long. The next follows immediately, and is for the +to+ square. Its length
  # is the remaining time.
  def generate_notes(track, channel, total_delta, piece, from, to)
    # First note is quickly followed by the second note
    note = RANK_TO_NOTE[piece.color][from.rank]
    e = NoteOnEvent.new(channel, note, 127)
    e.time_from_start = @time_from_start
    track.events << e

    e = NoteOffEvent.new(channel, note, 127)
    e.time_from_start = @time_from_start + @first_note_delta - 1
    track.events << e

    # Second note
    note = RANK_TO_NOTE[piece.color][to.rank]
    e = NoteOnEvent.new(channel, note, 127)
    e.time_from_start = @time_from_start + @first_note_delta
    track.events << e

    e = NoteOffEvent.new(channel, note, 127)
    e.time_from_start = @time_from_start + total_delta - 1
    track.events << e
  end

  # Translates a (possibly fractional) +file+ into an integer CC_PAN value.
  def file_to_pan(file)
    return interpolate(0, 127, 0, 7, file).to_i
  end

  # Translates a (possibly fractional) +rank+ into an integer CC_VOLUME value.
  def rank_to_volume(rank)
    rank = 3.5 - (3.5 - rank).abs
    return interpolate(10, 127, 0, 3.5, rank).to_i
  end

  # Generates a single volume event. #move_to calls this multiple times,
  # passing in new +delta+ and +value+ values.
  def generate_volume(track, channel, delta, value)
    raise "volume: bogus value #{value}" unless value >= 0 && value <= 127
    e = Controller.new(channel, CC_VOLUME, value)
    e.time_from_start = @time_from_start + delta
    track.events << e
  end

  # Generates a single pan event. #move_to calls this multiple times, passing
  # in new +delta+ and +value+ values.
  def generate_pan(track, channel, delta, value)
    raise "pan: bogus value #{value}" unless value >= 0 && value <= 127
    e = Controller.new(channel, CC_PAN, value)
    e.time_from_start = @time_from_start + delta
    track.events << e
  end

  # Generates a single portamento event.
  def generate_portamento(track, channel, total_delta)
    e = Controller.new(channel, CC_PORTAMENTO_TIME, 0)
    e.time_from_start = @time_from_start
    track.events << e

    value = interpolate(32, 100, 0, @max_delta, total_delta).to_i
    raise "portamento: bogus value #{value}" unless value >= 0 && value <= 127
    e = Controller.new(channel, CC_PORTAMENTO_TIME, value)
		       
    e.time_from_start = @time_from_start + @portamento_start
    track.events << e
  end

end
