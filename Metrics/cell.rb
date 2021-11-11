class Cell
  attr_accessor :x, :y, :obstacle, :occupied, :invisible
  attr_reader :g_score

  def initialize(x, y)
    @x = x
    @y = y
    @obstacle = false
    @occupied = true
    @invisible = false
    @g_score = Float::INFINITY
  end

  def calculate_g_score(score)
    @g_score = score
  end
end