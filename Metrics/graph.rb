require 'priority_queue'
require 'set'

# A* pathfinder can only go left, right or down. An object can not go
# up nor diagonally.
class Cell
  def initialize(x, y)
  	@x = x
  	@y = y
  	@obstacle = false
  	@occupied = true
    @invisible = false
  	@g_score = Float::INFINITY
  end

  def x()
  	return @x
  end

  def y()
  	return @y
  end

  def set_occupied(value)
  	@occupied = value
  end

  def occupied
  	return @occupied
  end

  def set_obstacle(value)
  	@obstacle = value
  end

  def set_invisible(value)
    @invisible = value
  end

  def obstacle()
  	return @obstacle
  end

  def invisible()
    return @invisible
  end

  def set_g_score(score)
  	@g_score = score
  end

  def g_score()
  	return @g_score
  end
end

class Graph
	def initialize(width, height)
		@width = width - 1
		@height = height - 1
		@grid = []

		for y in 0..@height
			row = []
			for x in 0..@width
				row.push(Cell.new(x, y))
			end
			@grid.push(row)
		end
	end

  def find_shortest_start_path(finish, width)
    path_arrays = []
    counter = 0
    outside = 0
    x = finish[0]
    y = finish[1]

    start_x = 0

    while start_x < width
      path_arrays << shortest_upward_path(finish[0], finish[1], start_x, 0)
      start_x += 1
    end

    return path_arrays.sort_by{|s| s.length }[0]
  end

  def find_best_clear_path(finish, width)
    path_arrays = []
    counter = 0
    outside = 0
    x = finish[0]
    y = finish[1]

    start_x = 0

    while start_x < width
      path_arrays << shortest_upward_path_with_no_occupants(finish[0], finish[1], start_x, 0)
      start_x += 1
    end

    path_arrays.sort_by! { |s| s.length }

    path_arrays.reverse_each do |pa|
      path_arrays.delete(pa) if pa.empty?
    end

    return path_arrays.sort_by{|s| s.length }[0]
  end

  def find_start_when_finish_known(finish_x, finish_y, width)
    counter = 0
    outside = 0
    x = finish_x
    y = 0

    while y < finish_y
      while outside < 2

        if counter % 2 == 0
          x = x - counter
        else
          x = x + counter
        end

        if x >= 0 && x < width
          #generate a path
          path = shortest_upward_path(finish_x, finish_y, x, y)
          return path.last if !path.empty?
          outside = 0
        else
          outside += 1
        end

        counter += 1
      end

      outside = 0
      counter = 0
      x = finish_x
      y += 1
    end
    return []
  end

  def shortest_upward_path(start_x, start_y, finish_x, finish_y)
    def heuristic(current, target)
        return [(current.x - target.x).abs, (current.y - target.y).abs].max
    end

    start = @grid[start_y][start_x]
    finish = @grid[finish_y][finish_x]

    visited = Set.new # The set of nodes already evaluated

    previous = {} # Previous node in optimal path from source
    previous[start] = 0
    f_score = PriorityQueue.new

    # All possible ways to go in a node
    dx = [1,  0, -1]
    dy = [0, -1,  0]

    start.set_g_score(0) # Cost from start along best known path
    f_score[start] = start.g_score + heuristic(start, finish) # Estimated total cost from start to finish

    while !f_score.empty?
      current = f_score.delete_min_return_key # Node with smallest f_score
      visited.add(current)

      if current == finish
        path = Set.new
        while previous[current]
            path.add(current)
            current = previous[current]
        end
        reset_score
        return get_path(path)
      end

      # Examine all directions for the next path to take
      for direction in 0..2

        new_x = current.x + dx[direction]
        new_y = current.y + dy[direction]

        if new_x < 0 or new_x > @width or new_y < 0 or new_y > @height #Check for out of bounds
            next # Try next configuration
        end

        neighbor = @grid[new_y][new_x]

        # Check if we've been to a node or if it is an obstacle
        if visited.include? neighbor or f_score.has_key? neighbor or neighbor.obstacle
          next
        end

        tentative_g_score = current.g_score + 10 # traveled so far + distance to next node vertical or horizontal

        # If there is a new shortest path update our priority queue (relax)
        if tentative_g_score < neighbor.g_score
          previous[neighbor] =  current
          neighbor.set_g_score(tentative_g_score)
          f_score[neighbor] = neighbor.g_score + heuristic(neighbor, finish)
        end
      end
    end

    reset_score
    return []
  end

  def shortest_upward_path_with_no_occupants(start_x, start_y, finish_x, finish_y)
    def heuristic(current, target)
        return [(current.x - target.x).abs, (current.y - target.y).abs].max
    end

    start = @grid[start_y][start_x]
    finish = @grid[finish_y][finish_x]

    visited = Set.new # The set of nodes already evaluated

    previous = {} # Previous node in optimal path from source
    previous[start] = 0
    f_score = PriorityQueue.new

    # All possible ways to go in a node
    dx = [1,  0, -1]
    dy = [0, -1,  0]

    start.set_g_score(0) # Cost from start along best known path
    f_score[start] = start.g_score + heuristic(start, finish) # Estimated total cost from start to finish

    while !f_score.empty?
      current = f_score.delete_min_return_key # Node with smallest f_score
      visited.add(current)

      if current == finish
        path = Set.new
        while previous[current]
            path.add(current)
            current = previous[current]
        end
        reset_score
        return get_path(path)
      end

      # Examine all directions for the next path to take
      for direction in 0..2

        new_x = current.x + dx[direction]
        new_y = current.y + dy[direction]

        if new_x < 0 or new_x > @width or new_y < 0 or new_y > @height #Check for out of bounds
            next # Try next configuration
        end

        neighbor = @grid[new_y][new_x]
        if visited.include? neighbor or f_score.has_key? neighbor or (neighbor.occupied && neighbor.obstacle && !neighbor.invisible) or (neighbor.occupied && !neighbor.invisible && !neighbor.obstacle)
          next
        end

        tentative_g_score = current.g_score + 10 # traveled so far + distance to next node vertical or horizontal

        # If there is a new shortest path update our priority queue (relax)
        if tentative_g_score < neighbor.g_score
          previous[neighbor] =  current
          neighbor.set_g_score(tentative_g_score)
          f_score[neighbor] = neighbor.g_score + heuristic(neighbor, finish)
        end
      end
    end

    reset_score
    return []
  end

  def shortest_path(start_x, start_y, finish_x, finish_y)

  	def heuristic(current, target)
  		return [(current.x - target.x).abs, (current.y - target.y).abs].max
  	end

  	start = @grid[start_y][start_x]
  	finish = @grid[finish_y][finish_x]

    visited = Set.new # The set of cells already evaluated

    previous = {} # Previous cell in optimal path from source
    previous[start] = 0
    f_score = PriorityQueue.new

    # All possible ways to go in a cell
    dx = [1, 0, -1]
    dy = [0, 1,  0]

    start.set_g_score(0) # Cost from start along best known path
    f_score[start] = start.g_score + heuristic(start, finish) # Estimated total cost from start to finish

    while !f_score.empty?
      current = f_score.delete_min_return_key # cell with smallest f_score
      visited.add(current)

      if current == finish
        path = Set.new

				while previous[current]
          path.add(current)
          current = previous[current]
        end
        reset_score
        return get_path(path)
      end

      # Examine all directions for the next path to take
      for direction in 0..2

        new_x = current.x + dx[direction]
        new_y = current.y + dy[direction]

        if new_x < 0 or new_x > @width or new_y < 0 or new_y > @height #Check for out of bounds
          next # Try next configuration
        end

        neighbor = @grid[new_y][new_x]

        # Check if we've been to a cell or if it is an obstacle
        if visited.include? neighbor or f_score.has_key? neighbor or neighbor.obstacle
          next
        end

        tentative_g_score = current.g_score + 10 # traveled so far + distance to next cell vertical or horizontal

        # If there is a new shortest path update our priority queue (relax)
        if tentative_g_score < neighbor.g_score
          previous[neighbor] =  current
          neighbor.set_g_score(tentative_g_score)
          f_score[neighbor] = neighbor.g_score + heuristic(neighbor, finish)
        end
      end
    end

    reset_score
    return []
  end

  def shortest_path_with_vacancies(start_x, start_y, finish_x, finish_y)

    def heuristic(current, target)
      return [(current.x - target.x).abs, (current.y - target.y).abs].max
    end

    start = @grid[start_y][start_x]
    finish = @grid[finish_y][finish_x]

    visited = Set.new # The set of cells already evaluated

    previous = {} # Previous cell in optimal path from source
    previous[start] = 0
    f_score = PriorityQueue.new

    # All possible ways to go in a cell
    dx = [1, 0, -1]
    dy = [0, 1,  0]

    start.set_g_score(0) # Cost from start along best known path
    f_score[start] = start.g_score + heuristic(start, finish) # Estimated total cost from start to finish

    while !f_score.empty?
      current = f_score.delete_min_return_key # cell with smallest f_score
      visited.add(current)

      if current == finish
        path = Set.new

        while previous[current]
          path.add(current)
          current = previous[current]
        end
        reset_score
        return get_path(path)
      end

      # Examine all directions for the next path to take
      for direction in 0..2

        new_x = current.x + dx[direction]
        new_y = current.y + dy[direction]

        if new_x < 0 or new_x > @width or new_y < 0 or new_y > @height #Check for out of bounds
          next # Try next configuration
        end

        neighbor = @grid[new_y][new_x]

        # Check if we've been to a cell or if it is an obstacle
        if visited.include? neighbor or f_score.has_key? neighbor or neighbor.occupied or neighbor.obstacle
          next
        end

        tentative_g_score = current.g_score + 10 # traveled so far + distance to next cell vertical or horizontal

        # If there is a new shortest path update our priority queue (relax)
        if tentative_g_score < neighbor.g_score
          previous[neighbor] =  current
          neighbor.set_g_score(tentative_g_score)
          f_score[neighbor] = neighbor.g_score + heuristic(neighbor, finish)
        end
      end
    end

    reset_score
    return []
  end

  def get_path(path)
    route = []

    path.reverse_each do |val|
      route << [val.x, val.y]
    end

    return route
  end

  def get_graph
    @grid.each do |grid|
      grid.each do |g|
        p "[#{g.x},#{g.y}] - occupied = #{g.occupied} - obstacle = #{g.obstacle}"
      end
    end
  end

  def get_invisibles
    invisibles = []

    @grid.each do |grid|
      grid.each do |g|
        if g.invisible
          invisibles << [g.x, g.y]
        end
      end
    end

    return invisibles
  end

  def set_invisibles(x, y, value)
    @grid[y][x].set_invisible(value)
  end

  def set_group_invisibles(cells)
    unless cells.is_a?(Array)
      raise "You have not provided an array object!"
    else
      cells.each do |c|
        @grid[c.last][c.first].set_invisible(true)
      end
    end
  end

  def get_obstacles
    obstacles = []

    @grid.each do |grid|
      grid.each do |g|
        if g.obstacle
          obstacles << [g.x, g.y]
        end
      end
    end
    return obstacles
  end

  def set_obstacle(x, y, value)
    @grid[y][x].set_obstacle(value)
  end

  def set_group_obstacles(cells)
    unless cells.is_a?(Array)
      raise "You have not provided an array object!"
    else
      cells.each do |c|
        @grid[c.last][c.first].set_obstacle(true)
      end
    end
  end

  def get_vacancies
    vacancies = []

    @grid.each do |grid|
      grid.each do |g|
        if !g.occupied
          vacancies << [g.x, g.y]
        end
      end
    end
    return vacancies
  end


  def set_vacancy(x, y, value)
    @grid[y][x].set_occupied(value)
  end

  def set_group_vacancies(cells)
  	unless cells.is_a?(Array)
  		raise "You have not provided an array object!"
  	else
  		cells.each do |c|
  			@grid[c.last][c.first].set_occupied(false)
  		end
  	end
  end

  def size
  	size = 0
  	@grid.each do |g|
  		size += g.size
  	end
  	size
  end

  def reset_score
  	@grid.each do |grid|
  		grid.each do |g|
  			g.set_g_score(Float::INFINITY)
  		end
  	end
  end

  def order_vacancies(vacancies)
    temp, order = [],[]

    vacancies.each do |v|
      temp << v.reverse
    end

    temp.each do |t|
      order << temp.max
      temp[temp.index(temp.max)] = [0,0]
    end

    order.each { |o| o.reverse! }
  end

  def group_path(start, sorted_vacancies)
    paths = []

    sorted_vacancies.each_with_index do |sv, i|
      g = shortest_path(start[i].first, start[i].last, sv.first, sv.last)
      paths << g

    end
    return paths
  end

  def sort_paths(paths)
    paths.each_with_index do |path, i|
      a = i + 1
      (i+1).upto(paths.size - 1) do
        if paths[a].include?(path.last)
          paths[i], paths[a] = paths[a], paths[i]
        end
        a += 1
      end
    end
    return paths
  end

  def order_by_occurence(paths)
    path = paths.flatten(1)
    cells = path.uniq

    order = {}

    cells.each do |cell|
      order[cell] = path.count(cell)
    end

    sorted_paths = []

    ordered_cells = order.sort_by { |_key, value| value }.to_h

    ordered_cells.each do |key, value|
      sorted_paths << paths.find { |path| path[0] == key }
    end

    sorted_paths.each(&:reverse!)
  end

  def find_occupied_cells(max_vacancy, width, remaining)
    x = max_vacancy.first
    y = max_vacancy.last

    above_vacancies = []
    while x >= 0 && y >= 0
      above_vacancies << [x,y]
      x -= 1
      if x < 0
        y -= 1
        x = width - 1
      end
    end

    p m_obstacles = get_obstacles
    p m_vacancies = get_vacancies

    above_vacancies = above_vacancies - m_obstacles - m_vacancies - remaining
    p "above_vacancies"
    p above_vacancies
  end

  #return cells in a path that are occupied
  def return_occupied_cells_in_path(path, vacant, remaining)
    occupied_cells = []

    path.each do |pa|
      if @grid[pa.first][pa.last].occupied
        occupied_cells << pa
      end
    end

    return (occupied_cells - remaining) - vacant
  end

  def move_occupied_cells_to_fill_any_vacancies(path)
    new_path = []
    temp = []

    if path.nil?
      return
    else
      path_counter = path.size - 1
      path.reverse.each do |pa|
        if @grid[pa.first][pa.last].occupied
          if pa.equal?(path[path_counter])
            p "#{ pa.last }, #{ pa.first } is occupied?"
            return
          else
            new_path << { move_from: pa, move_to: path[path_counter] }
            set_vacancy(path[path_counter].first, path[path_counter].last, true)
            path_counter -= 1
          end
        end
      end

      while path_counter >= 0
        set_vacancy(path[path_counter].first, path[path_counter].last, false)
        path_counter -= 1
      end

      new_path
    end
  end
end
