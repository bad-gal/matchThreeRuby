require 'gosu'
require_relative 'game_helper'
require_relative 'settings'
require_relative 'game_module'
require_relative '../Metrics/path'

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
    end
    objects
  end

  def self.fake_maps(level)
    case level
    when 1
      [2, 1, 5, 1, 2,
       2, 3, 3, 4, 1,
       2, 4, 3, 4, 5,
       2, 5, 4, 5, 2]

    when 2
      [2, 1, 4,
       4, 5, 5, 3, 1,
       4, 1, 3, 4, 3,
       4, 2, 1, 2, 1,
       5, 3, 3]

    when 3
      [1, 1, 2, 6, 7,
       6, 1, 3, 6, 6,
       5, 1, 6, 6, 2,
       1, 4, 3, 2, 3,
       6, 1, 4, 1, 2]

    when 4
      [5, 3, 5, 4, 2, 1,
       3, 5, 3, 6, 1, 1,
       1, 2, 3, 4, 5, 5,
       5, 4, 4, 4, 3, 4,
       2, 1, 4, 5, 2, 1]

    when 5
      [5, 1, 5, 1, 2, 1,
       5, 5, 2, 2, 3, 2,
       1, 2, 3, 4, 5, 5,
       4, 4, 4, 3,
       1, 4, 5, 1]
    end
  end

  def self.fake_urbs(cells, level, base_tiles, level_manager, obstacles)
    objects = []
    tile_sq = base_tiles.tile_square

    valid_tiles = []
    cells.each do |c|
      valid_tiles << c if c[:valid]
    end

    values = fake_maps(level)

    values.each_with_index do |v, i|
      duration = Gosu.random(9999, 15_001).to_i
      urb_hash = GameHelper.urb_file_type(v)

      x = valid_tiles[i][:position].first
      y = valid_tiles[i][:position].last

      visible = :visible
      status = :NONE
      active = true
      unless obstacles.empty?
        found = obstacles.find { |o| o.location == valid_tiles[i][:location] }
        unless found.nil?
          if level_manager.glass?
            visible = :visible
            status = :GLASS
          end
        end
      end

      objects << UrbAnimation.new(urb_hash[:file], tile_sq, tile_sq,
                                  Settings::FPS, duration, true, x, y,
                                  valid_tiles[i][:location], urb_hash[:type],
                                  status, visible, active,
                                  valid_tiles[i][:cell])
    end
    objects
  end

  def self.move_new_objects(objects, viable, urbs_in_level, graph, cells)
    GameModule.change_object_type(objects, 0, urbs_in_level)
    viable.each_with_index do |v, i|
      start = [objects[i].x, objects[i].y]
      v[:path].each do |path|
        position = GameHelper.find_x_y_value_of_cell(path, cells)
        objects[i].path.concat Path.new.create_path(start.first, start.last,
                                                    position.first,
                                                    position.last)
        start = objects[i].path.last
      end
      objects[i].animate_path
      objects[i].change_cell(v[:path].last)
      objects[i].location = GameHelper.find_location_of_cell(v[:path].last,
                                                             cells)
      graph.set_vacancy(objects[i].cell[0], objects[i].cell[1], true)
    end
  end

  def self.identify_new_positions(graph, move_down, move_to, objects, cells)
    temp = []

    graph.get_vacancies.reverse_each do |vacancy|
      temp << vacancy
      cell = [vacancy[0], vacancy[1] - 1]
      while cell[1] >= 0
        temp << cell.dup unless graph.get_obstacles.include?(cell)
        change = cell[1] - 1
        cell[1] = change
      end

      m_index = 0

      cell = [vacancy[0], vacancy[1] - 1]
      while cell[1] >= 0
        if !graph.get_vacancies.include?(cell) &&
           !move_down.include?(cell) && !graph.get_obstacles.include?(cell)
          move_down << cell.dup
          move_to << temp[m_index].dup
          m_index += 1
        elsif !graph.get_vacancies.include?(cell) &&
              !move_down.include?(cell) && graph.get_obstacles.include?(cell)
          break
        end

        change = cell[1] - 1
        cell[1] = change
      end
      temp.clear
    end
    GameHelper.set_move_down_path(move_down, move_to, objects, cells)
  end

  def self.move_objects_en_route(viable_objects, objects, graph, cells)
    viable_objects.reverse_each do |object|
      object[:path].reverse_each do |path|
        unless graph.get_vacancies.include?(path)
          to_move = objects.find { |ob| ob.cell == path }
          pos = GameHelper.find_x_y_value_of_cell(object[:path].last, cells)
          to_move.path.concat Path.new.create_path(to_move.x, to_move.y,
                                                   pos.first, pos.last)
          to_move.animate_path
          # p "the path = #{path}, other is #{object[:path].last}"
          graph.set_vacancy(path.first, path.last, false)
          graph.set_vacancy(object[:path].last[0], object[:path].last[1], true)
          to_move.location =
            GameHelper.find_location_of_cell(object[:path].last, cells)
          to_move.change_cell(object[:path].last)
          size = object[:path].size
          object[:path].delete_at(size - 1)
          # p graph.get_vacancies
          # byebug
        end
      end
    end
  end

  def self.find_matches_under_glass(obstacles, objects, width, map_size)

    extract_glass_obstacles = []

    obstacles.each do |obstacle|
      if obstacle.status == Settings::OBSTACLE_STATE.find_index(:GLASS)
        glass_obstacle = objects.find { |o| o.location == obstacle.location }
        if !glass_obstacle.nil?
          extract_glass_obstacles << glass_obstacle
        end
      end
    end

    pairs = find_obstacle_object_pairs(extract_glass_obstacles, objects, width,
                                       map_size)
    find_potential_matches(objects, width, map_size, pairs)
  end


  def self.find_obstacle_object_pairs(suitable_obstacle_objects, objects, width,
                                      map_size)
    pairs = []

    suitable_obstacle_objects.each do |obstacle| width
      if obstacle.location % width < (width - 1) # + 1
        temp = objects.find {|ob| ob.location == (obstacle.location + 1) && ob.type == obstacle.type && (ob.status == :NONE || ob.status == :GLASS) }
        if !temp.nil?
          pairs << [obstacle.location, temp.location].sort
        end
      end

      if obstacle.location % width > 0 # - 1
        temp = objects.find {|ob| ob.location == (obstacle.location - 1) && ob.type == obstacle.type && (ob.status == :NONE || ob.status == :GLASS) }
         if !temp.nil?
          pairs << [obstacle.location, temp.location].sort
        end
      end

      if obstacle.location % width < (width - 2) # + 2
        temp = objects.find {|ob| ob.location == (obstacle.location + 2) && ob.type == obstacle.type && (ob.status == :NONE || ob.status == :GLASS) }
         if !temp.nil?
          pairs << [obstacle.location, temp.location].sort
        end
      end

      if obstacle.location % width > 1 # - 2
        temp = objects.find {|ob| ob.location == (obstacle.location - 2) && ob.type == obstacle.type && (ob.status == :NONE || ob.status == :GLASS) }
        if !temp.nil?
          pairs << [obstacle.location, temp.location].sort
        end
      end

      if obstacle.location < (map_size - width) # + width
        temp = objects.find {|ob| ob.location == (obstacle.location + width) && ob.type == obstacle.type && (ob.status == :NONE || ob.status == :GLASS) }
         if !temp.nil?
          pairs << [obstacle.location, temp.location].sort
        end
      end

      if obstacle.location >= width # - width
        temp = objects.find {|ob| ob.location == (obstacle.location - width) && ob.type == obstacle.type && (ob.status == :NONE || ob.status == :GLASS) }
         if !temp.nil?
          pairs << [obstacle.location, temp.location].sort
        end
      end

      if obstacle.location < (map_size - (width * 2)) # + (width * 2)
        temp = objects.find {|ob| ob.location == (obstacle.location + (width * 2)) && ob.type == obstacle.type && (ob.status == :NONE || ob.status == :GLASS) }
         if !temp.nil?
          pairs << [obstacle.location, temp.location].sort
        end
      end

      if obstacle.location >= width * 2 # - (width * 2)
        temp = objects.find {|ob| ob.location == (obstacle.location - (width * 2)) && ob.type == obstacle.type && (ob.status == :NONE || ob.status == :GLASS) }
         if !temp.nil?
          pairs << [obstacle.location, temp.location].sort
        end
      end
    end

    return pairs.uniq
  end

  def self.collate_list(objects, width, urb, pair, location, location_sum)
    items = []

    temp = objects.find { |o| o.location == location + location_sum }
    if !temp.nil?
      if temp.status == :NONE
        arr = []
        if (temp.location + location_sum) / width == temp.location / width
          arr << [temp.location + width, temp.location - width, temp.location + location_sum]
        else
          arr << [temp.location + width, temp.location - width]
        end

        arr.flatten.each do |a|
          ob = objects.find { |i| i.location == a }
          if !ob.nil?
            if ob.status == :NONE && ob.type == urb.type
              items << [ob.location, pair.first, pair.last]
            end
          end
        end
      end
    end

    return items.sort
  end

  def self.find_potential_matches(objects, width, map_size, pairs)
    potentials = []

    pairs.each do |pair|
      urb = objects.find { |o| o.location == pair.first }
      if (pair.first - pair.last).abs == 1
        if pair.first % width > 0
          temp = collate_list(objects, width, urb, pair, pair.first, -1)
          temp.each do |t|
            potentials << t
          end
        end

        if pair.last % width < (width - 1)
          temp = collate_list(objects, width, urb, pair, pair.last, 1)
          temp.each do |t|
            potentials << t
          end
        end
      end

      if (pair.first - pair.last).abs == 2
        mid_cell = objects.find { |m| m.location == pair.first + 1 }
        if !mid_cell.nil? && mid_cell.status == :NONE

          if pair.first % width > 0
            temp = objects.find { |o| o.location == pair.first - 1 }
            if !temp.nil?
              if temp.status == :NONE && temp.type == urb.type
                potentials << [temp.location, pair.first, pair.last].sort
              end
            end
          end

          if pair.first >= width
            temp = objects.find { |o| o.location == pair.first - (width - 1) }
            if !temp.nil?
              if temp.status == :NONE && temp.type == urb.type
                potentials << [temp.location, pair.first, pair.last].sort
              end
            end
          end

          if pair.first < (map_size - width)
            temp = objects.find { |o| o.location == pair.first + (width + 1) }
            if !temp.nil?
              if temp.status == :NONE && temp.type == urb.type
                potentials << [pair.first, pair.last, temp.location].sort
              end
            end
          end

          if pair.last < (width - 1)
            temp = objects.find { |o| o.location == pair.last + 1 }
            if !temp.nil?
              if temp.status == :NONE && temp.type == urb.type
                potentials << [pair.first, pair.last, temp.location].sort
              end
            end
          end
        end

      end

      if (pair.first - pair.last).abs == width
        mid_cell = objects.find { |m| m.location == (pair.first - width) }
        if !mid_cell.nil? && mid_cell.status == :NONE

          if pair.first >= (width * 2)
            temp = objects.find { |o| o.location == (pair.first - (width * 2)) }
            if !temp.nil?
              if temp.status == :NONE && temp.type == urb.type
                potentials << [pair.first, pair.last, temp.location].sort
              end
            end
          end

          if pair.first > width && pair.first % width > 0
            temp = objects.find { |o| o.location == (pair.first - (width + 1)) }
            if !temp.nil?
              if temp.status == :NONE && temp.type == urb.type
                potentials << [pair.first, pair.last, temp.location].sort
              end
            end
          end

          if pair.first % width < (width -1) && pair.first > width
            temp = objects.find { |o| o.location == (pair.first - (width - 1)) }
            if !temp.nil?
              if temp.status == :NONE && temp.type == urb.type
                potentials << [pair.first, pair.last, temp.location].sort
              end
            end
          end
        end

        mid_cell = objects.find { |m| m.location == (pair.last + width) }
        if !mid_cell.nil? && mid_cell.status == :NONE
          if pair.last < (map_size - (width * 2))
            temp = objects.find { |o| o.location == (pair.last + (width * 2)) }
            if !temp.nil?
              if temp.status == :NONE && temp.type == urb.type
                potentials << [pair.first, pair.last, temp.location].sort
              end
            end
          end

          if pair.last < (map_size - width) && pair.last % width > 0
            temp = objects.find { |o| o.location == (pair.last + (width - 1)) }
            if !temp.nil?
              if temp.status == :NONE && temp.type == urb.type
                potentials << [pair.first, pair.last, temp.location].sort
              end
            end
          end

          if pair.last < (map_size - width) && pair.last % width < (width - 1)
            temp = objects.find { |o| o.location == (pair.last + (width + 1)) }
            if !temp.nil?
              if temp.status == :NONE && temp.type == urb.type
                potentials << [pair.first, pair.last, temp.location].sort
              end
            end
          end
        end
      end

      if (pair.first - pair.last).abs == (width * 2)
        mid_cell = objects.find { |m| m.location == pair.first + width }
        if !mid_cell.nil? && mid_cell.status == :NONE
          if pair.first >= width
            temp = objects.find { |o| o.location == pair.first - width}
            if !temp.nil?
              if temp.status == :NONE && temp.type == urb.type
                potentials << [pair.first, pair.last, temp.location].sort
              end
            end
          end

          if mid_cell.location % width > 0
            temp = objects.find { |o| o.location == mid_cell.location - 1 }
            if !temp.nil?
              if temp.status == :NONE && temp.type == urb.type
                potentials << [pair.first, pair.last, temp.location].sort
              end
            end
          end

          if mid_cell.location % width < (width - 1)
            temp = objects.find { |o| o.location == mid_cell.location + 1 }
            if !temp.nil?
              if temp.status == :NONE && temp.type == urb.type
                potentials << [pair.first, pair.last, temp.location].sort
              end
            end
          end

          if pair.last < (map_size - width)
            temp = objects.find { |o| o.location == pair.last + width}
            if !temp.nil?
              if temp.status == :NONE && temp.type == urb.type
                potentials << [pair.first, pair.last, temp.location].sort
              end
            end
          end
        end
      end
    end

    potentials.reject! { |pot| pot.empty? }
    return potentials.compact.uniq
  end

  def self.find_object_pairs(objects, width, map_size, status=:NONE)
    pairs = []

    objects.each do |o| width
      if o.location % width < (width - 1) # + 1
        temp = objects.find {|ob| ob.location == (o.location + 1) && ob.type == o.type && o.status == status && ob.status == status }
        if !temp.nil?
          pairs << [o.location, temp.location].sort
        end
      end

      if o.location % width > 0 # - 1
        temp = objects.find {|ob| ob.location == (o.location - 1) && ob.type == o.type && o.status == status && ob.status == status }
         if !temp.nil?
          pairs << [o.location, temp.location].sort
        end
      end

      if o.location % width < (width - 2) # + 2
        temp = objects.find {|ob| ob.location == (o.location + 2) && ob.type == o.type && o.status == status && ob.status == status }
         if !temp.nil?
          pairs << [o.location, temp.location].sort
        end
      end

      if o.location % width > 1 # - 2
        temp = objects.find {|ob| ob.location == (o.location - 2) && ob.type == o.type && o.status == status && ob.status == status }
        if !temp.nil?
          pairs << [o.location, temp.location].sort
        end
      end

      if o.location < (map_size - width) # + width
        temp = objects.find {|ob| ob.location == (o.location + width) && ob.type == o.type && o.status == status && ob.status == status }
         if !temp.nil?
          pairs << [o.location, temp.location].sort
        end
      end

      if o.location >= width # - width
        temp = objects.find {|ob| ob.location == (o.location - width) && ob.type == o.type && o.status == status && ob.status == status }
         if !temp.nil?
          pairs << [o.location, temp.location].sort
        end
      end

      if o.location < (map_size - (width * 2)) # + (width * 2)
        temp = objects.find {|ob| ob.location == (o.location + (width * 2)) && ob.type == o.type && o.status == status && ob.status == status }
         if !temp.nil?
          pairs << [o.location, temp.location].sort
        end
      end

      if o.location >= width * 2 # - (width * 2)
        temp = objects.find {|ob| ob.location == (o.location - (width * 2)) && ob.type == o.type && o.status == status && ob.status == status }
         if !temp.nil?
          pairs << [o.location, temp.location].sort
        end
      end
    end

    status
    return pairs.uniq
  end

  def self.all_potential_matches(objects, obstacles, map_width, map)
    obstacle_matches = MethodLoader.find_matches_under_glass(obstacles,
                                                             objects,
                                                             map_width,
                                                             map.size)
    pairs = MethodLoader.find_object_pairs(objects, map_width, map.size)
    potential_matches = MethodLoader.find_potential_matches(objects,
                                                            map_width,
                                                            map.size, pairs)
    if !obstacle_matches.empty?
      obstacle_matches.each do |obs|
        potential_matches << obs
      end
    end

    potential_matches
  end
end
