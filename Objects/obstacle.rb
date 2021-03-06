require_relative 'animation'
require_relative '../Helpers/settings'

class Obstacle < Animation
  attr_reader :visibility, :num_til_destroyed, :location, :cell
  attr_accessor :image, :status, :counter

  def initialize(filename, width, height, fps, duration, looped, x, y, status,
                 location, cell, visibility)
    super(filename, width, height, fps, duration, looped, x, y)
    @location = location
    @cell = cell
    @status = status
    @old_status = status
    @visibility = visibility
    @num_til_destroyed = number_til_destroyed(@status)
    @counter = @num_til_destroyed
  end

  def number_til_destroyed(status)
    case status
    when Settings::OBSTACLE_STATE.find_index(:NONE)
      0
    when Settings::OBSTACLE_STATE.find_index(:GLASS)
      1
    when Settings::OBSTACLE_STATE.find_index(:WOOD)
      2
    when Settings::OBSTACLE_STATE.find_index(:CEMENT)
      4
    end
  end

  def clear_status
    @status = Settings::OBSTACLE_STATE.find_index(:NONE)
  end

  def change(type)
    case type
    when Settings::OBSTACLE_STATE.find_index(:GLASS)
      filename = 'assets/glass_anim.png'
      looped = false
      change_image_and_loop(filename, looped)
    when Settings::OBSTACLE_STATE.find_index(:WOOD)
      if @counter.zero?
        filename = 'assets/wood_break_anim.png'
        looped = false
        change_image_and_loop(filename, looped)
      elsif @counter == 1
        filename = 'assets/wood_25.png'
        change_image(filename)
      end
    when Settings::OBSTACLE_STATE.find_index(:CEMENT)
      if @counter.zero?
        filename = 'assets/cement_break_anim.png'
        looped = false
        change_image_and_loop(filename, looped)
      elsif @counter == 1
        filename = 'assets/cement_25.png'
        change_image(filename)
      elsif @counter == 2
        filename = 'assets/cement_50.png'
        change_image(filename)
      elsif @counter == 3
        filename = 'assets/cement_75.png'
        change_image(filename)
      end
    end
  end
end
