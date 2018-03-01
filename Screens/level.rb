require_relative '../Objects/button'
require_relative '../Utilities/file_operation'

class Level
  def initialize
    @bkgnd = Gosu::Image.new('assets/backgnd1.png')
    file = FileOperation.new('save/save_data.json')
    @pref = file.load_data
    create_buttons
  end

  def update; end

  def create_buttons
    @buttons = []

    x = 30
    y = 100

    1.upto(20) do |i|
      @buttons << if @pref['access_level'] < i
                    { img: Button.new('assets/button_locked.png', x, y, ''),
                      value: 0 }
                  else
                    { img: Button.new('assets/pink_button.png', x, y, i),
                      value: i }
                  end
      x += 50

      if x == 280
        y += 70
        x = 30
      end
    end
  end

  def button_clicked(mouse_x, mouse_y)
    @buttons.each do |button|
      return button[:value] if button[:img].selected?(mouse_x, mouse_y)
    end
    -1
  end

  def draw
    @bkgnd.draw(0, 0, 0)

    @buttons.each do |button|
      button[:img].draw
    end
  end
end
