require 'test/unit'
$LOAD_PATH[0, 0] = File.join(File.dirname(__FILE__), '..', 'lib')
require 'bangkok/square'

class SquareTest < Test::Unit::TestCase

  def test_OFF_BOARD
    assert_not_nil(Square::OFF_BOARD)
  end

  def test_equals
    s1 = Square.at(3, 4)
    s2 = Square.new('d5')
    assert_equal(s1, s2)
    assert(s1 == s2)

    s3 = Square.at(0, 0)
    assert(s1 != s3)
  end

  def test_empty_ctor
    s = Square.new
    assert_equal(Square::OFF_BOARD, s)
  end

  def test_ctors
    s = Square.new
    assert_nil(s.file)
    assert_nil(s.rank)
    assert_nil(s.color)

    s = Square.at(1, 3)
    assert_equal(1, s.file)
    assert_equal(3, s.rank)
    assert_equal('b4', s.to_s)  # Just making sure I know what color should be
    assert_equal(:black, s.color)

    s1 = Square.new(s)
    assert_equal(s, s1)

    s = Square.new('a8')
    assert_equal(0, s.file)
    assert_equal(7, s.rank)
    assert_equal(:white, s.color)

    s = Square.new('g5')
    assert_equal(6, s.file)
    assert_equal(4, s.rank)
    assert_equal(:black, s.color)

    s = Square.new('d')
    assert_equal(3, s.file)
    assert_nil(s.rank)
    assert_nil(s.color)

    s = Square.new('4')
    assert_nil(s.file)
    assert_equal(3, s.rank)
    assert_nil(s.color)

    begin
      Square.new(Time.new)
      assert(false)
    rescue
      assert(true)
    end
  end

  def test_at
    assert_equal(Square.at(3, 3), Square.new('d4'))
  end

  def test_on_board
    s = Square.new
    assert(!s.on_board?)

    s = Square.at(1, 3)
    assert(s.on_board?)

    s1 = Square.new(s)
    assert(s.on_board?)

    s = Square.new('a8')
    assert(s.on_board?)

    s = Square.new('d')
    assert(!s.on_board?)

    s = Square.new('4')
    assert(!s.on_board?)
  end

  def test_to_s
    s = Square.new
    assert_equal("<off-board>", s.to_s)

    s = Square.at(1, 3)
    assert_equal("b4", s.to_s)

    s1 = Square.new(s)
    assert_equal("b4", s.to_s)

    s = Square.new('a8')
    assert_equal("a8", s.to_s)

    s = Square.new('d')
    assert_equal("<off-board>", s.to_s)

    s = Square.new('4')
    assert_equal("<off-board>", s.to_s)
  end

  def test_distance_to
    assert_nil(Square.new.distance_to(Square.new))
    assert_nil(Square.new.distance_to(Square.new('a4')))
    assert_nil(Square.new('a4').distance_to(Square.new))
    s = Square.new('b3')
    assert_equal(1, s.distance_to(Square.new('b4')))
    assert_equal(Math.sqrt(2), s.distance_to(Square.new('c4')))
    assert_equal(4, s.distance_to(Square.new('f3')))
    assert_equal(4, s.distance_to(Square.new('b7')))
  end

end
