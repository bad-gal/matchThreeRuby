require_relative 'image'

class Button < Image
  def initialize(file_image, x, y, text)
    super(file_image, x, y)
    @font = Gosu::Font.new(22)
    @text = text
  end

  def selected?(mouse_x, mouse_y)
    true if mouse_x >= @x && mouse_x <= (@x + @image.width) &&
            mouse_y >= @y && mouse_y <= (@y + @image.height)
  end

  def draw
    @image.draw(@x, @y, 0)

    @font.draw(
      @text,
      @x + ((@image.width / 2) - (@font.text_width(@text) / 2)),
      @y + ((@image.height / 2) - (@font.height / 2)), 0, 1, 1,
      Gosu::Color::WHITE
    )
  end
end
