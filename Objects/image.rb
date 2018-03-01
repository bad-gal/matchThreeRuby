class Image
  attr_accessor :x, :y

  def initialize(file_image, x, y)
    @image = Gosu::Image.new(file_image, tileable: true)
    @x = x
    @y = y
  end

  def draw
    @image.draw(@x, @y, 0)
  end

  def selected?(mouse_x, mouse_y)
    true if mouse_x >= @x && mouse_x <= (@x + @image.width) &&
            mouse_y >= @y && mouse_y <= (@y + @image.height)
  end
end
