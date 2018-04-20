class SpecialFX
  WIDTH = 42
  HEIGHT = 289
  
  def initialize(filename, x, y, fps, duration, size, type)
    @start_x = x
    @fps = fps
    @duration = duration
    @type = type
    @current_frame = 0
    @frames = size
    @frame_period = duration / fps
    @frame_ticker = 0
    @animation_finished = false
    @looped = false
    @image_array = []
    0.upto(size - 1) do
      @image_array << Gosu::Image.load_tiles(filename, WIDTH, HEIGHT)
    end
    
    @angles = []
    @centre_x = []
    @centre_y = []
    if type == :PURPLE_SWEET
      @angles = [0, 180]
      @centre_x = [0, 1]
      @centre_y = [1, 1]
      @y = [y - (WIDTH / 2), y]
      @x = [x, x]
    end
    
    if type == :MINT_SWEET
      @angles = [90, 270]
      @centre_x = [1, 0]
      @centre_y = [0.5, 0.5]
      @y = [y, y]
      @x = [x + (289 /2), x - (289 / 2)]
    end
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
    @image_array.each_with_index do |image, i|
      img = image[@current_frame]
      img.draw_rot(@x[i], @y[i], 0, @angles[i], @centre_x[i], @centre_y[i])
    end
  end
end
