require_relative '../Helpers/game_helper'
require_relative '../Metrics/path'
require_relative '../Metrics/graph'

module ShuffleHelper
  def self.objects_to_shuffle(objects)
    results = objects.find_all { |o| o.status == :NONE && o.y > 0 }

    cells = []
    results.each do |result|
      cells << result.cell
    end

    cells.shuffle!
    [results, cells]
  end

  def self.check_shuffle(objects, cells)
    object_shuffle = objects_to_shuffle(objects)
    object_shuffle[0].each_with_index do |obj, i|
      destination = GameHelper::find_x_y_value_of_cell(object_shuffle[1][i], cells)
      if !(obj.x == destination.first && obj.y == destination.last)
        obj.path.concat Path.new.create_path(obj.x, obj.y, destination.first, destination.last)
        obj.animate_path
      end
    end
    object_shuffle
  end

  def self.assign_shuffle_locations(object_shuffle, cells)
    object_shuffle[1].each_with_index do |cell, i|
      location = GameHelper.find_location_of_cell(cell, cells)
      object_shuffle[0][i].location = location
      object_shuffle[0][i].change_cell(cell)
    end
  end
end