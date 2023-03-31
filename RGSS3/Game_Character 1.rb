class Game_Character
  attr_reader:id                       
  attr_reader:x                        
  attr_reader:y                        
  attr_reader:real_x                   
  attr_reader:real_y                   
  attr_reader:tile_id                  
  attr_reader:character_name           
  attr_reader:character_hue            
  attr_reader:opacity                  
  attr_reader:blend_type               
  attr_reader:direction                
  attr_reader:pattern                  
  attr_reader:move_route_forcing       
  attr_reader:through                  
  attr_accessor:animation_id             
  attr_accessor:transparent              

  def initialize
    @id = 0
    @x = 0
    @y = 0
    @real_x = 0
    @real_y = 0
    @tile_id = 0
    @character_name = ""
    @character_hue = 0
    @opacity = 255
    @blend_type = 0
    @direction = 2
    @pattern = 0
    @move_route_forcing = false
    @through = false
    @animation_id = 0
    @transparent = false
    @original_direction = 2
    @original_pattern = 0
    @move_type = 0
    @move_speed = 4
    @move_frequency = 6
    @move_route = nil
    @move_route_index = 0
    @original_move_route = nil
    @original_move_route_index = 0
    @walk_anime = true
    @step_anime = false
    @direction_fix = false
    @always_on_top = false
    @anime_count = 0
    @stop_count = 0
    @jump_count = 0
    @jump_peak = 0
    @wait_count = 0
    @locked = false
    @prelock_direction = 0
  end

  def moving?
    return (@real_x != @x * 128 or @real_y != @y * 128)
  end

  def jumping?
    return @jump_count > 0
  end

  def straighten
    if @walk_anime or @step_anime
      @pattern = 0
    end
    @anime_count = 0
    @prelock_direction = 0
  end

  def force_move_route(move_route)
    if @original_move_route == nil
      @original_move_route = @move_route
      @original_move_route_index = @move_route_index
    end
    @move_route = move_route
    @move_route_index = 0
    @move_route_forcing = true
    @prelock_direction = 0
    @wait_count = 0
    move_type_custom
  end

  def passable?(x, y, d)
    new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
    
    unless $game_map.valid?(new_x, new_y)
      return false
    end
    if @through
      return true
    end
    unless $game_map.passable?(x, y, d, self)
      return false
    end
    unless $game_map.passable?(new_x, new_y, 10 - d)
      return false
    end
    
    for event in $game_map.events.values
      if event.x == new_x and event.y == new_y
        unless event.through
          if self != $game_player
            return false
          end
          if event.character_name != ""
            return false
          end
        end
      end
    end
    
    if $game_player.x == new_x and $game_player.y == new_y
      unless $game_player.through
        if @character_name != ""
          return false
        end
      end
    end
    
    return true
  end

  def lock
    if @locked
      return
    end
    @prelock_direction = @direction
    turn_toward_player
    @locked = true
  end

  def lock?
    return @locked
  end

  def unlock
    unless @locked
      return
    end
    @locked = false
    unless @direction_fix
      if @prelock_direction != 0
        @direction = @prelock_direction
      end
    end
  end

  def moveto(x, y)
    @x = x % $game_map.width
    @y = y % $game_map.height
    @real_x = @x * 128
    @real_y = @y * 128
    @prelock_direction = 0
  end

  def screen_x
    return (@real_x - $game_map.display_x + 3) / 4 + 16
  end

  def screen_y
    y = (@real_y - $game_map.display_y + 3) / 4 + 32
    if @jump_count >= @jump_peak
      n = @jump_count - @jump_peak
    else
      n = @jump_peak - @jump_count
    end
    return y - (@jump_peak * @jump_peak - n * n) / 2
  end

  def screen_z(height = 0)
    if @always_on_top
      return 999
    end
    z = (@real_y - $game_map.display_y + 3) / 4 + 32
    if @tile_id > 0
      return z + $game_map.priorities[@tile_id] * 32
    else
      return z + ((height > 32) ? 31 : 0)
    end
  end

  def bush_depth
    if @tile_id > 0 or @always_on_top
      return 0
    end
    if @jump_count == 0 and $game_map.bush?(@x, @y)
      return 12
    else
      return 0
    end
  end

  def terrain_tag
    return $game_map.terrain_tag(@x, @y)
  end
end