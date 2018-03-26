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
      [1, 4, 3, 6, 7,
       6, 4, 2, 6, 6,
       5, 1, 3, 6, 2,
       1, 4, 3, 4, 3,
       6, 1, 4, 1, 2]

    when 4
      [5, 3, 5, 4, 2, 1,
       3, 5, 3, 6, 1, 2,
       1, 2, 3, 4, 1, 1,
       5, 4, 4, 4, 5, 1,
       1, 1, 4, 1, 2, 3]

    when 5
      [5, 1, 5, 1, 2, 1,
       5, 5, 2, 2, 3, 2,
       1, 2, 3, 4, 5, 5,
       4, 4, 4, 3,
       1, 4, 5, 1]

    when 6
       [4, 4, 6, 3, 2,
        4, 2, 7, 3, 4,
        3, 3,
        2, 7, 6, 7, 3,
        7, 2, 2, 4, 6]
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
      v[:path].each_with_index do |path, num|
        position = GameHelper.find_x_y_value_of_cell(path, cells)
        unless position.empty?
          # change x position of off screen object to match entry-point
          if num.zero?
            objects[i].x = position.first
            start = [objects[i].x, objects[i].y]
          end
          objects[i].path.concat Path.new.create_path(start.first, start.last,
                                                      position.first,
                                                      position.last)
          start = objects[i].path.last
        end
      end

      objects[i].active = true
      objects[i].animate_path
      objects[i].change_cell(v[:path].last)
      objects[i].location = GameHelper.find_location_of_cell(v[:path].last,
                                                             cells)
      graph.set_vacancy(objects[i].cell[0], objects[i].cell[1], true)
    end
  end

  def self.join_paths(paths)
    paths
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

  def self.show_blocking_objects(viable_objects, graph)
    blocking = []

    viable_objects.reverse_each do |obj|
      "blocking objects = #{obj[:path]} and #{graph.get_vacancies}"
      blocking << obj[:path] - graph.get_vacancies
    end
    p "blocking objects -> ", blocking.reject(&:empty?).uniq
    blocking.reject(&:empty?).uniq.flatten(1)
  end

  # which paths have the blocking objects
  def self.affected_paths(viable_objects, blocking_urbs)
    affected = []
    blocking_urbs.each do |blocking|
      viable_objects.each do |viable|
        if viable[:path].include?(blocking) && !affected.include?(viable)
          affected << viable
        end
      end
    end
    affected
  end

  def self.blocking_objects(path, graph)
    p path - graph.get_vacancies
  end

  def self.sort_paths(affected)
    affected.each_with_index do |path, i|
      a = i + 1
      (i+1).upto(affected.size - 1) do
        if affected[a][:path].include?(path[:path].last)
          affected[i], affected[a] = affected[a], affected[i]
        end
        a += 1
      end
    end
    return affected
  end

  # only move the blocked objects -> [[2, 3], [2, 2], [2, 1]], affected -> subset of viable
  def self.move_blocking_urbs(affected, blocking_urbs, objects, cells, graph)
    p "...move_blocking_urbs"
    blocking_urbs.each do |blocking|
      p viable = affected.find{ |obj| obj[:path].include?(blocking) }
      to_move = objects.find { |ob| ob.cell == blocking }
      unless to_move.nil?
        p pos = GameHelper.find_x_y_value_of_cell(viable[:path].last, cells)
        to_move.path.concat Path.new.create_path(to_move.x, to_move.y, pos.first, pos.last)
        to_move.animate_path
        graph.set_vacancy(blocking.first, blocking.last, false)
        graph.set_vacancy(viable[:path].last[0], viable[:path].last[1], true)
        to_move.location = GameHelper.find_location_of_cell(viable[:path].last, cells)
        to_move.change_cell(viable[:path].last)
        find_last_path_cells_that_match(affected, viable[:path].last)
      end
    end
  end

  def self.change_route(viable_objects, objects, cells, graph, returning_objects)
    new_vacancies = []

    viable_objects.reverse.each_with_index do |object, i|
      # p object[:vacancy]
      object[:path].reverse_each do |path|
        unless graph.get_vacancies.include?(path)
          to_move = objects.find { |ob| ob.cell == path }
          p object[:vacancy]
          p to_move.path.size
          to_move.clear_path if to_move.path.size > 0

          pos = GameHelper.find_x_y_value_of_cell(object[:path].last, cells)
          to_move.path.concat Path.new.create_path(to_move.x, to_move.y, pos.first, pos.last)
          to_move.animate_path
          graph.set_vacancy(path.first, path.last, false)
          graph.set_vacancy(object[:path].last[0], object[:path].last[1], true)
          to_move.location = GameHelper.find_location_of_cell(object[:path].last, cells)
          to_move.change_cell(object[:path].last)
          size = object[:path].size
          object[:path].delete_at(size - 1)
          find_last_path_cells_that_match(viable_objects, object[:path].last, i)
        end
      end
    end
    # finally check if any of the last paths are the same if so delete the last path
    viable_objects.each_with_index do |vv, i|
      if (i + 1) < viable_objects.size
        if viable_objects[i][:path].last == viable_objects[i+1][:path].last
          size = viable_objects[i][:path].size
          viable_objects[i][:path].delete_at(size - 1)
        end
      end
    end

    viable_objects.sort_by!{ |vv| vv[:path].last }
    p "viable objects -> ", viable_objects
  end

  def self.find_last_path_cells_that_match(viable_objects, cell)
    viable_objects.reverse.each_with_index do |object, i|
      if object[:path].last == cell #&& i != exclusion
        p "path is #{object[:path]}"
        p "match found at #{object[:vacancy]}"
        size = object[:path].size
        object[:path].delete_at(size - 1)
      end
    end
  end

  def self.move_objects_en_route(viable_objects, objects, graph, cells)
    viable_objects.reverse_each do |object|
      object[:path].reverse_each do |path|
        p "blocked", blocking_objects(path, graph)
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
    testing_time = find_potential_matches(objects, width, map_size, pairs)

    find_potential_matches(objects, width, map_size, pairs)
    mytest(testing_time, objects, extract_glass_obstacles, width)
  end

  def self.mytest(array_data, objects, glass_obstacle, width)
    array_data.reverse.each do |arr|
      locations = glass_obstacle.map(&:location)
      glass_finder = arr.find_all { |a| locations.include?(a) }
      unless glass_finder.empty?
        g = glass_finder.first
        if !(arr.include?(g + width) || arr.include?(g - width) ||
            arr.include?(g - (width + 1)) || arr.include?(g - (width - 1)) ||
            arr.include?(g + (width + 1)) || arr.include?(g + (width - 1)) ||
            arr.include?(g + 1) || arr.include?(g - 1) ||
            arr.include?(g - 2) || arr.include?(g - 2) ||
            arr.include?(g + 2) || arr.include?(g + 2))
          array_data.delete(arr)
        end
      end
    end
    array_data
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

  def self.find_obstacle_potential_matches(objects, width, map_size, pairs)
    potentials = []

    pairs.each do |pair|
      obstacle = objects.find { |o| o.location == pair.first }
      if (pair.first - pair.last).abs == 1
        if pair.first % width > 0

        end
      end
    end


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
