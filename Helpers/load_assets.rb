# frozen_string_literal: true

# Load Assets
module LoadAssets
  def self.load_sounds
    Gosu::Song.new('sounds/freed2.mp3')
  end

  def self.load_bounce_sound
    Gosu::Song.new('sounds/pac.mp3')
  end

  def self.load_treat_bounce_sound
    Gosu::Song.new('sounds/creep.wav')
  end

  def self.load_explosion_sound
    Gosu::Song.new('sounds/explosion1.ogg')
  end

  def self.load_lightning_sound
    Gosu::Song.new('sounds/electric.wav')
  end
end
