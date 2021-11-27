require_relative '../game'

RSpec.describe Game do
  let(:game) { Game.new }

  describe '.new' do
    it 'returns a Game object' do
      expect(game).to be_an_instance_of(Game)
      expect(game.caption).to eq 'Urbies'
    end
  end

  describe '.draw' do
    it 'draws the game instancw' do
      expect(game).to receive(:draw)
      game.draw
    end
  end

  describe '.update' do
    it 'updates the game instance' do
      expect(game).to receive(:update)
      game.update
    end
  end

  describe '.play_level' do
    it 'sets the screen instance to Main' do
      screen = game.instance_variable_get(:@screen)
      allow(screen).to receive(:button_clicked).and_return(2)
      game.play_level

      updated_screen = game.instance_variable_get(:@screen)
      expect(updated_screen.class).to eq Main
    end
  end

  describe '.play_game' do
    it 'sets the screen instance to Level' do
      screen = game.instance_variable_get(:@screen)
      screen.instance_variable_set(:@exit_value, 1)

      allow(screen).to receive(:urb_clicked).and_return(screen.instance_variable_get(:@exit_value))
      game.play_game

      updated_screen = game.instance_variable_get(:@screen)
      expect(updated_screen.class).to eq Level
    end
  end

  describe '.play_button_pressed' do
    it 'sets the screen instance to Title' do
      allow(game).to receive(:inside_x).and_return(true)
      allow(game).to receive(:inside_y).and_return(true)

      game.play_button_pressed
      screen = game.instance_variable_get(:@screen)

      expect(screen.class).to eq Level
    end
  end
end
