require_relative '../Helpers/game_module'
require_relative '../Helpers/game_helper'
require_relative '../Utilities/levelmanager'
require_relative '../Objects/basetiles'
require_relative '../Objects/animation'
require_relative '../Objects/urb_animation'
require_relative '../Objects/obstacle'
require_relative '../Objects/image'
require_relative '../Metrics/path'
require_relative '../Metrics/graph'
require 'byebug'

class Main
  MATCH_STATE = %i[auto ready swap reset user_match shuffle special].freeze
  STAGE = %i[check match rearrange replace homeless home_found].freeze

  def initialize(level)
    load_level(level)
    load_foreground_images
    initialise_buttons
    load_tiles
    reset_graph
    add_obstacles
  end

  def update

  end

  def draw
    @bkgnd.draw(0, 0, 0)
    @font.draw("Level #{@level}", 250, 5, 0, 1, 1, Gosu::Color::YELLOW)
    @tile_images.each do |tile|
      tile[:img].draw(tile[:x], tile[:y], 0)
    end
    @obstacles.each(&:draw) unless @obstacles.empty?
  end

  private
    def load_foreground_images
      @bkgnd = Gosu::Image.new('assets/night_bkgnd.png')
      @font = Gosu::Font.new(16)
      @small_font = Gosu::Font.new(12)
    end

    def initialise_buttons
      @pause_value = 0
      @help_value = 0
      @exit_value = 0 # was owner previously
    end

    def load_level(level)
      @level = level
      @level_manager = Levelmanager.new(@level)
      level_tile_map = @level_manager.level_tile_map
      @map = level_tile_map[0]
      @map_width = level_tile_map[1]
      @map_height = level_tile_map[2]
    end

    def load_tiles
      @base_tiles = Basetiles.new(@map, @map_width, @map_height)
      @cells = @base_tiles.cells

      @tile_locations = []
      @tile_images = []

      @cells.each do |tile|
        @tile_images << { img: @base_tiles.image,
                          x: tile[:position].first,
                          y: tile[:position].last } if tile[:valid]
        @tile_locations << tile[:position]
      end
    end

    def reset_graph
      @graph = Graph.new(@map_width, @map_height)
      vacant_cells = []
      @cells.each do |tile|
        vacant_cells << tile[:cell] unless tile[:valid]
      end

      unless vacant_cells.empty?
        @graph.set_group_obstacles(vacant_cells)
        @graph.set_group_invisibles(vacant_cells)
      end

      @graph.set_group_vacancies(@homeless_cells) unless @homeless_cells.nil?
      reset_tile_obstacles
    end

    def add_obstacles
      obstacle_locations = @level_manager.obstacles
      return if obstacle_locations.empty?
      obstacle_definitions(obstacle_locations)
    end

    def obstacle_definitions(obstacle_locations)
      obstacle_cells = []
      obstacle_locations.each do |ol|
        obstacle_cells << GameHelper.find_cell_of_location(ol, @cells)
      end

      if @level_manager.glass?
        filename = 'assets/glass_tile.png'
        status = Settings::OBSTACLE_STATE.find_index(:GLASS)
      end

      tile_sq = @base_tiles.tile_square
      @obstacles = []
      obstacle_locations.each_with_index do |ol, i|
        position = GameHelper.find_x_y_value_of_cell(obstacle_cells[i], @cells)
        @obstacles << Obstacle.new(filename, tile_sq, tile_sq, 30, 2000, true,
                                   position.first, position.last, status, ol,
                                   obstacle_cells[i], true)
      end
      @graph.set_group_obstacles(obstacle_cells)
    end

    def reset_tile_obstacles
      @obstacle_locations ||= @level_manager.obstacles

      return if @obstacle_locations.empty?
      obstacle_cells = []
      @obstacle_locations.each do |ol|
        obstacle_cells << GameHelper.find_cell_of_location(ol, @cells)
      end
      @graph.set_group_obstacles(obstacle_cells)
    end
end
