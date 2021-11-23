require_relative 'game_helper'
require_relative 'urb_animation_helper'
require_relative 'settings'

module GameModule
  def self.find_automatic_matches(objects, width, map, obstacles)
    matched_details = []

    objects.each do |object|
      element = object.location
      next if object.off_screen

      temp = combine_matches(objects, element, width, map, obstacles, nil)
      matched_details << temp if !temp.nil? && !matched_details.include?(temp)
    end

    matched_details.each_with_index do |match1, i|
      matched_details.each_with_index do |match2, j|
        next if i == j

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
    # also stops any objects bouncing out if they are under
    # an obstacle and obstacle not yet broken
    obstacle_contained_in_match(obstacles, matched_details)
    matched_details
  end

  def self.get_shape(matches, width, user_select)
    size = matches.size

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
        result = (user_select.first - user_select.last).abs
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

  def self.combine_matches(objects, element, width, map, obstacles, user_selection)
    matches = []

    match = find_matches_by_column(objects, element, width, map, obstacles).sort.reverse
    matches << match unless match.empty?

    match = find_matches_by_row(objects, element, width, map, obstacles).sort.reverse
    matches << match unless match.empty?

    return nil if matches.empty?

    matches = matches.uniq.sort.reverse.flatten
    shape = get_shape(matches, width, user_selection)
    { matches: matches, shape: shape, intersects: intersected_element(matches, user_selection), special_type: load_special_type(shape) }
  end

  def self.intersected_element(matches, user_selection)
    if !user_selection.nil? && matches.size == 4
      matches.find { |el| user_selection.include?(el) }
    elsif user_selection.nil? && matches.size == 4
      matches[1]
    elsif matches.size > 4
      count = matches.select { |el| matches.count(el) > 1 }.uniq.join.to_i
      return count unless count.zero?

      return matches[2]
      # intersecting_elements = matches.size > 4 ? matches.select { |el| matches.count(el) > 1 }.uniq.join.to_i :
    end
  end

  def self.load_special_type(shape)
    treat_shape = { LINE_OF_FOUR_HORIZONTAL: :MINT_SWEET,
                    LINE_OF_FOUR_VERTICAL: :PURPLE_SWEET,
                    LINE_OF_FIVE_OR_MORE: :COOKIE,
                    L_OR_T_SHAPE: :GOBSTOPPER
    }
    treat_shape[shape]
  end

  def self.find_matches_by_column(objects, element, width, map, obstacles)
    matches = []
    row = element / width
    rows = map.size / width

    e = objects.index(objects.find { |i| i.location == element && !i.off_screen })
    urb_type = objects[e].type
    matches << element

    unless Settings::SWEET_TREATS.include?(urb_type)
      ((rows - 1) - row).times do |i|
        if map[element + (width * (i + 1))] == 1
          loc = objects.index(objects.find { |j| j.location == (element + (width * (i + 1))) && !j.off_screen })

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
          loc = objects.index(objects.find { |j| j.location == (element - (width * (i + 1))) && !j.off_screen })

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

    e = objects.index(objects.find { |i| i.location == element && !i.off_screen })
    urb_type = objects[e].type
    column = element % width
    matches << element

    unless Settings::SWEET_TREATS.include?(urb_type)
      ((width - 1) - column).times do |i|
        if map[element + (i + 1)] == 1
          loc = objects.index(objects.find { |j| j.location == (element + (i + 1)) && !j.off_screen })

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
          loc = objects.index(objects.find { |j| j.location == (element - (i + 1)) && !j.off_screen })

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
        temp = UrbAnimationHelper.animation_data(t.type)
        obj_new << UrbAnimation.new(temp[0], temp[1], temp[2], t.fps, t.duration, true, t.x, t.y, t.location, t.type, t.status, t.visible, t.active, t.cell)
      end
    end
    matched_objects_copy.concat obj_new
  end

  def self.move_objects_off_screen(matches, objects)
    positions = []

    matches.each do |m|
      t = objects.find { |o| o.location == m }
      unless t.nil?
        positions << { element: t.location, x: t.x, y: t.y }
        t.y = Settings::OFF_SCREEN_Y
      end
    end
    positions
  end

  def self.change_object_type(urb_objects, rnd_start, rnd_end)
    urb_objects.each do |uo|
      rnd = Gosu.random(rnd_start, rnd_end).to_i
      UrbAnimationHelper.change(uo, rnd)
    end
  end

  # any matches that result in sweet treats should be
  # removed from bouncing out of tilemap
  def self.remove_sweet_treat(match_details, objects)
    removable = []

    match_details.each do |details|
      next if details[:shape] == :LINE

      object = objects.find { |o| o.location == details[:intersects] && !o.off_screen }
      details[:matches].delete(object.location)

      next if object.nil?

      object.type = details[:special_type]
      UrbAnimationHelper.sweet_transformation(object)
      removable << object
    end
    removable
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

      next unless matches.include? obs.location

      obs.counter -= 1
      obs.change(obs.status)
      next if obs.counter.zero?

      # remove match element from array
      found = match_details.find { |match| match[:matches].include?(obs.location) }
      found[:matches].delete(obs.location) unless found.nil?
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
end
