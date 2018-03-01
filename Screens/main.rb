require_relative '../Helpers/game_module'
require_relative '../Helpers/game_helper'
require_relative '../Helpers/method_loader'
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
    load_foreground_image
    initialise_buttons
    load_tiles
    reset_graph
    add_obstacles
    load_gui
    initial_state
    setup_objects
  end

  def update
    case @match_state
    when MATCH_STATE.find_index(:auto)
      automatic_state
    when MATCH_STATE.find_index(:ready)
      ready_state
    when MATCH_STATE.find_index(:swap)
      swap_state
    when MATCH_STATE.find_index(:user_match)
      user_match_state
    when MATCH_STATE.find_index(:reset)
      reset_state
    end

    @objects.each(&:update)
    @obstacles.each(&:update) unless @obstacles.empty?
  end

  def draw
    @bkgnd.draw(0, 0, 0)
    @font.draw("Level #{@level}", 250, 5, 0, 1, 1, Gosu::Color::YELLOW)
    @tile_image.each do |tile|
      tile[:img].draw(tile[:x], tile[:y], 0)
    end
    @objects.each(&:draw)
    @obstacles.each(&:draw) unless @obstacles.empty?
    draw_buttons
  end

  def urb_clicked(mouse_x, mouse_y)
    if @match_state == MATCH_STATE.find_index(:ready) &&
       @stage == STAGE.find_index(:check)
      button_pressed(mouse_x, mouse_y)

      if [@pause_value, @help_value].all?(&:zero?)
        check_if_object_selected if [@urb_one, @urb_two].any?(&:negative)
      end
    end
  end

  private

  def load_foreground_image
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
    @tile_image = []

    @cells.each do |tile|
      if tile[:valid]
        @tile_image << { img: @base_tiles.image,
                         x: tile[:position].first,
                         y: tile[:position].last }
      end
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

  def load_gui
    @pause = Image.new('Assets/pause.png', 270, 30)
    @help = Image.new('Assets/help.png', 6, 30)
    @board = Image.new('Assets/board3.png', 0, 435)
    @victory = Image.new('assets/victory.png', 10, 200)
    @failed = Image.new('assets/failed.png', 10, 200)
    @exit_game = Image.new('assets/exit_game.png', 5, 150)
    @continue = Image.new('assets/continue.png', 5, 230)
    @exit_level = Image.new('assets/exit_to_level.png', 5, 320)
    @pause_board = Image.new('assets/pause_board.png', 7, 90)
  end

  def draw_buttons
    @pause.draw
    @help.draw
    @board.draw
  end

  def button_pressed(mouse_x, mouse_y)
    if @pause.selected?(mouse_x, mouse_y) && @pause_value.zero?
      p 'pause button has been pressed'
      @pause_value = 1
    elsif @help.selected?(mouse_x, mouse_y) && @help_value.zero?
      @help_value = 1
      p 'help button has been pressed'
    end

    if @pause_value == 1
      @pause_value = 0 if @continue.selected?(mouse_x, mouse_y)
      @exit_value = 1 if @exit_level.selected?(mouse_x, mouse_y)
      @exit_value = -1 if @exit_game.selected?(mouse_x, mouse_y)
    elsif @help_value == 1
      @help_value = 0
    end
  end

  def initial_state
    @match_state = MATCH_STATE.find_index(:ready)
    @stage = STAGE.find_index(:check)
  end

  def initial_swap
    @match_state = MATCH_STATE.find_index(:swap)
    @stage = STAGE.find_index(:check)
  end

  def automatic_state; end

  def ready_state; end

  def swap_state; end

  def user_match_state; end

  def reset_state; end

  def check_if_object_selected
    @objects.each do |object|
      next unless object.status == :NONE
      select_urb(object) if object.selected?(mouse_x, mouse_y)
    end
  end

  def select_urb(object)
    @urb_one == -1 ? @urb_one = object.location : @urb_two = object.location
    if [@urb_one, @urb_two].all?(&:positive)
      if (@urb_two != @urb_one) &&
         (@urb_two == @urb_one + 1 &&
         (@urb_two / @map_width) == (@urb_one / @map_width)) ||
         (@urb_two == @urb_one - 1 && (@urb_two / @map_width) ==
         (@urb_one / @map_width)) || (@urb_two ==
         (@urb_one + @map_width) && @urb_two < @map.size) ||
         (@urb_two == @urb_one - @map_width && @urb_two >= 0)
        @urb_object2 = @objects.find { |jt| jt.location == @urb_two }

        if @urb_object1.type == @urb_object2.type
          reset_urb_selectors
        else
          assign_selector(@selectors[1], @urb_object2)
          initial_swap
        end
        p object.location
      else
        reset_urb_selectors
      end
    else
      p object.location
      @urb_object1 = @objects.find { |ob| ob.location == @urb_one }
      assign_selector(@selectors[0], @urb_object1)
    end
  end

  def assign_selector(selector, object)
    selector.x = object.x
    selector.y = object.y
  end

  def reset_urb_selectors
    @urb_one = -1
    @urb_two = -1
    @urb_object1 = nil
    @urb_object2 = nil
  end

  def setup_objects
    @urbs_in_level = @level_manager.urbs_in_level
    @objects = MethodLoader.create_urbs(@cells, @base_tiles, @level_manager,
               @obstacles)
    # fake_urbs(@cells, 30, @level)
  end
end
