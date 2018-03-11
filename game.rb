require 'rubygems'
require 'gosu'
require_relative 'Helpers/settings.rb'
require_relative 'Screens/title'
require_relative 'Screens/level'
require_relative 'Screens/main'

class Game < Gosu::Window
  def initialize
    super Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT
    self.caption = 'Urbies'
    @font = Gosu::Font.new(20)
    @screen = Title.new
  end

  def update
    @screen.update
  end

  def draw
    @screen.draw
  end

  def needs_cursor?
    true
  end

  def button_down(id)
    case id
    when Gosu::KbEscape
      close
    when Gosu::MsLeft
      if @screen.class == Title
        play_button_pressed
      elsif @screen.class == Level
        play_level
      elsif @screen.class == Main
        play_game
      end
    end
  end

  def play_level
    selected_level = @screen.button_clicked(mouse_x, mouse_y)
    return if selected_level.zero?
    @level = selected_level
    @screen = Main.new(@level)
  end

  def play_game
    @screen.urb_clicked(mouse_x, mouse_y)
    if @screen.instance_variable_get(:@exit_value) == -1
      close
    elsif @screen.instance_variable_get(:@exit_value) == 1
      @screen = Level.new
    end
  end

  def inside_x
    mouse_x >= @screen.x &&
      mouse_x <= (@screen.x + @screen.button_play.width)
  end

  def inside_y
    mouse_y >= @screen.y &&
      mouse_y <= (@screen.y + @screen.button_play.height)
  end

  def play_button_pressed
    return unless inside_x && inside_y
    @screen = Level.new
  end
end

Game.new.show
