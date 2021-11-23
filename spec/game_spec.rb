require_relative '../game'

RSpec.describe Game do
  describe '.new' do
    let(:game) { Game.new }

    it 'returns a Game object' do
      expect(game).to be_an_instance_of(Game)
      expect(game.caption).to eq 'Urbies'
    end
  end
end
