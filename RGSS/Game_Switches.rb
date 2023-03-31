class Game_Switches
  def initialize
    @data = []
  end

  def [](switch_id)
    if switch_id <= 5000 and @data[switch_id] != nil
      return @data[switch_id]
    else
      return false
    end
  end

  def []=(switch_id, value)
    if switch_id <= 5000
      @data[switch_id] = value
    end
  end
end