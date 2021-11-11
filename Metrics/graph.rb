require 'fc'
require 'set'
require_relative 'cell'

# A* pathfinder can only go left, right or down. An object can not go
# up nor diagonally.
class Graph
  def initialize(width, height)
    @width = width - 1
    @height = height - 1
    @grid = []

    (0..@height).each do |y|
      row = []
      (0..@width).each do |x|
        row.push(Cell.new(x, y))
      end
      @grid.push(row)
    end
  end

  def heuristic(current, target)
    [(current.x - target.x).abs, (current.y - target.y).abs].max
  end

  # does our queue include the specified cell?
  def neighbor?(queue:, cell:)
    result = queue.entries.find { |c| c.first == cell }
    result.nil? ? false : true
  end

  def get_path(path)
    route = []
    path.reverse_each do |val|
      route << [val.x, val.y]
    end
    route
  end

  def shortest_path(start_x, start_y, finish_x, finish_y, movement)
    start = @grid[start_y][start_x]
    finish = @grid[finish_y][finish_x]

    visited = Set.new # The set of cells already evaluated

    previous = {} # Previous cell in optimal path from source
    previous[start] = 0
    f_score = FastContainers::PriorityQueue.new(:min)

    # All possible ways to go in a cell
    dx = [1, 0, -1]
    dy = movement == :down ? [0, 1, 0] : [0, -1, 0]

    # Cost from start along best known path
    start.calculate_g_score(0)

    # Estimated total cost from start to finish
    f_score.push(start, start.g_score + heuristic(start, finish))

    until f_score.empty?
      current = f_score.pop # cell with smallest f_score
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
      (0..2).each do |direction|

        new_x = current.x + dx[direction]
        new_y = current.y + dy[direction]
        # Check for out of bounds
        next if new_x.negative? || new_x > @width || new_y.negative? || new_y > @height

        neighbor = @grid[new_y][new_x]

        # Check if we've been to a cell or if it is an obstacle
        next if (visited.include? neighbor) || neighbor?(queue: f_score, cell: neighbor) || neighbor.obstacle

        # traveled so far + distance to next cell vertical or horizontal
        tentative_g_score = current.g_score + 10

        # If there is a new shortest path update our priority queue (relax)
        next unless tentative_g_score < neighbor.g_score

        previous[neighbor] = current
        neighbor. calculate_g_score(tentative_g_score)
        f_score.push(neighbor, neighbor.g_score + heuristic(neighbor, finish))
      end
    end

    reset_score
    []
  end

  def find_start_when_finish_known(finish_x, finish_y, width)
    counter = 0
    outside = 0
    x = finish_x
    y = 0

    while y < finish_y
      while outside < 2
        x = (counter % 2).even? ? x - counter : x + counter

        if x >= 0 && x < width
          # generate a path
          path = shortest_path(finish_x, finish_y, x, y, :up)
          return path.last unless path.empty?

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

  def load_invisible
    invisibles = []

    @grid.each do |grid|
      grid.each do |g|
        invisibles << [g.x, g.y] if g.invisible
      end
    end
    invisibles
  end

  def set_invisible(x, y, value)
    @grid[y][x]&.invisible = value
  end

  def load_group_invisible(cells)
    raise 'You have not provided an array object!' unless cells.is_a?(Array)

    cells.each do |c|
      @grid[c.last][c.first]&.invisible = true
    end
  end

  def fetch_obstacles
    obstacles = []

    @grid.each do |grid|
      grid.each do |g|
        obstacles << [g.x, g.y] if g.obstacle
      end
    end
    obstacles
  end

  def set_obstacle(x, y, value)
    @grid[y][x]&.obstacle = value
  end

  def load_group_obstacles(cells)
    raise 'You have not provided an array object!' unless cells.is_a?(Array)

    cells.each do |c|
      @grid[c.last][c.first]&.obstacle = true
    end
  end

  def load_vacancies
    vacancies = []

    @grid.each do |grid|
      grid.each do |g|
        vacancies << [g.x, g.y] unless g.occupied
      end
    end
    vacancies
  end

  def set_vacancy(x, y, value)
    @grid[y][x]&.occupied = value
  end

  def load_group_vacancies(cells)
    raise 'You have not provided an array object!' unless cells.is_a?(Array)

    cells.each do |c|
      @grid[c.last][c.first]&.occupied = false
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
        g.calculate_g_score(Float::INFINITY)
      end
    end
  end
end
