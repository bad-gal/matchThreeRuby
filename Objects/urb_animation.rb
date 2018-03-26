class UrbAnimation < Animation
  attr_reader :type, :path, :cell
  attr_accessor :location, :visible, :active, :off_screen, :status, :keyframes

  def initialize(filename, width, height, fps, duration, looped, x, y, location,
                 type, status, visible, active, cell)
    super(filename, width, height, fps, duration, looped, x, y)
    @location = location
    @visible = visible
    @type = type
    @status = status
    @active = active
    @path = []
    @path_counter = 0
    @keyframes = []
    @off_screen = false
    @cell = cell
  end

  def change_cell(cell)
    @cell = cell
  end

  def draw
    unless off_screen
      image = @image_array[@current_frame]
      image.draw(@x, @y, 0)
    end

    return if path.empty?
    assign_to_keyframe
  end

  def assign_to_keyframe
    if @path_counter <= @keyframes.size - 1
      @x = @keyframes[@path_counter].first
      @y = @keyframes[@path_counter].last
      @path_counter += 1
    else
      @x = @path[@path.size - 1].first
      @y = @path[@path.size - 1].last
      clear_path
    end
  end

  def update
    super
    off_camera
  end

  def selected?(mouse_x, mouse_y)
    true if mouse_x >= @x && mouse_x <= (@x + @width) &&
            mouse_y >= @y && mouse_y <= (@y + @height)
  end

  def animate_path
    return if path.empty?
    step = @path.size / 40

    step = 2 if step <= 1
    (0..@path.size).step(step) do |x|
      @keyframes << @path[x]
    end

    @keyframes.compact!
  end

  def clear_path
    @path.clear
    @keyframes.clear
    @path_counter = 0
    off_camera
  end

  def off_camera
    @off_screen = if @x.negative? || @x > Settings::SCREEN_WIDTH ||
                     @y.negative? || @y > Settings::SCREEN_HEIGHT
                    true
                  else
                    false
                  end
  end

  def change(num)
    case num
    when 0
      type = :rocker
      filename = 'assets/rocker_anim.png'
    when 1
      type = :pac
      filename = 'assets/pac_anim.png'
    when 2
      type = :pigtails
      filename = 'assets/pigtails_anim.png'
    when 3
      type = :punk
      filename = 'assets/punk_anim.png'
    when 4
      type = :nerd
      filename = 'assets/nerd_anim.png'
    when 5
      type = :nerd_girl
      filename = 'assets/nerd_girl_anim.png'
    when 6
      type = :baby
      filename = 'assets/baby_anim.png'
    when 7
      type = :lady
      filename = 'assets/lady_anim.png'
    end
    change_image(filename)
    @type = type
  end
end
