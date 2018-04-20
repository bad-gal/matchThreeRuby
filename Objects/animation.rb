class Animation
  attr_reader :sprite_array, :fps, :duration, :height, :animation_finished
  attr_accessor :x, :y

  def initialize(filename, width, height, fps, duration, looped, x, y)
    @image_array = Gosu::Image.load_tiles filename, width, height
    @width = width
    @height = height
    @fps = fps
    @looped = looped
    @duration = duration
    @x = x
    @y = y
    add_frame_data(@image_array.size, @duration, @fps)
  end

  def add_frame_data(size, duration, fps)
    @current_frame = 0
    @frames = size
    @frame_period = duration / fps
    @frame_ticker = 0
    @animation_finished = false
  end

  def change_loop(value)
    @looped = value
  end

  def update
    return if Gosu.milliseconds < (@frame_ticker + @frame_period)
    @frame_ticker = Gosu.milliseconds
    @current_frame += 1

    case @looped
    when true
      @current_frame = 0 if @current_frame >= @frames
    when false
      @animation_finished = true if @current_frame >= @frames
    end
  end

  def draw
    return if @animation_finished
    image = @image_array[@current_frame]
    image.draw(@x, @y, 0)
  end

  def change_image(filename)
    @image_array.clear
    @image_array = Gosu::Image.load_tiles filename, @width, @height
    @frames = @image_array.size
  end

  def change_image_and_loop(filename, looped)
    @image_array.clear
    @image_array = Gosu::Image.load_tiles filename, @width, @height
    @frames = @image_array.size
    @looped = looped
  end
end
