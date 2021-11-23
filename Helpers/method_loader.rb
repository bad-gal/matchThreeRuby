require 'gosu'
require_relative 'game_helper'
require_relative 'settings'
require_relative 'game_module'
require_relative 'urb_animation_helper'
require_relative '../Metrics/path'

module MethodLoader
  def self.create_urbs(cells, base_tiles, level_manager, obstacles)
    objects = []
    tile_sq = base_tiles.tile_square

    valid_tiles = []
    cells.each { |c| valid_tiles << c if c[:valid] }

    valid_tiles.each do |valid|
      rnd = Random.new.random_number(level_manager.urbs_in_level)
      duration = Gosu.random(9999, 15_001).to_i

      urb_hash = UrbAnimationHelper.urb_file_type(rnd)

      x = valid[:position].first
      y = valid[:position].last
      visible = :visible
      status = :NONE
      active = true

      status, visible = obstacle_status(level_manager, obstacles, valid) unless obstacles.empty?
      objects << UrbAnimation.new(urb_hash[:file], tile_sq, tile_sq, Settings::FPS, duration, true, x, y,
                                  valid[:location], urb_hash[:type], status, visible, active, valid[:cell])
    end
    objects
  end

  def self.fake_maps(level)
    case level
    when 1
      [2, 1, 10, 1, 2,
       1, 2, 2, 5, 1,
       2, 1, 11, 10, 5,
       2, 5, 4, 5, 2]
    when 2
       [2, 1, 4,
     4, 5, 5, 3, 1,
     4, 1, 3, 4, 3,
     4, 2, 1, 2, 1,
        5, 3, 3]
    when 3
      [6, 1, 3, 2, 1,
       3, 1, 13, 5, 6,
       1, 1, 3, 4, 1,
       3, 1, 3, 4, 3,
       6, 4, 2, 5, 2]
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
        3,          3,
        2, 7, 6, 6, 6,
        2, 2, 2, 2, 7]
    when 7
        [2, 1, 4,
      4, 5, 5, 3, 1,
      4, 1, 3, 4, 3,
      4, 2, 1, 2, 1,
         5, 3, 3]
    when 8
      [1,    3,    7,
       6, 4, 2, 5, 6,
       5, 5, 3, 6, 2,
       1, 1, 3, 4, 3,
       6, 4, 1, 5, 2,
       5,    3,    2]
    when 9
      [1, 2, 3, 4, 5, 4,
       4, 5, 6, 1, 4, 2,
       2,    1, 3,    6,
       6,    4, 2,    2,
       3, 1, 1, 4, 5, 2,
       5, 6, 5, 2, 2, 4]
    when 10
      [1, 4, 3, 6, 7,
       6, 4, 2, 5, 6,
       5, 5, 3, 6, 2,
       1, 1, 3, 4, 3,
       6, 4, 1, 5, 2]
    when 11
      [5, 6, 5, 4, 2, 1,
       3, 2, 3, 6, 5, 2,
       1, 2, 3, 2, 1, 6,
       5, 4, 6, 4, 5, 1,
       1, 1, 4, 6, 2, 3,
       5, 3, 5, 3, 2, 1]
    when 12
         [2, 1, 4,
       4, 5, 5, 3, 1,
       13, 1, 3, 4, 3,
       4, 2, 1, 2, 1,
          5, 3, 3]
    when 13
    when 14
      [1, 2, 3, 4, 5, 6, 1,
       5, 4, 3, 2, 1, 2, 3,
       6, 5, 4, 3, 2, 1, 1,
          1, 4, 2, 6, 4,
             4, 4, 4,
                3]
    when 15
    when 16
    when 17
    when 18
      [      3,    5,
          4, 3, 2, 1, 2,
       6, 5, 4, 3, 2, 1, 1,
       3, 1, 13, 2, 6, 4, 3,
       4, 4, 6, 6, 1, 3, 4,
          1, 2, 2, 3, 4,
             5,    3]
    when 19
    when 20
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
      urb_hash = UrbAnimationHelper.urb_file_type(v)
      x, y = valid_tiles[i][:position]

      visible = :visible
      status = :NONE
      active = true
      unless obstacles.empty?
        found = obstacles.find { |o| o.location == valid_tiles[i][:location] }
        unless found.nil?
          if level_manager.glass?
            visible = :visible
            status = :GLASS
          elsif level_manager.wood?
            visible = :visible
            status = :WOOD
          elsif level_manager.cement?
            visible = :visible
            status = :CEMENT
          end
        end
      end

      objects << UrbAnimation.new(urb_hash[:file], tile_sq, tile_sq, Settings::FPS, duration, true, x, y,
                        valid_tiles[i][:location], urb_hash[:type], status, visible, active, valid_tiles[i][:cell])
    end
    objects
  end

  def self.move_new_objects(objects, viable, urbs_in_level, graph, cells)
    GameModule.change_object_type(objects, 0, urbs_in_level)
    viable.each_with_index do |v, i|
      start = [objects[i].x, objects[i].y]
      v[:path].each_with_index do |path, num|
        position = GameHelper.find_x_y_value_of_cell(path, cells)
        next if position.empty?

        # change x position of off screen object to match entry-point
        if num.zero?
          objects[i].x = position.first
          start = [objects[i].x, objects[i].y]
        end
        objects[i].path.concat Path.new.create_path(start.first, start.last, position.first, position.last)
        start = objects[i].path.last
      end

      objects[i].active = true
      objects[i].animate_path
      objects[i].change_cell(v[:path].last)
      objects[i].location = GameHelper.find_location_of_cell(v[:path].last, cells)
      graph.set_vacancy(objects[i].cell[0], objects[i].cell[1], true)
    end
  end

  def self.join_paths(paths)
    paths
  end

  def self.identify_new_positions(graph, move_down, move_to, objects, cells)
    temp = []

    graph.load_vacancies.reverse_each do |vacancy|
      temp << vacancy
      cell = [vacancy[0], vacancy[1] - 1]
      while cell[1] >= 0
        temp << cell.dup unless graph.fetch_obstacles.include?(cell)
        change = cell[1] - 1
        cell[1] = change
      end

      m_index = 0
      cell = [vacancy[0], vacancy[1] - 1]

      while cell[1] >= 0
        if !graph.load_vacancies.include?(cell) &&
           !move_down.include?(cell) && !graph.fetch_obstacles.include?(cell)
          move_down << cell.dup
          move_to << temp[m_index].dup
          m_index += 1
        elsif !graph.load_vacancies.include?(cell) &&
              !move_down.include?(cell) && graph.fetch_obstacles.include?(cell)
          break
        end

        change = cell[1] - 1
        cell[1] = change
      end
      temp.clear
    end
    GameHelper.set_move_down_path(move_down, move_to, objects, cells)
  end

  def self.show_blocking_objects(viable_objects, graph, obstacles)
    blocking = []
    obstacle_cells = obstacles.map(&:cell)
    viable_objects.reverse_each do |obj|
      blocked = obj[:path] - graph.load_vacancies
      blocked.each do |bl|
        blocking << bl unless obstacle_cells.include?(bl)
      end
    end
    blocking.reject(&:empty?).uniq.sort.reverse
  end

  def self.blocking_affect(affect, graph, obstacles)
    blocking = []
    obstacle_cells = obstacles.map(&:cell)
    blocked = affect[:path] - graph.load_vacancies
    blocked.each do |bl|
      blocking << bl unless obstacle_cells.include?(bl)
    end
    blocking.reject(&:empty?).uniq.sort.reverse
  end

  # which paths have the blocking objects
  def self.affected_paths(viable_objects, blocking_urbs)
    affected = []
    blocking_urbs.each do |blocking|
      viable_objects.each do |viable|
        affected << viable if viable[:path].include?(blocking) && !affected.include?(viable)
      end
    end
    affected
  end

  def self.sort_paths(affected)
    affected.each_with_index do |path, i|
      a = i + 1
      (i+1).upto(affected.size - 1) do
        affected[i], affected[a] = affected[a], affected[i] if affected[a][:path].include?(path[:path].last)
        a += 1
      end
    end
    affected
  end

  def self.move_blocking_urbs(affect, _blocking_urbs, objects, cells, graph, obstacles, affected)
    arr = []

    blocking_urbs = blocking_affect(affect, graph, obstacles)
    if blocking_urbs.empty?
      # non_blocking(affect, arr, cells, graph, objects)
      affect[:path].each do |node|
        to_move = objects.find { |ob| ob.cell == node && !ob.off_screen }
        next unless to_move.nil?

        arr << to_move unless arr.include?(to_move)
        if to_move.path.empty?
          move_x = to_move.x
          move_y = to_move.y
        else
          move_x = to_move.path.last[0]
          move_y = to_move.path.last[1]
        end

        pos = GameHelper.find_x_y_value_of_cell(node, cells)
        new_path = Path.new.create_path(move_x, move_y, pos.first, pos.last)
        to_move.path.concat Path.new.create_path(move_x, move_y, pos.first, pos.last)
        move_x = pos.first
        move_y = pos.last

        if node == affect[:path].last
          to_move.animate_path
          graph.set_vacancy(affect[:path].last[0], affect[:path].last[1], true)
          to_move.location = GameHelper.find_location_of_cell(affect[:path].last, cells)
          to_move.change_cell(affect[:path].last)
        end
      end
    else
      # blocking_urbs(affect, affected, arr, blocking_urbs, cells, graph, objects)
      affect[:path].reverse_each do |node|
        if blocking_urbs.include?(node)
          to_move = objects.find { |ob| ob.cell == node && !ob.off_screen }
          unless to_move.nil?
            arr << to_move unless arr.include?(to_move)
            if to_move.path.empty?
              move_x = to_move.x
              move_y = to_move.y
            else
              move_x = to_move.path.last[0]
              move_y = to_move.path.last[1]
            end
            start = affect[:path].find_index(node)
            finish = affect[:path].find_index(affect[:path].last)
            start.upto(finish) do |inc|
              pos = GameHelper.find_x_y_value_of_cell(affect[:path][inc], cells)
              new_path = Path.new.create_path(move_x, move_y, pos.first, pos.last)
              to_move.path.concat Path.new.create_path(move_x, move_y, pos.first, pos.last)
              move_x = pos.first
              move_y = pos.last
            end
            to_move.animate_path
            graph.set_vacancy(node.first, node.last, false)
            graph.set_vacancy(affect[:path].last[0], affect[:path].last[1], true)
            to_move.location = GameHelper.find_location_of_cell(affect[:path].last, cells)
            to_move.change_cell(affect[:path].last)
            last_path_cells_matching(affected, affect[:path].last)
          end
        end
      end
    end

    arr.each(&:reset_keyframes)
  end

  def self.last_path_cells_matching(viable_objects, cell)
    viable_objects.reverse.each do |object|
      if object[:path].last == cell
        size = object[:path].size
        object[:path].delete_at(size - 1)
      end
    end
  end

  private

  def self.blocking_urbs(affect, affected, arr, blocking_urbs, cells, graph, objects)
    affect[:path].reverse_each do |node|
      if blocking_urbs.include?(node)
        to_move = objects.find { |ob| ob.cell == node && !ob.off_screen }
        unless to_move.nil?
          arr << to_move unless arr.include?(to_move)
          if to_move.path.empty?
            move_x = to_move.x
            move_y = to_move.y
          else
            move_x = to_move.path.last[0]
            move_y = to_move.path.last[1]
          end
          start = affect[:path].find_index(node)
          finish = affect[:path].find_index(affect[:path].last)
          start.upto(finish) do |inc|
            pos = GameHelper.find_x_y_value_of_cell(affect[:path][inc], cells)
            new_path = Path.new.create_path(move_x, move_y, pos.first, pos.last)
            to_move.path.concat Path.new.create_path(move_x, move_y, pos.first, pos.last)
            move_x = pos.first
            move_y = pos.last
          end
          to_move.animate_path
          graph.set_vacancy(node.first, node.last, false)
          graph.set_vacancy(affect[:path].last[0], affect[:path].last[1], true)
          to_move.location = GameHelper.find_location_of_cell(affect[:path].last, cells)
          to_move.change_cell(affect[:path].last)
          last_path_cells_matching(affected, affect[:path].last)
        end
      end
    end
  end

  def self.non_blocking(affect, arr, cells, graph, objects)
    affect[:path].each do |node|
      to_move = objects.find { |ob| ob.cell == node && !ob.off_screen }
      next unless to_move.nil?

      arr << to_move unless arr.include?(to_move)
      if to_move.path.empty?
        move_x = to_move.x
        move_y = to_move.y
      else
        move_x = to_move.path.last[0]
        move_y = to_move.path.last[1]
      end

      pos = GameHelper.find_x_y_value_of_cell(node, cells)
      new_path = Path.new.create_path(move_x, move_y, pos.first, pos.last)
      to_move.path.concat Path.new.create_path(move_x, move_y, pos.first, pos.last)
      move_x = pos.first
      move_y = pos.last

      if node == affect[:path].last
        to_move.animate_path
        graph.set_vacancy(affect[:path].last[0], affect[:path].last[1], true)
        to_move.location = GameHelper.find_location_of_cell(affect[:path].last, cells)
        to_move.change_cell(affect[:path].last)
      end
    end
  end

  def self.obstacle_status(level_manager, obstacles, valid)
    found = obstacles.find { |o| o.location == valid[:location] }
    return if found.nil?

    status = :NONE
    visible = :visible

    if level_manager.glass?
      visible = :visible
      status = :GLASS
    elsif level_manager.wood?
      visible = :visible
      status = :WOOD
    elsif level_manager.cement?
      visible = :visible
      status = :CEMENT
    end
    [status, visible]
  end
end
