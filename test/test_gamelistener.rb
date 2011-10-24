require 'test/unit'
$LOAD_PATH[0, 0] = File.dirname(__FILE__)
$LOAD_PATH[0, 0] = File.join(File.dirname(__FILE__), '..', 'lib')
require 'bangkok/gamelistener'

class GameListenerTest < Test::Unit::TestCase

  def setup
    @listener = GameListener.new
  end

  def test_interp
    assert_equal(0, @listener.interpolate(0, 100, 0, 100, 0))
    assert_equal(100, @listener.interpolate(0, 100, 0, 100, 100))
    assert_equal(50, @listener.interpolate(0, 100, 0, 100, 50))

    assert_equal(50, @listener.interpolate(0, 100, 0, 500, 250))
    assert_equal(127, @listener.interpolate(0, 127, 0, 100, 100))
  end

  def test_file_to_pan
    assert_equal(0, @listener.file_to_pan(0))
    assert_equal(127, @listener.file_to_pan(7))
    assert_equal(63, @listener.file_to_pan(3.5))
  end

  def test_rank_to_pan
    assert_equal(10, @listener.rank_to_volume(0)) # 10 is minimum volume
    assert_equal(10, @listener.rank_to_volume(7))
    assert_equal(127, @listener.rank_to_volume(3.5))
  end
end
