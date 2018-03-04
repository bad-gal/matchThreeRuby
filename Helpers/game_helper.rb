module GameHelper
  def self.load_sounds
    Gosu::Sample.new('sounds/freed2.mp3')
  end

  def self.convert_matches_to_cells(matches, objects, level_manager)
    match_cells = []

    matches.each do |matched|
      arr = []
      matched.each do |m|
        temp = objects.find { |o| o.location == m }
        unless temp.nil?
          arr << temp.cell
          level_manager.add_to_urb_counter(temp.type)
        end
      end
      match_cells << arr
      level_manager.add_match_score(matched.size)
    end
    match_cells
  end

  def self.remove_broken_obstacles(matches, obstacles, graph)
    matches.each do |matched|
      matched.each do |m|
        found = obstacles.find { |o| o.location == m }
        next if found.nil?
        if found.counter <= 0
          graph.set_obstacle(found.cell.first, found.cell.last, false)
        end
      end
    end
  end

  def self.get_starting_point(cell_vacancies, graph, map_width)
    starting_point = []

    cell_vacancies.each do |cv|
      temp = []
      cv.each do |c|
        path = []
        path << graph.find_start_when_finish_known(c.first, c.last, map_width)
        sub_arr = path - cv
        temp += if sub_arr.empty?
                  [nil]
                else
                  sub_arr
                end
      end
      starting_point << temp
    end

    starting_point
  end

  def self.find_location_of_cell(cell, cells)
    node = cells.find { |c| c[:cell] == cell }
    return node[:location] unless node.nil?
  end

  def self.find_cell_of_location(location, cells)
    node = cells.find { |c| c[:location] == location }
    return node[:cell] unless node.nil?
  end

  def self.find_x_y_value_of_cell(cell, cells)
    node = cells.find { |c| c[:cell] == cell }
    node[:position]
  end

  def self.find_cell_of_position(position, cells)
    node = cells.find { |c| c[:position] == position }
    node[:cell]
  end

  def self.valid_swap?(object_a, object_b)
    !(object_a.status != :NONE || object_b.status != :NONE) &&
      object_a.type != object_b.type
  end

  def self.available_paths(graph, map_width)
    vacancies = graph.get_vacancies
    puts "vacancies  = #{vacancies}"
    available_paths = []
    vacancies.each do |nv|
      available_paths << graph.find_start_when_finish_known(nv.first, nv.last,
                                                            map_width)
    end
    available_paths
  end

  def self.return_matches_from_hash_in_order(match_details)
    match_temp = []

    match_details.each do |md|
      match_temp << md[:matches]
    end

    temp = match_temp.collect(&:max)
    temp.sort!.reverse!

    matches = []
    temp.each do |t|
      matches << match_temp.find { |mt| mt.include?(t) }
    end
    matches
  end

  def self.urb_file_type(number)
    case number
    when 0
      file = 'assets/rocker_anim.png'
      type = :rocker
    when 1
      file = 'assets/pac_anim.png'
      type = :pac
    when 2
      type = :pigtails
      file = 'assets/pigtails_anim.png'
    when 3
      type = :punk
      file = 'assets/punk_anim.png'
    when 4
      type = :nerd
      file = 'assets/nerd_anim.png'
    when 5
      type = :nerd_girl
      file = 'assets/nerd_girl_anim.png'
    when 6
      type = :baby
      file = 'assets/baby_anim.png'
    when 7
      type = :lady
      file = 'assets/lady_anim.png'
    end
    { file: file, type: type }
  end

  def self.decide_direction(primary_direction, vacancies)
    vacancy_columns = []
    vacancies.each { |v| vacancy_columns << v.first }
    direction = nil

    if primary_direction.uniq.length == 1 && !primary_direction.first.nil?
      if vacancy_columns.max <= primary_direction[0].first
        direction = :left
      elsif vacancy_columns.max > primary_direction[0].first &&
            vacancy_columns.min >= primary_direction[0].first
        direction = :right
      elsif vacancy_columns.max > primary_direction[0].first &&
            vacancy_columns.min < primary_direction[0].first
        direction = :both
      end
    elsif primary_direction.uniq.length > 1
      direction = :multiple
    end
    puts "direction = #{direction}"
    puts "vacancy_columns = #{vacancy_columns}"
    puts "primary_direction = #{primary_direction}"
    direction
  end

  def self.set_new_vacancy_details(objects, homeless_objects, width, cells,
                                   collapsed_matches, graph)
    new_vacancies = graph.get_vacancies
    new_vacancy_details = []

    new_vacancies.each_with_index do |nv, i|
      t_path = graph.find_start_when_finish_known(nv.first, nv.last, width)
      if !t_path.empty? || nv.last.zero?
        new_vacancy_details << {
          location: find_location_of_cell(nv, cells),
          position: find_x_y_value_of_cell(nv, cells),
          cell: nv
        }
      else
        obj = objects.find { |o| o.location == collapsed_matches[i] }
        unless obj.nil?
          obj.active = false
          homeless_objects << obj
        end
      end
    end

    [new_vacancy_details, new_vacancies]
  end

  def self.bounce_out_setup(matched_copy, effects)
    unless matched_copy.empty?
      matched_copy.each_with_index do |m, i|
        direction = i % 3
        case direction
        when 0
          path = Path.new.set_up_bounce_out_left(m.x, m.y)
          m.path.concat path
        when 1
          path = Path.new.set_up_bounce_out_middle(m.x, m.y)
          m.path.concat path
        when 2
          path = Path.new.set_up_bounce_out_right(m.x, m.y)
          m.path.concat path
        end

        m.animate_path
        effects << Animation.new('assets/muzzle_flash.png', 50, 50, 30, 1200,
                                 false, m.x, m.y)
      end
    end
  end

  def self.swap_check(urb_object1, urb_object2)
    urb_object1.path.concat Path.new.create_path(urb_object1.x,
                                                 urb_object1.y,
                                                 urb_object2.x,
                                                 urb_object2.y)
    urb_object1.animate_path

    urb_object2.path.concat Path.new.create_path(urb_object2.x,
                                                 urb_object2.y,
                                                 urb_object1.x,
                                                 urb_object1.y)
    urb_object2.animate_path
  end

  def self.move_remaining(moveable_urbs, cells, graph)
    return false if moveable_urbs.empty?

    complete = 0
    moveable_urbs.each do |moveable|
      pos = find_x_y_value_of_cell(moveable[2], cells)
      complete += 1 if moveable[0].y == pos[1]
    end

    if complete == moveable_urbs.size
      moveable_urbs.each do |urb|
        graph.set_vacancy(urb[0].cell.first, urb[0].cell.last, false)
        graph.set_vacancy(urb[2].first, urb[2].last, true)
        urb[0].change_cell(urb[2])
        urb[0].location = find_location_of_cell(urb[2], cells)
        urb[0].clear_path
      end
      return true
    end
  end

  def self.set_move_down_path(move_down, move_to, objects, cells)
    raise RunTimeError, 'main.rb: set_move_down_path' unless move_down.size ==
                                                             move_to.size
    moveable_urbs = []
    move_down.each_with_index do |md, i|
      urb = objects.find { |o| o.cell == md }
      unless urb.nil?
        pos = find_x_y_value_of_cell(move_to[i], cells)
        urb.path.concat Path.new.create_vertical_path(urb.x, urb.y, pos[1])
        urb.animate_path
        moveable_urbs << [urb, pos, move_to[i]]
      end
    end

    moveable_urbs
  end
end
