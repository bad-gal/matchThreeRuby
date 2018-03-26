require 'priority_queue'
require 'set'

# A* pathfinder can only go left, right or down. An object can not go
# up nor diagonally.
class Cell
  attr_accessor :x, :y, :obstacle, :occupied, :invisible
  attr_reader :g_score

  def initialize(x, y)
    @x = x
    @y = y
    @obstacle = false
    @occupied = true
    @invisible = false
    @g_score = Float::INFINITY
  end

  def calculate_g_score(score)
    @g_score = score
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
    []
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

    start. calculate_g_score(0) # Cost from start along best known path
    # Estimated total cost from start to finish
    f_score[start] = start.g_score + heuristic(start, finish)

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

        #Check for out of bounds
        if new_x < 0 or new_x > @width or new_y < 0 or new_y > @height
          next # Try next configuration
        end

        neighbor = @grid[new_y][new_x]

        # Check if we've been to a node or if it is an obstacle
        if visited.include? neighbor or f_score.has_key? neighbor or neighbor.obstacle
          next
        end

        # traveled so far + distance to next node vertical or horizontal
        tentative_g_score = current.g_score + 10

        # If there is a new shortest path update our priority queue (relax)
        if tentative_g_score < neighbor.g_score
          previous[neighbor] =  current
          neighbor. calculate_g_score(tentative_g_score)
          f_score[neighbor] = neighbor.g_score + heuristic(neighbor, finish)
        end
      end
    end

    reset_score
    []
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

    start. calculate_g_score(0) # Cost from start along best known path
    # Estimated total cost from start to finish
    f_score[start] = start.g_score + heuristic(start, finish)

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
        # Check for out of bounds
        if new_x < 0 or new_x > @width or new_y < 0 or new_y > @height
          next # Try next configuration
        end

        neighbor = @grid[new_y][new_x]

        # Check if we've been to a cell or if it is an obstacle
        if visited.include? neighbor or f_score.has_key? neighbor or neighbor.obstacle
          next
        end

        # traveled so far + distance to next cell vertical or horizontal
        tentative_g_score = current.g_score + 10

        # If there is a new shortest path update our priority queue (relax)
        if tentative_g_score < neighbor.g_score
          previous[neighbor] =  current
          neighbor. calculate_g_score(tentative_g_score)
          f_score[neighbor] = neighbor.g_score + heuristic(neighbor, finish)
        end
      end
    end

    reset_score
    []
  end

  def get_path(path)
    route = []
    path.reverse_each do |val|
      route << [val.x, val.y]
    end
    route
  end

  def get_graph
    @grid.each do |grid|
      grid.each do |g|
        p "[#{g.x},#{g.y}]: occupied = #{g.occupied} - obstacle = #{g.obstacle} - invisible = #{g.invisible}"
      end
    end
  end

  def get_invisibles
    invisibles = []

    @grid.each do |grid|
      grid.each do |g|
        invisibles << [g.x, g.y] if g.invisible
      end
    end
    invisibles
  end

  def set_invisibles(x, y, value)
    @grid[y][x].invisible = value
  end

  def set_group_invisibles(cells)
    unless cells.is_a?(Array)
      raise 'You have not provided an array object!'
    else
      cells.each do |c|
        @grid[c.last][c.first].invisible = true
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
    obstacles
  end

  def set_obstacle(x, y, value)
    @grid[y][x].obstacle = value
  end

  def set_group_obstacles(cells)
    unless cells.is_a?(Array)
      raise 'You have not provided an array object!'
    else
      cells.each do |c|
        @grid[c.last][c.first].obstacle = true
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
    vacancies
  end

  def set_vacancy(x, y, value)
    @grid[y][x].occupied = value
  end

  def set_group_vacancies(cells)
  	unless cells.is_a?(Array)
      raise 'You have not provided an array object!'
  	else
  		cells.each do |c|
        @grid[c.last][c.first].occupied = false
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
        g. calculate_g_score(Float::INFINITY)
      end
    end
  end
end
