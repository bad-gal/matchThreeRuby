require 'bezier'

class Path
  def bezier_middle_one(start_x, start_y)
    rnd_x = Gosu.random(120, 160)
    p0 = Bezier::Point.new(start_x, start_y)
    p1 = Bezier::Point.new(100, start_y)
    p2 = Bezier::Point.new(0, 400)
    p3 = Bezier::Point.new(rnd_x, 400)
    Bezier::Bezier.new(p0, p1, p2, p3)
  end

  def bezier_middle_two
    rnd_x = Gosu.random(120, 160)
    p4 = Bezier::Point.new(rnd_x, 400)
    p5 = Bezier::Point.new(rnd_x, 300)
    p6 = Bezier::Point.new(-50, 300)
    p7 = Bezier::Point.new(-50, 400)
    Bezier::Bezier.new(p4, p5, p6, p7)
  end

  def bezier_left_one(start_x, start_y)
    rnd_x = Gosu.random(40, 70)
    p0 = Bezier::Point.new(start_x, start_y)
    p1 = Bezier::Point.new(start_x - rnd_x, start_y)
    p2 = Bezier::Point.new(start_x - rnd_x, 410)
    p3 = Bezier::Point.new(start_x, 410)
    Bezier::Bezier.new(p0, p1, p2, p3)
  end

  def bezier_left_two(start_x)
    p4 = Bezier::Point.new(start_x, 410)
    p5 = Bezier::Point.new(start_x, 300)
    p6 = Bezier::Point.new(-50, 300)
    p7 = Bezier::Point.new(-50, 410)
    Bezier::Bezier.new(p4, p5, p6, p7)
  end

  def set_up_bounce_out_middle(start_x, start_y)
    plotter_one = bezier_middle_one(start_x, start_y).run
    plotter_two = bezier_middle_two.run
    define_route(plotter_one, plotter_two)
  end

  def set_up_bounce_out_left(start_x, start_y)
    plotter_one = bezier_left_one(start_x, start_y).run
    plotter_two = bezier_left_two(start_x).run
    define_route(plotter_one, plotter_two)
  end

  def set_up_bounce_out_right(start_x, start_y)
    plotter_one = bezier_right_one(start_x, start_y).run
    plotter_two = bezier_right_two(start_x).run

    define_route(plotter_one, plotter_two)
  end

  def define_route(plotter_one, plotter_two)
    path = []
    plotter_one.each do |pl|
      path << [pl.coordinates.first.to_i, pl.coordinates.last.to_i]
    end
    path.uniq!

    plotter_two.each do |pl|
      path << [pl.coordinates.first.to_i, pl.coordinates.last.to_i]
    end
    path.uniq!
  end

  def bezier_right_one(start_x, start_y)
    rnd_x = Gosu.random(40, 70)
    p0 = Bezier::Point.new(start_x, start_y)
    p1 = Bezier::Point.new(start_x + rnd_x, start_y)
    p2 = Bezier::Point.new(start_x + rnd_x, 400)
    p3 = Bezier::Point.new(start_x, 400)
    Bezier::Bezier.new(p0, p1, p2, p3)
  end

  def bezier_right_two(start_x)
    p4 = Bezier::Point.new(start_x, 400)
    p5 = Bezier::Point.new(start_x, 300)
    p6 = Bezier::Point.new(500, 300)
    p7 = Bezier::Point.new(500, 400)
    Bezier::Bezier.new(p4, p5, p6, p7)
  end

  def create_vertical_path(start_x, start_y, end_y)
    path = []
    y = start_y
    cycle = end_y - start_y
    0.upto cycle.abs do
      path << [start_x, y]
      if y != end_y
        y < end_y ? y += 1 : y -= 1
      end
    end
    path
  end

  def create_line_path(start_x, start_y, end_x, end_y)
    path = []
    dx = (end_x - start_x).abs
    dy = (end_y - start_y).abs
    sx = start_x < end_x ? 1 : -1
    sy = start_y < end_y ? 1 : -1
    err = dx-dy

    while true
      path << [start_x, start_y]
      return path if start_x == end_x && start_y == end_y

      e2 = 2 * err

      if e2 > -dy
        err -= dy
        start_x += sx
      end

      if e2 < dx
        err += dx
        start_y += sy
      end
    end
  end

  def create_path(start_x, start_y, end_x, end_y)
    path = []
    y = start_y
    x = start_x
    cycle = end_y - start_y
    0.upto cycle.abs do
      path << [start_x, y]
      if y != end_y
        y < end_y ? y += 1 : y -= 1
      end
    end

    if start_x != end_x
      cycle = end_x - start_x
      0.upto cycle.abs do
        path << [x, y]
        if x != end_x
          x < end_x ? x += 1 : x -= 1
        end
      end
    end
    path
  end
end
