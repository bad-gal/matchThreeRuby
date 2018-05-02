require_relative 'game_module'

module UrbAnimationHelper

  #------------------------------------------------------
  # change urb based on type
  #------------------------------------------------------
  def self.change(object, num)
    case num
    when 0
      type = :rocker
      filename = 'assets/rocker_anim.png'
    when 1
      type = :pac
      filename = 'assets/pac_anim.png'
    when 2
      type = :pigtails
      filename = 'assets/pigtails_anim.png'
    when 3
      type = :punk
      filename = 'assets/punk_anim.png'
    when 4
      type = :nerd
      filename = 'assets/nerd_anim.png'
    when 5
      type = :nerd_girl
      filename = 'assets/nerd_girl_anim.png'
    when 6
      type = :baby
      filename = 'assets/baby_anim.png'
    when 7
      type = :lady
      filename = 'assets/lady_anim.png'
    end
    object.change_image(filename)
    object.type = type
  end

  #------------------------------------------------------
  # change urb animation to bounced image
  #------------------------------------------------------
  def self.bounce_image(object)
    case object.type
    when :rocker
      filename = 'assets/rocker_bounce.png'
    when :pac
      filename = 'assets/pac_bounce.png'
    when :pigtails
      filename = 'assets/pigtails_bounce.png'
    when :punk
      filename = 'assets/punk_bounce.png'
    when :nerd
      filename = 'assets/nerd_bounce.png'
    when :nerd_girl
      filename = 'assets/nerd_girl_bounce.png'
    when :baby
      filename = 'assets/baby_bounce.png'
    when :lady
      filename = 'assets/lady_bounce.png'
    end
    object.change_image(filename)
    object.add_frame_data(5, Settings::BOUNCE_DURATION, Settings::BOUNCE_FPS)
  end

  #------------------------------------------------------
  # change urb animation file based on type, change frame rates
  #------------------------------------------------------
  def self.regular_image(object)
    case object.type
    when :rocker
      filename = 'assets/rocker_anim.png'
    when :pac
      filename = 'assets/pac_anim.png'
    when :pigtails
      filename = 'assets/pigtails_anim.png'
    when :punk
      filename = 'assets/punk_anim.png'
    when :nerd
      filename = 'assets/nerd_anim.png'
    when :nerd_girl
      filename = 'assets/nerd_girl_anim.png'
    when :baby
      filename = 'assets/baby_anim.png'
    when :lady
      filename = 'assets/lady_anim.png'
    end
    object.change_image(filename)
    object.add_frame_data(5, Gosu.random(9999, 15_001).to_i, Settings::FPS)
  end

  #------------------------------------------------------
  # change urb animation file based on type
  #------------------------------------------------------
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

  #------------------------------------------------------
  # change urb animation file based on number
  #------------------------------------------------------
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
    when 10
      type = :MINT_SWEET
      file = 'assets/mint_sweet.png'
    when 11
      type = :PURPLE_SWEET
      file = 'assets/purple_sweet.png'
    when 12
      type = :COOKIE
      file = 'assets/cookie.png'
    when 13
      type = :GOBSTOPPER
      file = 'assets/gobstopper.png'
    end
    { file: file, type: type }
  end

  #------------------------------------------------------
  # sweet treat animation files
  #------------------------------------------------------
  def self.sweet_transformation(object)
    case object.type
    when :MINT_SWEET
      filename = 'assets/mint_sweet.png'
    when :PURPLE_SWEET
      filename = 'assets/purple_sweet.png'
    when :GOBSTOPPER
      filename = 'assets/gobstopper.png'
    when :COOKIE
      filename = 'assets/cookie.png'
    end
    object.change_image(filename)
  end

  #------------------------------------------------------
  # fade animation for sweet treats
  #------------------------------------------------------
  def self.sweet_fade(object)
    case object.type
    when :MINT_SWEET
      filename = 'assets/mint_sweet_fade.png'
    when :PURPLE_SWEET
      filename = 'assets/purple_sweet_fade.png'
    when :GOBSTOPPER
      filename = 'assets/gobstopper_fade.png'
    when :COOKIE
      filename = 'assets/cookie_fade.png'
    end
    object.add_frame_data(5, Settings::BOUNCE_DURATION, Settings::BOUNCE_FPS)
    object.change_image_and_loop(filename, false)
  end

  #------------------------------------------------------
  # assign the right method depending on the sweet treats
  #------------------------------------------------------
  def self.special_treat(object1, object2, objects, width, height, obstacles)
    p "This is a special treat"
    result = []
    arr = [object1, object2]

    arr.each do |ar|
      result << ar if Settings::SWEET_TREATS.include?(ar.type)
    end

    if result.size == 1
      case result.first.type

      when :MINT_SWEET
        sfx = horizontal_effects(result.first)
        return [basic_stripe_sweet(result.first, objects, width, obstacles), sfx, [result.first]]

      when :PURPLE_SWEET
        sfx = vertical_effects(result.first)
        return [basic_stripe_sweet(result.first, objects, width, obstacles), sfx, [result.first]]

      when :COOKIE
        urb = arr.find{ |a| !Settings::SWEET_TREATS.include?(a.type) }
        cookie_selection = basic_cookie(urb, objects, obstacles)
        sfx = cookie_effects(result.first, cookie_selection.first[:matches], objects)
        return [cookie_selection, sfx, [result.first]]

      when :GOBSTOPPER
        bomb_positions = basic_gobstopper(object1, object2, width, objects, obstacles)
        sfx = bomb_effects(object1)
        return [bomb_positions, sfx, [result.first]]
      end
    else

      if [result.first.type, result.last.type].all? { |o| [:MINT_SWEET, :PURPLE_SWEET].include?(o) }
        sfx = []
        mint = nil
        purple = nil
        if result.first.type == result.last.type
          mint = result.first
          mint.type = :MINT_SWEET unless mint.type == :MINT_SWEET
          purple = result.last
          purple.type = :PURPLE_SWEET unless purple.type == :PURPLE_SWEET
        else
          mint = [result.first, result.last].find{ |r| r.type == :MINT_SWEET }
          purple = [result.first, result.last].find{ |r| r.type == :PURPLE_SWEET }
        end
        sfx << horizontal_effects(mint)
        sfx << vertical_effects(purple)
        return [double_stripe_sweet(mint, purple, objects, width, obstacles), sfx, [result.first, result.last]]

      elsif [result.first.type, result.last.type].all? { |o| [:COOKIE].include?(o) }
        cookie_selection = double_cookie(result.first, result.last, objects, obstacles)
        match = cookie_selection.first[:matches]
        cookie_tin = match.each_slice((match.size/2.0).round).to_a
        sfx = []
        sfx << cookie_effects(result.first, cookie_tin.first, objects)
        sfx << cookie_effects(result.last, cookie_tin.last, objects)
        return [cookie_selection, sfx, [result.first, result.last]]

      elsif [result.first.type, result.last.type].all? { |o| [:GOBSTOPPER].include?(o) }
        sfx = []
        bomb_positions = basic_gobstopper(object1, object2, width, objects, obstacles)
        sfx << bomb_effects(result.first)
        sfx << bomb_effects(result.last)
        return [bomb_positions, sfx, [result.first, result.last]]

      elsif [result.first.type, result.last.type].all? { |o| [:MINT_SWEET, :COOKIE].include?(o) || [:PURPLE_SWEET, :COOKIE].include?(o) }

        sfx = []
        details = []

        cookie = result.find{ |o| o.type == :COOKIE }
        cookie_selection = sweet_cookie(result.first, result.last, objects, obstacles)
        cookie_selection.each do |biscuit|
          sfx << horizontal_effects(biscuit)
          details << basic_stripe_sweet(biscuit, objects, width, obstacles).map{ |o| o[:matches] }
        end
        matched_details = [{ matches: details.flatten.uniq.sort, shape: :LINE, intersects: nil, special_type: nil }]
        cookie_selection << result.first
        cookie_selection << result.last
        return [matched_details, sfx, cookie_selection]

      elsif [result.first.type, result.last.type].all? { |o| [:MINT_SWEET, :GOBSTOPPER].include?(o) } ||
            [result.first.type, result.last.type].all? { |o| [:PURPLE_SWEET, :GOBSTOPPER].include?(o) }
        sfx = []
        direction = (result.first.location - result.last.location).abs
        if direction == 1
          result.first.type = :PURPLE_SWEET
          result.last.type = :PURPLE_SWEET
          sfx << vertical_effects(result.first)
          sfx << vertical_effects(result.last)
          result.first.type = :MINT_SWEET
          sfx << horizontal_effects(result.first)
        end
        return [sweet_gobstopper(result.first, result.last, width, objects, obstacles), sfx, [result.first, result.last]]

      elsif [result.first.type, result.last.type].all? { |o| [:PURPLE_SWEET, :COOKIE].include?(o) [result.first, result.last] }
        sweet_cookie(result.first, result.last)

      elsif [result.first.type, result.last.type].all? { |o| [:COOKIE, :GOBSTOPPER].include?(o) }
        cookie_gobstopper(result.first, result.last)
      end
    end
  end

  #--------------------------------------------------------------------
  # identify the objects that need to bounce out from stripe sweet swap
  #--------------------------------------------------------------------
  def self.basic_stripe_sweet(object, objects, width, obstacles)
    if object.type == :MINT_SWEET # horizontal
      loc = object.location / width
      matches = objects.find_all { |o| o.location / width == loc && o.location != object.location && !Settings::SWEET_TREATS.include?(o.type)}.map { |o| o.location }
    else # vertical
      loc = object.location % width
      matches = objects.find_all { |o| o.location % width == loc && o.location != object.location && !Settings::SWEET_TREATS.include?(o.type)}.map { |o| o.location }
    end
    matched_details = [{ matches: matches, shape: :LINE, intersects: nil, special_type: nil }]
    GameModule.obstacle_contained_in_match(obstacles, matched_details)
    matched_details
  end

  #--------------------------------------------------------------
  # identify the objects that need to bounce out from cookie swap
  #--------------------------------------------------------------
  def self.basic_cookie(urb, objects, obstacles)
    matches = objects.find_all{ |obj| obj.type == urb.type }.map{ |o| o.location }
    matched_details = [{ matches: matches, shape: :LINE, intersects: nil, special_type: nil }]
    GameModule.obstacle_contained_in_match(obstacles, matched_details)
    matched_details
  end

  #------------------------------------------------------------------
  # identify the objects that need to bounce out from gobstopper swap
  #------------------------------------------------------------------
  def self.basic_gobstopper(object1, object2, width, objects, obstacles)
    direction = (object1.location - object2.location).abs
    p matches = bomb_matrix(object1, object2, direction, width, objects, obstacles)
    matched_details = [{ matches: matches, shape: :LINE, intersects: nil, special_type: nil }]
    GameModule.obstacle_contained_in_match(obstacles, matched_details)
    matched_details
  end

  #------------------------------------------------------------------
  # identify the objects that need to bounce out from double stripe sweet
  #------------------------------------------------------------------
  def self.double_stripe_sweet(object1, object2, objects, width, obstacles)
    matches = []

    loc = object1.location / width
    matches << objects.find_all { |o| o.location / width == loc && !Settings::SWEET_TREATS.include?(o.type) && o.location != object1.location }.map { |o| o.location }

    loc = object2.location % width
    matches << objects.find_all { |o| o.location % width == loc && !Settings::SWEET_TREATS.include?(o.type) && o.location != object2.location }.map { |o| o.location }

    matches.flatten!.uniq
    matched_details = [{ matches: matches, shape: :LINE, intersects: nil, special_type: nil }]
    GameModule.obstacle_contained_in_match(obstacles, matched_details)
    matched_details
  end

  #------------------------------------------------------------------
  # identify the objects that need to bounce out from double cookie
  #------------------------------------------------------------------
  def self.double_cookie(object1, object2, objects, obstacles)
    p matches = objects.find_all{ |obj| ![object1.location, object2.location].include?(obj.location) }.map{ |o| o.location }
    matched_details = [{ matches: matches, shape: :LINE, intersects: nil, special_type: nil }]
    GameModule.obstacle_contained_in_match(obstacles, matched_details)
    matched_details
  end

  #------------------------------------------------------------------
  # identify the objects that need to bounce out from sweet gobstopper
  #------------------------------------------------------------------
  def self.sweet_gobstopper(object1, object2, width, objects, obstacles)
    matches = []
    # need to do something with gobstopper as it is not included in match but needs to be removed from tilemap
    [object1, object2].each do |object|
      loc = object.location % width
      matches << objects.find_all { |o| o.location % width == loc }.map { |o| o.location }
      loc = object.location / width
      matches << objects.find_all { |o| o.location / width == loc }.map { |o| o.location }
    end
    matches.flatten!.uniq!.sort

    [object1, object2].each do |object|
      found = matches.find{ |m| m == object.location }
      matches.delete(found)
    end
    matched_details = [{ matches: matches.sort, shape: :LINE, intersects: nil, special_type: nil }]
    GameModule.obstacle_contained_in_match(obstacles, matched_details)
    matched_details
  end

  #------------------------------------------------------------------
  # identify the objects that need to bounce out from sweet cookie
  #------------------------------------------------------------------
  def self.sweet_cookie(object1, object2, objects, obstacles)
    urb = objects.find_all{ |urb| !Settings::SWEET_TREATS.include?(urb.type) }.sample
    collective = objects.find_all{ |o| o.type == urb.type }
    treat = [object1, object2].find{ |o| o.type != :COOKIE }
    cookie_transformation(collective, treat.type)
    sweet_fade(object1)
    sweet_fade(object2)
    collective
    # p matches = collective.map{ |o| o.location }.sort
    # matched_details = [{ matches: matches, shape: :LINE, intersects: nil, special_type: nil }]
    # GameModule.obstacle_contained_in_match(obstacles, matched_details)
    # matched_details
  end

  def self.cookie_transformation(list, type)
    list.each do |l|
      l.type = type
      sweet_transformation(l)
    end
  end

  #------------------------------------------------------------------
  # identify the objects that need to bounce out from cookie gobstopper
  #------------------------------------------------------------------
  def self.cookie_gobstopper(object1, object2)
  end

  #------------------------------------------------------------------
  # collect a list of valid locations to bomb 4x3 grid
  # or 3x4 grid depending on direction
  #------------------------------------------------------------------
  def self.bomb_matrix(object1, object2, direction, width, objects, obstacles)
    arr = []

    if object1.location > object2.location
      l2 = object1.location
      l1 = object2.location
    else
      l1 = object1.location
      l2 = object2.location
    end

    if direction == 1
      arr << matrix_horizontal_left(l1, width, objects)
      arr << matrix_horizontal_right(l2, width, objects)
    elsif direction == width
      arr << matrix_vertical_left(l1, width, objects)
      arr << matrix_vertical_right(l2, width, objects)
    end
    arr.flatten.uniq.sort
  end

  #------------------------------------------------------------------
  # horizontal left list of max 2 x 3 locations that form the bomb matrix
  #------------------------------------------------------------------
  def self.matrix_horizontal_left(l1, width, objects)
    arr = []
    arr << l1
    arr << l1 - 1 if l1 % width > 0 && objects.find{ |o| o.location == l1 - 1 && !o.off_screen }
    arr << l1 + width if objects.find { |o| o.location == l1 + width && !o.off_screen }
    arr << l1 + (width - 1) if l1 % width > 0 && objects.find{ |o| o.location == l1 + (width - 1) && !o.off_screen }
    arr << l1 - width if l1 >= width && objects.find{ |o| o.location == l1 - width && !o.off_screen }
    arr << l1 - (width + 1) if (l1 / width) - (l1 - (width + 1)) / width == 1 && objects.find{ |o| o.location == l1 - (width + 1) && !o.off_screen }
    arr
  end

  #------------------------------------------------------------------
  # horizontal right list of max 2 x 3 locations that form the bomb matrix
  #------------------------------------------------------------------
  def self.matrix_horizontal_right(l2, width, objects)
    arr = []
    arr << l2
    arr << l2 + 1 if l2 % width < (width - 1) && objects.find{ |o| o.location == l2 + 1 && !o.off_screen }
    arr << l2 + width if objects.find { |o| o.location == l2 + width && !o.off_screen }
    arr << l2 + (width + 1) if l2 % width < (width - 1) && objects.find{ |o| o.location == l2 + (width + 1) && !o.off_screen }
    arr << l2 - width if l2 >= width && objects.find{ |o| o.location == l2 - width && !o.off_screen }
    arr << l2 - (width - 1) if (l2 / width) != (l2 - (width - 1)) / width && objects.find{ |o| o.location == l2 - (width - 1) && !o.off_screen }
    arr
  end

  #------------------------------------------------------------------
  # vertical left list of max 2 x 3 locations that form the bomb matrix
  #------------------------------------------------------------------
  def self.matrix_vertical_left(l1, width, objects)
    arr = []
    arr << l1
    arr << l1 - 1 if l1 % width > 0 && objects.find{ |o| o.location == l1 - 1 && !o.off_screen }
    arr << l1 + 1 if l1 % width < (width - 1) && objects.find{ |o| o.location == l1 + 1 && !o.off_screen }
    arr << l1 - width if l1 >= width && objects.find{ |o| o.location == l1 - width && !o.off_screen }
    arr << l1 - (width + 1) if (l1 / width) - (l1 - (width + 1)) / width == 1 && objects.find{ |o| o.location == l1 - (width + 1) && !o.off_screen }
    arr << l1 - (width - 1) if (l1 / width) != (l1 - (width - 1)) / width && objects.find{ |o| o.location == l1 - (width - 1) && !o.off_screen }
    arr
  end

  #------------------------------------------------------------------
  # vertical right list of max 2 x 3 locations that form the bomb matrix
  #------------------------------------------------------------------
  def self.matrix_vertical_right(l2, width, objects)
    arr = []
    arr << l2
    arr << l2 - 1 if l2 % width > 0 && objects.find{ |o| o.location == l2 - 1 && !o.off_screen }
    arr << l2 + 1 if l2 % width < (width - 1) && objects.find{ |o| o.location == l2 + 1 && !o.off_screen }
    arr << l2 + width if objects.find { |o| o.location == l2 + width && !o.off_screen }
    arr << l2 + (width + 1) if l2 % width < (width - 1) && objects.find{ |o| o.location == l2 + (width + 1) && !o.off_screen }
    arr << l2 + (width - 1) if (l2 / width) != (l2 + (width - 1)) / width && objects.find{ |o| o.location == l2 + (width - 1) && !o.off_screen }
    arr
  end

  #----------------------------------------------------------
  # calculate the purple sweet special effects
  #----------------------------------------------------------
  def self.vertical_effects(object)
    x = object.x
    y = object.y + 31
    fps = Settings::FPS
    duration = 5000
    looped = false
    frames = 2
    sweet_fade(object)
    [SpecialFX.new('assets/lightning2r.png', x, y, fps, duration, frames, 2, object.type)]
  end

  #----------------------------------------------------------
  # calculate the mint sweet special effects
  #----------------------------------------------------------
  def self.horizontal_effects(object)
    x = object.x + 21
    y = object.y + 42
    fps = Settings::FPS
    duration = 5000
    looped = false
    frames = 2
    sweet_fade(object)
    [SpecialFX.new('assets/lightning2r.png', x, y, fps, duration, frames, 2, object.type)]
  end

  #----------------------------------------------------------
  # calculate the cookie special effects
  #----------------------------------------------------------
  def self.cookie_effects(object, match_locations, objects)
    positions = []
    match_locations.each do |ml|
      positions << objects.find{ |o| o.location == ml }
    end
    positions = positions.map{ |po| [po.x, po.y] }
    p positions
    x = object.x + 21
    y = object.y + 21
    fps = Settings::FPS
    duration = 5000
    looped = false
    frames = 2
    sweet_fade(object)
    [SpecialFX.new('assets/lightning2r.png', x, y, fps, duration, frames, match_locations.size, object.type, positions)]
  end

  #----------------------------------------------------------
  # calculate the gobstopper special effects
  #----------------------------------------------------------
  def self.bomb_effects(object)
    [SpecialFX.new('assets/explosion.png', object.x, object.y, Settings::BOUNCE_FPS, 2000, 16, 1, object.type)]
  end
end
