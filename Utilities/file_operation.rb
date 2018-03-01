require 'json'

class FileOperation
  def initialize(filename)
    @filename = filename
    return unless File.size?(filename).nil?
    data = generate_basic_data
    write_to_file(data)
  end

  def load_data
    file = File.read(@filename)
    JSON.parse(file)
  end

  def generate_basic_data
    { access_level: 1 }
  end

  def write_to_file(data)
    File.write(@filename, data.to_json)
  end
end
