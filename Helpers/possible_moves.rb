require_relative 'settings'

module PossibleMoves
  def self.find_obstacle_object_pairs(suitable_obstacle_objects, objects, width, map_size)
    pairs = []

    suitable_obstacle_objects.each do |obstacle| width
      if obstacle.location % width < (width - 1) # + 1
        temp = objects.find {|ob| ob.location == (obstacle.location + 1) && ob.type == obstacle.type && (ob.status == :NONE || ob.status == :GLASS || ob.status == :WOOD || ob.status == :CEMENT) }
        if !temp.nil?
          pairs << [obstacle.location, temp.location].sort
        end
      end

      if obstacle.location % width > 0 # - 1
        temp = objects.find {|ob| ob.location == (obstacle.location - 1) && ob.type == obstacle.type && (ob.status == :NONE || ob.status == :GLASS || ob.status == :WOOD || ob.status == :CEMENT) }
         if !temp.nil?
          pairs << [obstacle.location, temp.location].sort
        end
      end

      if obstacle.location % width < (width - 2) # + 2
        temp = objects.find {|ob| ob.location == (obstacle.location + 2) && ob.type == obstacle.type && (ob.status == :NONE || ob.status == :GLASS || ob.status == :WOOD || ob.status == :CEMENT) }
         if !temp.nil?
          pairs << [obstacle.location, temp.location].sort
        end
      end

      if obstacle.location % width > 1 # - 2
        temp = objects.find {|ob| ob.location == (obstacle.location - 2) && ob.type == obstacle.type && (ob.status == :NONE || ob.status == :GLASS || ob.status == :WOOD || ob.status == :CEMENT) }
        if !temp.nil?
          pairs << [obstacle.location, temp.location].sort
        end
      end

      if obstacle.location < (map_size - width) # + width
        temp = objects.find {|ob| ob.location == (obstacle.location + width) && ob.type == obstacle.type && (ob.status == :NONE || ob.status == :GLASS || ob.status == :WOOD || ob.status == :CEMENT) }
         if !temp.nil?
          pairs << [obstacle.location, temp.location].sort
        end
      end

      if obstacle.location >= width # - width
        temp = objects.find {|ob| ob.location == (obstacle.location - width) && ob.type == obstacle.type && (ob.status == :NONE || ob.status == :GLASS || ob.status == :WOOD || ob.status == :CEMENT) }
         if !temp.nil?
          pairs << [obstacle.location, temp.location].sort
        end
      end

      if obstacle.location < (map_size - (width * 2)) # + (width * 2)
        temp = objects.find {|ob| ob.location == (obstacle.location + (width * 2)) && ob.type == obstacle.type && (ob.status == :NONE || ob.status == :GLASS || ob.status == :WOOD || ob.status == :CEMENT) }
         if !temp.nil?
          pairs << [obstacle.location, temp.location].sort
        end
      end

      if obstacle.location >= width * 2 # - (width * 2)
        temp = objects.find {|ob| ob.location == (obstacle.location - (width * 2)) && ob.type == obstacle.type && (ob.status == :NONE || ob.status == :GLASS || ob.status == :WOOD || ob.status == :CEMENT) }
         if !temp.nil?
          pairs << [obstacle.location, temp.location].sort
        end
      end
    end

    return pairs.uniq
  end
  
  def self.collate_list(objects, width, urb, pair, location, location_sum)
    items = []

    temp = objects.find { |o| o.location == location + location_sum && !o.off_screen }
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
        temp = objects.find {|ob| ob.location == (o.location + 1) && ob.type == o.type && o.status == status && ob.status == status && !ob.off_screen }
        if !temp.nil?
          pairs << [o.location, temp.location].sort
        end
      end

      if o.location % width > 0 # - 1
        temp = objects.find {|ob| ob.location == (o.location - 1) && ob.type == o.type && o.status == status && ob.status == status && !ob.off_screen }
         if !temp.nil?
          pairs << [o.location, temp.location].sort
        end
      end

      if o.location % width < (width - 2) # + 2
        temp = objects.find {|ob| ob.location == (o.location + 2) && ob.type == o.type && o.status == status && ob.status == status && !ob.off_screen }
         if !temp.nil?
          pairs << [o.location, temp.location].sort
        end
      end

      if o.location % width > 1 # - 2
        temp = objects.find {|ob| ob.location == (o.location - 2) && ob.type == o.type && o.status == status && ob.status == status && !ob.off_screen }
        if !temp.nil?
          pairs << [o.location, temp.location].sort
        end
      end

      if o.location < (map_size - width) # + width
        temp = objects.find {|ob| ob.location == (o.location + width) && ob.type == o.type && o.status == status && ob.status == status && !ob.off_screen }
         if !temp.nil?
          pairs << [o.location, temp.location].sort
        end
      end

      if o.location >= width # - width
        temp = objects.find {|ob| ob.location == (o.location - width) && ob.type == o.type && o.status == status && ob.status == status && !ob.off_screen }
         if !temp.nil?
          pairs << [o.location, temp.location].sort
        end
      end

      if o.location < (map_size - (width * 2)) # + (width * 2)
        temp = objects.find {|ob| ob.location == (o.location + (width * 2)) && ob.type == o.type && o.status == status && ob.status == status && !ob.off_screen }
         if !temp.nil?
          pairs << [o.location, temp.location].sort
        end
      end

      if o.location >= width * 2 # - (width * 2)
        temp = objects.find {|ob| ob.location == (o.location - (width * 2)) && ob.type == o.type && o.status == status && ob.status == status && !ob.off_screen }
         if !temp.nil?
          pairs << [o.location, temp.location].sort
        end
      end
    end
    return pairs.uniq
  end
  
  def self.find_matches_under_obstacles(obstacles, objects, width, map_size)
    extract_obstacles = []

    obstacles.each do |obstacle|
      if [Settings::OBSTACLE_STATE.find_index(:GLASS), Settings::OBSTACLE_STATE.find_index(:WOOD), Settings::OBSTACLE_STATE.find_index(:CEMENT)].any? { |obs| obs == obstacle.status }
        tile_obstacle = objects.find { |o| o.location == obstacle.location && !o.off_screen }
        if !tile_obstacle.nil?
          extract_obstacles << tile_obstacle
        end
      end
    end

    pairs = find_obstacle_object_pairs(extract_obstacles, objects, width, map_size)
    testing_time = find_potential_matches(objects, width, map_size, pairs)
    find_potential_matches(objects, width, map_size, pairs)
    remove_suggestions(testing_time, objects, extract_obstacles, width)
  end
  
  def self.remove_suggestions(array_data, objects, glass_obstacle, width)
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
  
  def self.all_potential_matches(objects, obstacles, map_width, map)
    obstacle_matches = find_matches_under_obstacles(obstacles, objects, map_width, map.size)
    pairs = find_object_pairs(objects, map_width, map.size)
    potential_matches = find_potential_matches(objects, map_width, map.size, pairs)

    if !obstacle_matches.empty?
      obstacle_matches.each do |obs|
        potential_matches << obs
      end
    end

    potential_matches
  end
end