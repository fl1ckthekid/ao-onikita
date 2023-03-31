class Game_SelfSwitches
  def initialize
    @data = {}
  end

  def [](key)
    return @data[key] == true ? true : false
  end
  
  def []=(key, value)
    @data[key] = value
  end
end