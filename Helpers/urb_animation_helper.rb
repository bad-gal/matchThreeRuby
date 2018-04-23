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
        cookie_selection = basic_cookie(result.first, urb, objects, obstacles)
        sfx = cookie_effects(result.first, cookie_selection.first[:matches], objects)
        return [cookie_selection, sfx, [result.first]]
      when :GOBSTOPPER
        basic_gobstopper(result.first)
      end
    else # double treats
      if result.first.type == result.last.type
        case result.first.type
        when :MINT_SWEET, :PURPLE_SWEET
          double_stripe_sweet(result.first, result.last)
        when :COOKIE
          double_cookie(result.first, result.last)
        when :GOBSTOPPER
          double_gobstopper(result.first, result.last)
        end
      elsif [result.first.type, result.last.type].all? { |o| [:MINT_SWEET, :PURPLE_SWEET] }
        double_stripe_sweet(result.first, result.last)
      elsif [result.first.type, result.last.type].all? { |o| [:MINT_SWEET, :COOKIE] }
        sweet_cookie(result.first, result.last)
      elsif [result.first.type, result.last.type].all? { |o| [:MINT_SWEET, :GOBSTOPPER] }
        sweet_gobstopper(result.first, result.last)
      elsif [result.first.type, result.last.type].all? { |o| [:PURPLE_SWEET, :COOKIE] }
        sweet_cookie(result.first, result.last)
      elsif [result.first.type, result.last.type].all? { |o| [:PURPLE_SWEET, :GOBSTOPPER] }
        sweet_gobstopper(result.first, result.last)
      elsif [result.first.type, result.last.type].all? { |o| [:COOKIE, :GOBSTOPPER] }
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
      matches = objects.find_all { |o| o.location / width == loc && o.location != object.location }.map { |o| o.location }
    else # vertical
      loc = object.location % width
      matches = objects.find_all { |o| o.location % width == loc && o.location != object.location }.map { |o| o.location }
    end
    matched_details = [{ matches: matches, shape: :LINE, intersects: nil, special_type: nil }]
    GameModule.obstacle_contained_in_match(obstacles, matched_details)
    matched_details
  end

  #--------------------------------------------------------------
  # identify the objects that need to bounce out from cookie swap
  #--------------------------------------------------------------
  def self.basic_cookie(object, urb, objects, obstacles)
    matches = objects.find_all{ |obj| obj.type == urb.type }.map{ |o| o.location }
    matched_details = [{ matches: matches, shape: :LINE, intersects: nil, special_type: nil }]
    GameModule.obstacle_contained_in_match(obstacles, matched_details)
    matched_details
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
    sweet_fade(object)
    [SpecialFX.new('assets/lightning2r.png', x, y, fps, duration, 2, object.type)]
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
    sweet_fade(object)
    [SpecialFX.new('assets/lightning2r.png', x, y, fps, duration, 2, object.type)]
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
    sweet_fade(object)
    [SpecialFX.new('assets/lightning2r.png', x, y, fps, duration, match_locations.size, object.type, positions)]
  end

  def self.double_stripe_sweet(object1, object2)
  end

  def self.double_cookie(object1, object2)
  end

  def self.double_gobstopper(object1, object2)
  end

  def self.basic_gobstopper(object)
  end

  def self.sweet_cookie(object1, object2)
  end

  def self.sweet_gobstopper(object1, object2)
  end

  def self.cookie_gobstopper(object1, object2)
  end
end
