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
  {file: file, type: type}
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
end
