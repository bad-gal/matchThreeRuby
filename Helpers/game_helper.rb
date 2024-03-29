module GameHelper
  def self.load_sounds
    Gosu::Song.new('sounds/freed2.mp3')
  end

  def self.load_bounce_sound
    Gosu::Song.new('sounds/pac.mp3')
  end

  def self.load_treat_bounce_sound
    Gosu::Song.new('sounds/creep.wav')
  end

  def self.load_explosion_sound
    Gosu::Song.new('sounds/explosion1.ogg')
  end

  def self.load_lightning_sound
    Gosu::Song.new('sounds/electric.wav')
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

  def self.remove_broken_obstacles(matches, obstacles, graph, level_manager)
    matches.each do |matched|
      matched.each do |m|
        found = obstacles.find { |o| o.location == m }
        next if found.nil?

        if found.counter <= 0
          graph.set_obstacle(found.cell.first, found.cell.last, false)
          level_manager.add_obstacle_score
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
    return [] if cell.empty?

    node = cells.find { |c| c[:cell] == cell }
    node[:position]
  end

  def self.find_cell_of_position(position, cells)
    node = cells.find { |c| c[:position] == position }
    node[:cell]
  end

  def self.valid_swap?(object_a, object_b)
    moveable = object_a.status && object_b.status == :NONE
    different_types = object_a.type != object_b.type || (object_a.type == object_b.type && Settings::SWEET_TREATS.include?(object_a.type))
    moveable && different_types
  end

  def self.available_paths(graph, map_width)
    vacancies = graph.load_vacancies
    available_paths = []
    vacancies.each do |nv|
      available_paths << graph.find_start_when_finish_known(nv.first, nv.last, map_width)
    end
    available_paths
  end

  def self.matches_from_hash_in_order(match_details)
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
    direction
  end

  def self.set_new_vacancy_details(objects, homeless_objects, width, cells, collapsed_matches, graph)
    new_vacancies = graph.load_vacancies
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
    return if matched_copy.empty?

    matched_copy.each_with_index do |m, i|
      direction = i % 3

      case direction
      when 0
        path = Path.new.set_up_bounce_out_left(m.x, m.y)
      when 1
        path = Path.new.set_up_bounce_out_middle(m.x, m.y)
      when 2
        path = Path.new.set_up_bounce_out_right(m.x, m.y)
      end

      m.path.concat path
      m.animate_path
      effects << Animation.new('assets/muzzle_flash.png', 50, 50, 30, 1200, false, m.x, m.y)
    end
  end

  def bounce_out_left(m)
    path = Path.new.set_up_bounce_out_left(m.x, m.y)
    m.path.concat path
  end

  def bounce_out_middle(m)
    path = Path.new.set_up_bounce_out_middle(m.x, m.y)
    m.path.concat path
  end

  def bounce_out_right(m)
    path = Path.new.set_up_bounce_out_right(m.x, m.y)
    m.path.concat path
  end

  def self.swap_check(urb_object1, urb_object2)
    urb_object1.path.concat Path.new.create_path(urb_object1.x, urb_object1.y, urb_object2.x, urb_object2.y)
    urb_object1.animate_path
    urb_object2.path.concat Path.new.create_path(urb_object2.x, urb_object2.y, urb_object1.x, urb_object1.y)
    urb_object2.animate_path
  end

  def self.move_remaining(moveable_urbs, cells, graph)
    return false if moveable_urbs.empty?

    complete = 0
    moveable_urbs.each do |moveable|
      pos = find_x_y_value_of_cell(moveable[2], cells)
      complete += 1 if moveable[0].y == pos[1]
    end

    return false unless complete == moveable_urbs.size

    moveable_urbs.each do |urb|
      graph.set_vacancy(urb[0].cell.first, urb[0].cell.last, false)
      graph.set_vacancy(urb[2].first, urb[2].last, true)
      urb[0].change_cell(urb[2])
      urb[0].location = find_location_of_cell(urb[2], cells)
      urb[0].clear_path
    end
    true
  end

  def self.set_move_down_path(move_down, move_to, objects, cells)
    raise RunTimeError, 'main.rb: set_move_down_path' unless move_down.size == move_to.size

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

  def self.most_suitable_path(vacancy, graph, map_width)
    paths = []
    unless vacancy.last.zero?
      0.upto(map_width - 1) do |x|
        paths << graph.shortest_path(x, 0, vacancy.first, vacancy.last, :down)
      end

      # element must end with the destination, otherwise delete path
      # remove any paths that contain obstacles
      paths.reverse_each do |path|
        if graph.load_vacancies.include?(path.last)
          path.each do |pa|
            paths.delete(path) if graph.fetch_obstacles.include?(pa)
          end
        else
          paths.delete(path)
        end
      end
    end

    paths.sort_by!(&:length) if paths.size > 1
    paths.first
  end

  def self.list_vacancies(vacancies, graph, map_width)
    path = []
    vacancies.each do |v|
      path << if v.last.zero?
                []
              else
                most_suitable_path(v, graph, map_width)
              end
    end
    path
  end

  def self.viable_objects2(vacancies, graph, map_width)
    path = list_vacancies(vacancies, graph, map_width)

    viable = []
    vacancies.reverse.each_with_index do |v, i|
      next if path[i].nil?

      viable << viable_path(v, path[i], graph)
    end

    # must do check if column is removed and has invisible cells above
    if viable.empty?
      exception = viable_exceptions(vacancies, graph)
      viable = exception unless exception.empty?
    end
    viable
  end

  def self.viable_path(vacancy, path_point, graph)
    if !path_point.empty?
      { vacancy: vacancy, path: path_point }
    elsif (vacancy[1]).zero? && !graph.fetch_obstacles.include?(vacancy)
      { vacancy: vacancy, path: [vacancy] }
    end
  end

  def self.viable_objects(vacancies, graph, map_width)
    path = list_vacancies(vacancies, graph, map_width)

    viable = []
    vacancies.each_with_index do |v, i|
      next if path[i].nil?

      viable << viable_path(v, path[i], graph)
    end

    # must do check if column is removed and has invisible cells above
    if viable.empty?
      exception = viable_exceptions(vacancies, graph)
      viable = exception unless exception.empty?
    end
    viable
  end

  def self.viable_exceptions(vacancies, graph)
    temp = []
    invisibles = graph.load_invisible
    vacancies.each do |vacancy|
      invisibles.each do |inv|
        arr = []
        inv.last.downto(0) do |i|
          arr << [inv.first, i]
        end
        if (invisibles & arr) == arr
          temp << { vacancy: vacancy, path: [vacancy] } if vacancy.first == inv.first && inv.last < vacancy.last
        end
      end
    end
    temp.uniq
  end

  def self.position_new_objects(returning_objects, viable, cells)
    returning_objects.each_with_index do |object, i|
      pos = find_x_y_value_of_cell(viable[i][:path].first, cells)
      object.x = pos.first
    end
  end

  def self.objects_in_place(objects)
    complete = 0

    objects.each do |object|
      complete += 1 if object.path.empty?
    end
    complete
  end
end
