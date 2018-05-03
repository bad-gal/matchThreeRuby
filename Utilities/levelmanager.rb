class Levelmanager
  attr_reader :scores, :urbs_in_level

  def initialize(level_number)
    @level = level_number
    @urbs_in_level = set_urbs_in_level
    @scores = {
      score: 0,
      moves: 0,
      counters: {
        pac_counter: 0, baby_counter: 0, nerd_counter: 0, lady_counter: 0,
        punk_counter: 0, rocker_counter: 0, girl_nerd_counter: 0,
        pigtails_counter: 0, glass_counter: 0, wood_counter: 0,
        cement_counter: 0, urb_counter: 0
      },
      min_score: 0,
      max_timer: 0,
      glass: 0,
      wood: 0,
      cement: 0
    }
    level_creator
  end

  def set_urbs_in_level
    case @level
    when 1, 3, 4, 6, 7, 8, 9, 10, 12, 13
      5
    when 2, 5, 11, 14, 15, 17, 18, 19, 20
      6
    when 16
      7
    end
  end

  def score_setter(args = {})
    @scores[:moves] = args[:moves] if args.key?(:moves)
    @scores[:min_score] = args[:min_score] if args.key?(:min_score)
    @scores[:glass] = args[:glass] if args.key?(:glass)
    @scores[:wood] = args[:wood] if args.key?(:wood)
    @scores[:cement] = args[:cement] if args.key?(:cement)
  end

  def level_creator
    case @level
    when 1
      score_setter(moves: 5, min_score: 1000)
    when 2
      score_setter(moves: 8, min_score: 2000)
    when 3
      score_setter(moves: 15, glass: 5)
    when 4
      score_setter(moves: 20, min_score: 4500, glass: 6)
    when 5
      score_setter(moves: 20, min_score: 5000)
    when 6
      score_setter(moves: 10, min_score: 3000)
    when 7
      score_setter(moves: 6, glass: 5)
    when 8
      score_setter(moves: 16, glass: 8)
    when 9
      score_setter(moves: 25, glass: 8)
    when 10
      score_setter(moves: 10, min_score: 5500, glass: 10)
    when 11
      score_setter(moves: 28, min_score: 7000, glass: 16)
    when 12
      score_setter(moves: 20, wood: 5)
    when 13
      score_setter(moves: 25, min_score: 1500, cement: 1)
    when 14
      score_setter(moves: 30, wood: 4)
    when 15
      score_setter(moves: 20, cement: 3)
    when 16
      score_setter(moves: 22, min_score: 8000)
    when 17
      score_setter(moves: 25, wood: 5)
    when 18
      score_setter(moves: 30, cement: 5)
    when 19
      score_setter(moves: 100, min_score: 6050, urb_counter: 35)
    when 20
      score_setter(moves: 100, urb_counter: 50)
    end
  end

  def level_completed?
    case @level
    when 1, 2, 5, 6, 16
      if @scores[:score] >= @scores[:min_score]
       return :success
      elsif @scores[:moves] == 0
       return :fail
      end
    when 3, 7, 8, 9
      if @scores[:glass_counter] ==  @scores[:glass]
        return :success
      elsif @scores[:moves] == 0
        return :fail
      end
    when 4, 10, 11
      if @scores[:glass_counter] == @scores[:glass] && @scores[:score] >= @scores[:min_score]
        return :success
      elsif @scores[:moves] == 0
        return :fail
      end
    when 12
      if @scores[:wood_counter] == @scores[:wood]
        return :success
      elsif @scores[:moves] == 0
        return :fail
      end
    when 13
      if @scores[:cement_counter] == @scores[:cement] && @scores[:score] >= @scores[:min_score]
        return :success
      elsif @scores[:moves] == 0
        return :fail
      end
    when 14, 17
      if @scores[:wood_counter] >= @scores[:wood]
        return :success
      elsif @scores[:moves] == 0
        return :fail
      end
    when 15, 18
      if @scores[:cement_counter] == @scores[:cement]
        return :success
      elsif @scores[:moves] == 0
        return :fail
      end
    when 19
      if @scores[:score] >= @scores[:min_score] && @scores[:counters][:urb_counter] >= 35
       return :success
      elsif @scores[:moves] == 0
       return :fail
      end
    when 20
      if @scores[:counters][:urb_counter] >= 50
        return :success
      elsif @scores[:moves] == 0
        return :fail
      end
    end
    :pending
  end

  def move_level?
    case @level
    when 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20
      return true
    end
    false
  end

  def glass?
    !@scores[:glass].zero?
  end

  def wood?
    !@scores[:wood].zero?
  end

  def cement?
    !@scores[:cement].zero?
  end

  def obstacles
    locations = []
    case @level
    when 3, 12
      locations.push(15, 16, 17, 18, 19)
    when 4
      locations.push(12, 13, 14, 15, 16, 17)
    when 7
      locations.push(7, 11, 12, 13, 17)
    when 8
      locations.push(6, 8, 11, 13, 16, 18, 21, 23)
    when 9
      locations.push(12, 14, 15, 17, 18, 20, 21, 23)
    when 10
      locations.push(0, 4, 5, 9, 10, 14, 15, 19, 20, 24)
    when 11
      locations.push(2, 6, 7, 8, 9, 10, 11, 14, 20, 24, 25, 26, 27, 28, 29, 32)
    when 13
      locations.push(17)
    when 14
      locations.push(14, 20, 22, 26, 30, 32, 38)
    when 15
      locations.push(23, 24, 25)
    when 17
      locations.push(22, 23, 24, 25, 26)
    when 18
      locations.push(10, 17, 24, 31, 38)
    end
    locations
  end

  def deduct_move
    @scores[:moves] -= 1
  end

  def map_setter(args = {})
    map_width = args[:width] if args.key?(:width)
    map_height = args[:height] if args.key?(:height)
    map_level = args[:map_level] if args.key?(:map_level)
    [map_level, map_width, map_height]
  end

  def map_structure
    case @level
    when 1
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
    when 2, 7, 12
      [0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1,
       0]
    when 3, 10
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
       1]
    when 4
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
       1, 1, 1, 1, 1, 1]
    when 5
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0,
       0, 1, 1, 1, 1, 0]
    when 6
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
       1]
    when 8
      [1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
       1, 1, 0, 1, 0, 1]
    when 9
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1,
       1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
    when 11
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
       1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
    when 13
      [0, 0, 1, 0, 0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
       1, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0]
    when 14
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1,
       1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0]
    when 15
      [0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1,
       1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0]
    when 16
      [1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1,
       1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1]
    when 17
      [0, 0, 1, 0, 1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
       1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0]
    when 18
      [0, 0, 1, 0, 1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
       1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0]
    when 19
      [1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1,
       0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1]
    when 20
      [1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1,
       0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1]
    end
  end

  def level_tile_map
    case @level
    when 1
      map_setter(width: 5, height: 4, map_level: map_structure)
    when 2, 3, 6, 7, 10, 12
      map_setter(width: 5, height: 5, map_level: map_structure)
    when 4, 5
      map_setter(width: 6, height: 5, map_level: map_structure)
    when 8
      map_setter(width: 5, height: 6, map_level: map_structure)
    when 9, 11
      map_setter(width: 6, height: 6, map_level: map_structure)
    when 13
      map_setter(width: 5, height: 7, map_level: map_structure)
    when 14
      map_setter(width: 7, height: 6, map_level: map_structure)
    when 15, 16, 17, 18, 20
      map_setter(width: 7, height: 7, map_level: map_structure)
    when 19
      map_setter(width: 6, height: 7, map_level: map_structure)
    end
  end

  def add_match_score(size)
    basic = 50 * size
    bonus = size * 30

    if size <= 3
      @scores[:score] += basic
    elsif size > 3
      @scores[:score] += (basic + bonus)
    end
  end

  def add_obstacle_score
    @scores[:score] += 200 if glass?
    @scores[:score] += 350 if wood?
    @scores[:score] += 600 if cement?
  end

  def add_treat_score(quantity)
    @scores[:score] += (800 * quantity)
  end

  def add_to_urb_counter(type)
    case type
    when :pac
      @scores[:counters][:pac_counter] += 1
    when :pigtails
      @scores[:counters][:pigtails_counter] += 1
    when :nerd
      @scores[:counters][:nerd_counter] += 1
    when :girl_nerd
      @scores[:counters][:girl_nerd_counter] += 1
    when :rocker
      @scores[:counters][:rocker_counter] += 1
    when :lady
      @scores[:counters][:lady_counter] += 1
    when :baby
      @scores[:counters][:baby_counter] += 1
    when :punk
      @scores[:counters][:punk_counter] += 1
    end
    urb_calculation
  end

  def urb_calculation
    @scores[:counters][:urb_counter] = @scores[:counters][:pac_counter] + @scores[:counters][:pigtails_counter] +
    @scores[:counters][:nerd_counter] + @scores[:counters][:girl_nerd_counter] + @scores[:counters][:rocker_counter] +
    @scores[:counters][:lady_counter] + @scores[:counters][:baby_counter] + @scores[:counters][:punk_counter]
  end
end
