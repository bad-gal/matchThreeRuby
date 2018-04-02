require_relative 'game_helper'

module GameModule
  OFF_SCREEN_Y = -300

  def self.find_automatic_matches(objects, width, map, obstacles)
    matched_details = []

    objects.each do |object|
      if object.active
        element = object.location

        if object.status == :NONE && object.y.positive?
          temp = combine_matches(objects, element, width, map, obstacles)

          if !temp.nil? && !matched_details.include?(temp)
            matched_details << temp
          end
        end
      end
    end

    matched_details.each_with_index do |match1, i|
      matched_details.each_with_index do |match2, j|
        if i != j
          if (match1[:matches] - match2[:matches]).empty? ||
             (match2[:matches] - match1[:matches]).empty?
            if match1[:matches].size >= match2[:matches].size
              matched_details.delete(match2)
            else
              matched_details.delete(match1)
            end
          end
        end
      end
    end
    obstacle_contained_in_match(obstacles, matched_details)
    matched_details
  end

  def self.get_shape(matches, width)
    size = matches.size
    user_select = nil
    # need to change user_select, I need to record finger swaps for user select

    case size
    when 3
      :LINE
    when 4
      if user_select.nil?
        if matches.first - matches.last == size - 1
          :LINE_OF_FOUR_HORIZONTAL
        else
          :LINE_OF_FOUR_VERTICAL
        end
      else
        result = (user_select.first - user.select.last).abs
        if result == 1
          :LINE_OF_FOUR_HORIZONTAL
        else
          :LINE_OF_FOUR_VERTICAL
        end
      end
    when 4..100
      if matches.first - matches.last == size - 1
        :LINE_OF_FIVE_OR_MORE
      else
        result = 0
        matches.each_with_index do |_m, i|
          result += (matches[i - 1].to_i - matches[i].to_i) if i.positive?
        end

        if result == (size - 1) * width
          :LINE_OF_FIVE_OR_MORE
        else
          :L_OR_T_SHAPE
        end
      end
    end
  end

  def self.combine_matches(objects, element, width, map, obstacles)
    matches = []
    add_match = find_matches_by_column(objects, element, width, map, obstacles).sort.reverse
    matches.concat add_match

    add_match = find_matches_by_row(objects, element, width, map, obstacles).sort.reverse
    matches.concat add_match

    return nil if matches.empty?

    matches.flatten!
    intersecting_elements = if matches.size > 3
                              matches.select { |el| matches.count(el) > 1 }.uniq
                            else
                              nil
                            end
    matches = matches.uniq.sort.reverse.flatten
    details = { matches: matches, shape: get_shape(matches, width),
    intersects: intersecting_elements, special_type: :NONE }
  end

  def self.find_matches_by_column(objects, element, width, map, obstacles)
    matches = []
    row = element / width
    rows = map.size / width

    e = objects.index(objects.find { |i| i.location == element && !i.off_screen })
    urb_type = objects[e].type
    matches << element

    ((rows - 1) - row).times do |i|
      if map[element + (width * (i + 1))] == 1
        loc = objects.index(
          objects.find { |j| j.location == (element + (width * (i + 1))) }
        )

        if !loc.nil?
          if objects[loc].type == urb_type && objects[loc].visible == :visible && objects[loc].active == true && !objects[loc].off_screen
            unless matches.include?(element + (width * (i + 1)))
              matches << element + (width * (i + 1))
            end
          else break
          end
        else break
        end
      else break
      end
    end

    row.times do |i|
      if map[element - (width * (i + 1))] == 1
        loc = objects.index(
          objects.find { |j| j.location == (element - (width * (i + 1))) }
        )

        if !loc.nil?
          if objects[loc].type == urb_type && objects[loc].visible == :visible && objects[loc].active == true && !objects[loc].off_screen
            unless matches.include?(element - (width * (i + 1)))
              matches << element - (width * (i + 1))
            end
          else break
          end
        else break
        end
      else break
      end
    end

    if matches.size < 3
      matches.clear
    else
      matches.sort!.reverse!
    end
    matches
  end

  def self.find_matches_by_row(objects, element, width, map, obstacles)
    matches = []

    e = objects.index(objects.find { |i| i.location == element })
    urb_type = objects[e].type
    column = element % width

    matches << element

    ((width - 1) - column).times do |i|
      if map[element + (i + 1)] == 1
        loc = objects.index(
          objects.find { |j| j.location == (element + (i + 1)) }
        )

        if !loc.nil?
          if objects[loc].type == urb_type && objects[loc].visible == :visible && objects[loc].active == true && !objects[loc].off_screen
            unless matches.include?(element + (i + 1))
              matches << element + (i + 1)
            end
          else break
          end
        else break
        end
      else break
      end
    end

    column.times do |i|
      if map[element - (i + 1)] == 1
        loc = objects.index(
          objects.find { |j| j.location == (element - (i + 1)) }
        )

        if !loc.nil?
          if objects[loc].type == urb_type && objects[loc].visible == :visible && objects[loc].active == true && !objects[loc].off_screen
            unless matches.include?(element - (i + 1))
              matches << element - (i + 1)
            end
          else break
          end
        else break
        end
      else break
      end
    end

    if matches.size < 3
      matches.clear
    else
      matches.sort!.reverse!
    end
    matches
  end

  def self.set_matched_objects(matches, objects)
    matched_objects_copy = []
    obj_new = []

    matches.each do |m|
      t = objects.find { |o| o.location == m }
      unless t.nil?
        temp = animation_data(t.type)
        obj_new << UrbAnimation.new(temp[0], temp[1], temp[2], t.fps, t.duration, true, t.x, t.y, t.location, t.type, t.status, t.visible, t.active, t.cell)
      end
    end
    matched_objects_copy.concat obj_new
  end

  def self.animation_data(type)
    filename = ''
    w = 42
    h = 42
    case type
    when :pac
      filename = 'assets/pac_anim.png'
    when :lady
      filename = 'assets/lady_anim.png'
    when :punk
      filename = 'assets/punk_anim.png'
    when :baby
      filename = 'assets/baby_anim.png'
    when :nerd
      filename = 'assets/nerd_anim.png'
    when :rocker
      filename = 'assets/rocker_anim.png'
    when :nerd_girl
      filename = 'assets/nerd_girl_anim.png'
    when :pigtails
      filename = 'assets/pigtails_anim.png'
    end
    [filename, w, h]
  end

  def self.move_objects_off_screen(matches, objects)
    positions = []

    matches.each do |m|
      t = objects.find { |o| o.location == m }
      unless t.nil?
        positions << { element: t.location, x: t.x, y: t.y }
        t.y = OFF_SCREEN_Y
      end
    end
    positions
  end

  def self.change_object_type(urb_objects, rnd_start, rnd_end)
    urb_objects.each do |uo|
      rnd = Gosu.random(rnd_start, rnd_end).to_i
      uo.change(rnd)
    end
  end

  def self.obstacle_contained_in_match(obstacles, match_details)
    matches = []
    match_details.each do |match|
      match[:matches].each do |m|
        matches << m
      end
    end

    return if obstacles.empty?
    obstacles.each do |obs|
      next unless [Settings::OBSTACLE_STATE.find_index(:GLASS), Settings::OBSTACLE_STATE.find_index(:WOOD), Settings::OBSTACLE_STATE.find_index(:CEMENT)].any? { |obstacle| obstacle == obs.status }
      if matches.include? obs.location
        obs.counter -= 1
        obs.change(obs.status)
        unless obs.counter.zero?
          # remove match element from array
          found = match_details.find { |match| match[:matches].include?(obs.location) }
          unless found.nil?
            found[:matches].delete(obs.location)
          end
        end
      end
    end
  end

  def self.delete_obstacles(obstacles, objects, obstacle_locations)
    return if obstacles.empty?
    obstacles.delete_if do |o|
      if o.animation_finished
        urb = objects.find { |u| u.location == o.location }
        urb.status = :NONE unless urb.nil?
        obstacle_locations.delete(o.location)
      end
    end
  end

  def self.objects_to_shuffle(objects)
    results = objects.find_all { |o| o.status == :NONE && o.y > 0 }

    cells = []
    results.each do |result|
      cells << result.cell
    end

    cells.shuffle!
    [results, cells]
  end

  def self.check_shuffle(objects, cells)
    object_shuffle = objects_to_shuffle(objects)
    object_shuffle[0].each_with_index do |obj, i|
      destination = GameHelper::find_x_y_value_of_cell(object_shuffle[1][i], cells)
      if !(obj.x == destination.first && obj.y == destination.last)
        obj.path.concat Path.new.create_path(obj.x, obj.y, destination.first, destination.last)
        obj.animate_path
      end
    end
    object_shuffle
  end
end
