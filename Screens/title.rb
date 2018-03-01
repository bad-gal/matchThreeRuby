require 'gosu'

class Title
  attr_reader :x, :y, :button_play

  def initialize
    @bkgnd = Gosu::Image.new('assets/urbies.png')
    @button_play = Gosu::Image.new('assets/play_xs.png')
    @x = 110
    @y = 260
  end

  def update; end

  def draw
    @bkgnd.draw(0, 0, 0)
    @button_play.draw(@x, @y, 0)
  end

  def button_down(id); end
end
