class Game_Variables
  def initialize
    @data = []
  end

  def [](variable_id)
    if variable_id <= 5000 and @data[variable_id] != nil
      return @data[variable_id]
    else
      return 0
    end
  end

  def []=(variable_id, value)
    if variable_id <= 5000
      @data[variable_id] = value
    end
  end
end