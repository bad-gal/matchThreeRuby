require_relative '../Helpers/game_helper'
require_relative '../Metrics/path'
require_relative '../Metrics/graph'

module ShuffleHelper
  def self.shuffle_objects(objects, graph, width, height)
    rows = blocked_rows(objects, graph, width, height)
    cols = blocked_columns(objects, graph, width, height)

    sections = []
    temp = []

    rows[1].each do |ro|
      cols[1].each do |co|
	      ro.each do |r|
		      temp << co.map{|i| [i,r]}
	      end
	      sections << temp.clone unless temp.empty?
	      temp.clear
      end
    end
    sections.each{ |s| s.flatten!(1) }

    obs = graph.get_obstacles
    sections.each do |section|
      section.reverse_each do |sect|
        section.delete(sect) if obs.include?(sect)
      end
    end

    results = []
    sections.each do |section|
      temp = []
      section.each do |sect|
        temp << objects.find { |o| o.cell == sect && !o.off_screen && o.status == :NONE }
      end
      results << [temp, section.shuffle!]
    end
    results
  end

  def self.check_shuffle(objects, graph, width, height, cells)
    object_shuffle = shuffle_objects(objects, graph, width, height)

    object_shuffle.each do |object|
      object[0].each_with_index do |obj, i|
        unless obj.cell == object[1][i]
          destination = GameHelper::find_x_y_value_of_cell(object[1][i], cells)
          obj.path.concat Path.new.create_line_path(obj.x, obj.y, destination.first, destination.last)
          obj.animate_path
        end
      end
    end
    object_shuffle
  end

  def self.assign_shuffle_locations(object_shuffle, cells)
    object_shuffle.each do |object|
      object[1].each_with_index do |cell, i|
        location = GameHelper.find_location_of_cell(cell, cells)
        object[0][i].location = location
        object[0][i].change_cell(cell)
      end
    end
  end

  def self.blocked_rows(objects, graph, width, height)
    blockers = graph.get_obstacles
    list = []

    0.upto(height - 1) do |row|
      temp = blockers.find_all {|block| block.last == row }.uniq
      list << temp unless temp.empty?
    end

    list.reverse_each do |li|
      list.delete(li) if li.size < width
    end

    temp = []
    list.each do |li|
      temp << li.first[1]
    end

    sum = 0
    clear_rows = 0
    sections = []
    arr = []

    0.upto(height - 1) do |row|
      if !temp.include?(row)
        clear_rows += 1
        p arr << row
        if clear_rows == 1
          sum += 1
        end
      else
        clear_rows = 0
        sections << arr.clone
        arr.clear
      end
    end

    sections << arr unless arr.empty?

    [sum, sections]
  end

  def self.blocked_columns(objects, graph, width, height)
    blockers = graph.get_obstacles
    list = []

    0.upto(width - 1) do |col|
      temp = blockers.find_all {|block| block.first == col }.uniq
      list << temp unless temp.empty?
    end

    list.reverse_each do |li|
      list.delete(li) if li.size < width
    end

    temp = []
    list.each do |li|
      temp << li.first[0]
    end

    sum = 0
    clear_cols = 0
    sections = []
    arr = []

    0.upto(width - 1) do |col|
      if !temp.include?(col)
        clear_cols += 1
        p arr << col
        if clear_cols == 1
          sum += 1
        end
      else
        clear_cols = 0
        sections << arr.clone
        arr.clear
      end
    end

    sections << arr unless arr.empty?

    [sum, sections]
  end
end
