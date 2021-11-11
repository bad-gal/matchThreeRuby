require 'gosu'

class Title
  attr_reader :x, :y, :button_play

  def initialize
    @bkgnd = Gosu::Image.new('assets/urbies.png')
    @button_play = Gosu::Image.new('assets/play_xs.png')
    @font = Gosu::Font.new(16)
    @x = 110
    @y = 260
  end

  def update; end

  def draw
    @bkgnd.draw(0, 0, 0)
    @button_play.draw(@x, @y, 0)
    @font.draw_text("copyright (c) 2018 Andrien Ricketts", 40, 455, 0, 1, 1, Gosu::Color::WHITE)
  end

  def button_down(id); end
end
