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
        pigtails_counter: 0, glass_counter: 0
      },
      min_score: 0,
      max_timer: 0,
      glass: 0
    }
    level_creator
  end

  def set_urbs_in_level
    case @level
    when 1, 3, 4, 6, 7, 8, 9, 10
      5
    when 2, 5, 11
      6
    end
  end

  def score_setter(args = {})
    @scores[:moves] = args[:moves] if args.key?(:moves)
    @scores[:minScore] = args[:minScore] if args.key?(:minScore)
    @scores[:glass] = args[:glass] if args.key?(:glass)
  end

  def level_creator
    case @level
    when 1
      score_setter(moves: 5, minScore: 1000)
    when 2
      score_setter(moves: 8, minScore: 2000)
    when 3
      score_setter(moves: 15, minScore: 3500, glass: 5)
    when 4
      score_setter(moves: 20, minScore: 4500, glass: 6)
    when 5
      score_setter(moves: 100, minScore: 6000)
    when 6
      score_setter(moves: 100, minScore: 7000)
    when 7
      score_setter(moves: 100, glass: 5)
    when 8
      score_setter(moves: 100, glass: 6)
    when 9
      score_setter(moves: 100, glass: 8)
    when 10
      score_setter(moves: 100, glass: 13)
    when 11
      score_setter(moves: 100, minScore: 7000)
    end
  end

  def move_level?
    case @level
    when 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
      return true
    end

    false
  end

  def glass?
    !@scores[:glass].zero?
  end

  def obstacles
    locations = []
    case @level
    when 3
      locations.push(15, 16, 17, 18, 19)
    when 4
      locations.push(12, 13, 14, 15, 16, 17)
    when 7
      locations.push(7, 11, 12, 13, 17)
    when 8
      locations.push(2, 7, 12, 17, 22, 27)
    when 9
      locations.push(12, 14, 15, 17, 18, 20, 21, 23)
    when 10
      locations.push(0, 1, 2, 3, 4, 5, 9, 14, 15, 19, 20, 24)
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
    when 2
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
    when 7
      [0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1,
       0]
    when 8
      [1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
       1, 1, 0, 1, 0, 1]
    when 9
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1,
       1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
    when 11
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
       1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
    end
  end

  def level_tile_map
    case @level
    when 1
      map_setter(width: 5, height: 4, map_level: map_structure)
    when 2, 3, 6, 7, 10
      map_setter(width: 5, height: 5, map_level: map_structure)
    when 4, 5
      map_setter(width: 6, height: 5, map_level: map_structure)
    when 8
      map_setter(width: 5, height: 6, map_level: map_structure)
    when 9, 11
      map_setter(width: 6, height: 6, map_level: map_structure)
    end
  end

  def add_match_score(size)
    basic = 50 * size
    bonus = size * 30

    if size == 3
      @scores[:score] += basic
    elsif size > 3
      @scores[:score] += (basic + bonus)
    end
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
  end
end
