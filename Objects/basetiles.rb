require_relative '../Helpers/settings'

class Basetiles
  TILE_GAP = 2
  attr_reader :cells, :tile_square, :image

  def initialize(tile_map, tile_map_width, tile_map_height)
    @tile_map = tile_map
    @tile_map_width = tile_map_width
    @tile_map_height = tile_map_height
    @image = Gosu::Image.new('assets/tile_42x42.png')
    @tile_square = image.height
    @cells = set_cells(@tile_map_width, @tile_map_height)
  end

  def x_start_position
    sum = (@tile_map_width * @tile_square) + (TILE_GAP * (@tile_map_width - 1))
    (Settings::SCREEN_WIDTH - sum) / 2
  end

  def y_start_position
    sum = (@tile_map_height * @tile_square) +
          (TILE_GAP * (@tile_map_height - 1))
    (Settings::SCREEN_HEIGHT - sum) / 2
  end

  def set_cells(width, height)
    cells = []

    tile_locations = set_tile_map
    0.upto(height - 1) do |w|
      0.upto(width - 1) do |h|
        location = h + (w * width)
        valid = @tile_map[location] == 1
        cells << {
          cell: [h, w],
          location: location,
          position: tile_locations[location],
          valid: valid
        }
      end
    end
    cells
  end

  def set_tile_map
    positions = []
    x_start = x = x_start_position
    y_start = y = y_start_position

    @tile_map.each_with_index do |_tile, i|
      x, y = get_location(i, x_start, y_start, x, y)
      positions << [x, y]
    end
    positions
  end

  def get_location(i, x_start, y_start, x, y)
    if i.zero?
      x = x_start
      y = y_start
    elsif (i % @tile_map_width).zero?
      x = x_start
      y += (@tile_square + TILE_GAP)
    else
      x += (@tile_square + TILE_GAP)
    end
    [x, y]
  end
end
