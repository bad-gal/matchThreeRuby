module UrbAnimationHelper
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
end
