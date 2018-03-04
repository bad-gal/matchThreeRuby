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
    reset_urb_selectors
    load_selectors
    reset_variables
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

    @effects.each(&:update) unless @effects.empty?
    @objects.each(&:update)
    @obstacles.each(&:update) unless @obstacles.empty?

    GameModule.delete_obstacles(@obstacles, @objects, @obstacle_locations)
  end

  def draw
    @bkgnd.draw(0, 0, 0)
    @font.draw("Level #{@level}", 250, 5, 0, 1, 1, Gosu::Color::YELLOW)
    @tile_image.each do |tile|
      tile[:img].draw(tile[:x], tile[:y], 0)
    end
    @effects.each(&:draw) unless @effects.empty?
    @objects.each(&:draw)

    unless @matched_copy.nil?
      @matched_copy.each(&:draw) unless @matched_copy.empty?
    end

    @selectors[0].draw unless @urb_one.negative?
    @selectors[1].draw unless @urb_two.negative?
    @obstacles.each(&:draw) unless @obstacles.empty?
    draw_buttons
  end

  def urb_clicked(x, y)
    if @match_state == MATCH_STATE.find_index(:ready) &&
       @stage == STAGE.find_index(:check)
      button_pressed(x, y)

      if [@pause_value, @help_value].all?(&:zero?)
        check_if_object_selected(x, y) if [@urb_one, @urb_two].any?(&:negative?)
      end
    end
  end

  private

  def load_foreground_image
    @bkgnd = Gosu::Image.new('assets/night_bkgnd.png')
    @font = Gosu::Font.new(16)
    @small_font = Gosu::Font.new(12)
    @freed_sound = GameHelper.load_sounds
  end

  def load_selectors
    @selectors = [
      Image.new('Assets/selector.png', -100, -100),
      Image.new('Assets/selector.png', -100, -100)
    ]
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
    @match_state = MATCH_STATE.find_index(:auto)
    @stage = STAGE.find_index(:check)
  end

  def initial_swap
    @match_state = MATCH_STATE.find_index(:swap)
    @stage = STAGE.find_index(:check)
  end

  def initial_user_match
    @match_state = MATCH_STATE.find_index(:user_match)
    @stage = STAGE.find_index(:check)
  end

  def initial_ready
    @match_state = MATCH_STATE.find_index(:ready)
    @stage = STAGE.find_index(:check)
  end

  def automatic_state
    case @stage
    when STAGE.find_index(:check)
      find_matches
    when STAGE.find_index(:match)
      remove_matches
    when STAGE.find_index(:rearrange)
      manage_remaining_objects
    when STAGE.find_index(:replace)
      add_new_objects # working on this next
    when STAGE.find_index(:homeless)
      replace_homeless_objects # not implemented
    when STAGE.find_index(:home_found)
      add_homeless_objects # not implemented
    end
  end

  def ready_state; end

  def swap_state
    case @stage
    when STAGE.find_index(:check)
      GameHelper.swap_check(@urb_object1, @urb_object2)
      @counter = 0
      @stage = STAGE.find_index(:match)
    when STAGE.find_index(:match)
      swap_match # amend
    end
  end

  def user_match_state; end

  def reset_state; end

  def check_if_object_selected(mouse_x, mouse_y)
    @objects.each do |object|
      next unless object.status == :NONE
      select_urb(object) if object.selected?(mouse_x, mouse_y)
    end
  end

  def select_urb(object)
    @urb_one == -1 ? @urb_one = object.location : @urb_two = object.location
    if [@urb_one, @urb_two].all?(&:positive?)
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
    # @objects = MethodLoader.create_urbs(@cells, @base_tiles, @level_manager,
    #                                     @obstacles)
    @objects = MethodLoader.fake_urbs(@cells, @level, @base_tiles,
                                      @level_manager, @obstacles)
  end

  def find_matches
    return unless @counter.zero?
    @match_details = GameModule.find_automatic_matches(@objects, @map_width,
                                                       @map, @obstacles)
    if @match_details.empty?
      initial_ready
      reset_variables
      p 'GO TO READY'
    else
      generate_match_data
    end
  end

  def generate_match_data
    @matches = GameHelper.return_matches_from_hash_in_order(@match_details)
    match_cells = GameHelper.convert_matches_to_cells(@matches, @objects,
                                                      @level_manager)
    GameHelper.remove_broken_obstacles(@matches, @obstacles, @graph)

    @cell_vacancies = []
    match_cells.each { |mc| @cell_vacancies << @graph.set_group_vacancies(mc) }
    @collapsed_match = @matches.flatten

    @matched_copy = GameModule.set_matched_objects(@collapsed_match, @objects)
    @stage = STAGE.find_index(:match)
  end

  def create_bounce
    GameHelper.bounce_out_setup(@matched_copy, @effects)
    @freed_sound.play
    @counter = 2
  end

  def place_bounced_urbs_offscreen
    result = @matched_copy.inject(0) do |sum, m|
      m.off_screen == true ? sum + 1 : sum
    end
    @counter = 3 if result == @matched_copy.size
  end

  def replace_or_rearrange
    @effects.clear
    @matched_copy.clear
    @counter = 0
    paths = GameHelper.available_paths(@graph, @map_width)
    return @stage = STAGE.find_index(:rearrange) unless paths.flatten.empty?
    vacant_details = GameHelper.set_new_vacancy_details(@objects,
                                                        @homeless_objects,
                                                        @map_width, @cells,
                                                        @collapsed_match,
                                                        @graph)
    @new_vacancy_details = vacant_details[0]
    @new_vacancies = vacant_details[1]
    @stage = STAGE.find_index(:replace)
  end

  def remove_matches
    initial_match_removal if @counter.zero?
    create_bounce if @counter == 1
    place_bounced_urbs_offscreen if @counter == 2
    replace_or_rearrange if @counter == 3
  end

  def initial_match_removal
    @matched_positions = GameModule.move_objects_off_screen(@collapsed_match,
                                                            @objects)
    @starting_points = GameHelper.get_starting_point(@cell_vacancies, @graph,
                                                     @map_width)
    @counter = 1
  end

  def swap_match
    swap_define
    swap_first_move
    match_in_swap
  end

  def swap_define
    return unless @counter.zero?
    @swap_one = GameHelper.find_x_y_value_of_cell(@urb_object2.cell, @cells)
    @swap_two = GameHelper.find_x_y_value_of_cell(@urb_object1.cell, @cells)
    @counter = 1
  end

  def swap_first_move
    return unless @counter == 1
    if @urb_object1.x == @swap_one.first && @urb_object1.y == @swap_one.last &&
       @urb_object2.x == @swap_two.first && @urb_object2.y == @swap_two.last
      @urb_object1.clear_path
      @urb_object2.clear_path
      @counter = 2
    end
  end

  def match_in_swap
    return unless @counter == 2
    if GameHelper.valid_swap?(@urb_object1, @urb_object2)
      temp = @urb_object1.dup
      update_object_cell(@urb_object1, @urb_object2)
      update_object_cell(@urb_object2, temp)
      details = GameModule.combine_matches(@objects, @urb_one, @map_width,
                                           @map, @obstacles)
      details2 = GameModule.combine_matches(@objects, @urb_two,
                                            @map_width, @map, @obstacles)
      p details, details2
      if details.nil? && details2.nil?
        no_match_made
      else
        find_matches(details, details2)
      end
    else
      @counter = 0
      @match_state = MATCH_STATE.find_index(:reset)
    end
  end

  def no_match_made
    @urb_object2.location = @urb_object1.location
    @urb_object2.change_cell(@urb_object1.cell)
    @urb_object1.location = temp.location
    @urb_object1.change_cell(temp.cell)
    @counter = 0
    @match_state = MATCH_STATE.find_index(:reset)
  end

  def match_found(details, details2)
    @match_details << details
    @match_details << details2
    @match_details.compact!
    reset_urb_selectors
    @swap_one = nil
    @swap_two = nil
    @counter = 0
    initial_user_match
  end

  def update_object_cell(object, new_object)
    object.location = new_object.location
    object.change_cell(new_object.cell)
  end

  def reset_variables
    @counter = 0
    @effects = []
    @move_down = []
    @move_to = []
  end

  def manage_remaining_objects
    if @counter.zero?
      @moved_urbs = identify_new_positions
      @counter = 1
    end

    if @counter == 1
      finished = GameHelper.move_remaining(@moved_urbs, @cells, @graph)
      @counter = 2 if finished
    end

    if @counter == 2
      puts "vacancies after remaining urbs moved down = #{@graph.get_vacancies}"
      reset_variables
      @match_details = []
      @cell_vacancies = []
      @collapsed_match = []
      @matched_positions = []
      @starting_points = []
      @counter = 0
      @stage = STAGE.find_index(:replace)
    end
  end

  def identify_new_positions
    temp = []

    @graph.get_vacancies.reverse_each do |vacancy|
      temp << vacancy
      cell = [vacancy[0], vacancy[1] - 1]
      while cell[1] >= 0
        temp << cell.dup unless @graph.get_obstacles.include?(cell)
        change = cell[1] - 1
        cell[1] = change
      end

      m_index = 0

      cell = [vacancy[0], vacancy[1] - 1]
      while cell[1] >= 0
        if !@graph.get_vacancies.include?(cell) &&
           !@move_down.include?(cell) && !@graph.get_obstacles.include?(cell)
          @move_down << cell.dup
          @move_to << temp[m_index].dup
          m_index += 1
        elsif !@graph.get_vacancies.include?(cell) &&
              !@move_down.include?(cell) && @graph.get_obstacles.include?(cell)
          break
        end

        change = cell[1] - 1
        cell[1] = change
      end
      temp.clear
    end
    GameHelper.set_move_down_path(@move_down, @move_to, @objects, @cells)
  end

  def delete_after_use
    puts "move down = #{@move_down}" unless @move_down.nil?
    puts "move to = #{@move_to}" unless @move_to.nil?
    puts "counter = #{@counter}"
    puts "moved urbs = #{@moved_urbs.size}" unless @moved_urbs.nil?
    puts "match details = #{@match_details}" unless @match_details.nil?
    puts "homeless cells = #{@homeless_cells}" unless @homeless_cells.nil?
    puts "obs locs = #{@obstacle_locations}" unless @obstacle_locations.nil?
    puts "cell vacancies = #{@cell_vacancies}" unless @cell_vacancies.nil?
    puts "collapsed match = #{@collapsed_match}" unless @collapsed_match.nil?
    puts "new v dets = #{@new_vacancy_details}" unless @new_vacancy_details.nil?
    puts "new vacancy = #{@new_vacancies}" unless @new_vacancies.nil?
    puts "matched pos = #{@matched_positions}" unless @matched_positions.nil?
    puts "starting points = #{@starting_points}" unless @starting_points.nil?
  end
end
