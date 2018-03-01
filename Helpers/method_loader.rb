require 'gosu'
require_relative 'game_helper'
require_relative 'settings'

module MethodLoader

  def self.create_urbs(cells, base_tiles, level_manager, obstacles)
    objects = []
    tile_sq = base_tiles.tile_square

    valid_tiles = []
    cells.each do |c|
      valid_tiles << c if c[:valid]
    end

    valid_tiles.each do |valid|
      rnd = Random.new.random_number(level_manager.urbs_in_level)
      duration = Gosu.random(9999, 15_001).to_i

      urb_hash = GameHelper.urb_file_type(rnd)

      x = valid[:position].first
      y = valid[:position].last
      visible = :visible
      status = :NONE
      active = true

      unless obstacles.empty?
        found = obstacles.find { |o| o.location == valid[:location] }
        unless found.nil?
          if level_manager.glass?
            visible = :visible
            status = :GLASS
          end
        end
      end
      objects << UrbAnimation.new(urb_hash[:file], tile_sq, tile_sq,
                                  Settings::FPS, duration, true, x, y,
                                  valid[:location], urb_hash[:type], status,
                                  visible, active, valid[:cell])
                                  # filename, width, height, fps, duration, looped, x, y
    end
    objects
  end

  def fake_urbs(cells, fps, level)
    @objects = []
    values = []
    tile_sq = @base_tiles.tile_square

    valid_tiles = []

    cells.each do |c|
      valid_tiles << c if c[:valid]
    end

    case level
    when 1
      values += [2, 1, 1, 1, 2,
                 3, 2, 3, 4, 1,
                 2, 4, 3, 4, 5,
                 3, 5, 4, 5, 2]
    when 2
      values += [2, 1, 4,
                 5, 5, 5, 3, 1,
                 4, 1, 3, 5, 4,
                 4, 2, 4, 2, 1,
                 5, 3, 3]

    when 3
      values += [1, 4, 3, 6, 7,
                 6, 3, 3, 2, 6,
                 5, 6, 3, 6, 2,
                 1, 4, 3, 6, 3,
                 6, 1, 1, 1, 2]

    when 4
      values += [5, 3, 5, 4, 2, 1,
                 3, 5, 3, 6, 1, 1,
                 1, 2, 3, 4, 5, 5,
                 5, 4, 4, 4, 3, 4,
                 2, 1, 4, 5, 2, 1]

    when 5
      values += [5, 1, 5, 1, 2, 1,
                 5, 5, 2, 2, 3, 2,
                 1, 2, 3, 4, 5, 5,
                 4, 4, 4, 3,
                 1, 4, 5, 1]
    end

    values.each_with_index do |v, i|
      duration = Gosu.random(9999, 15_001).to_i
      urb_hash = GameHelper.urb_file_type(v)

      x = valid_tiles[i][:position].first
      y = valid_tiles[i][:position].last

      visible = :visible
      status = :NONE
      active = true
      unless @obstacles.empty?
        found = @obstacles.find { |o| o.location == valid_tiles[i][:location] }
        unless found.nil?
          if @level_manager.glass?
            visible = :visible
            status = :GLASS
          end
        end
      end

      @objects << UrbAnimation.new(urb_hash[:file], tile_sq, tile_sq, fps,
                                   duration, true, x, y,
                                   valid_tiles[i][:location], urb_hash[:type],
                                   status, visible, active,
                                   valid_tiles[i][:cell])
    end
  end

end
