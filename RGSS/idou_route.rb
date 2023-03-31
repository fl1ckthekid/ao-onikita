class Game_Character

  def move_toward_event(id)
    sx = @x - $game_map.events[id].x
    sy = @y - $game_map.events[id].y
    if sx == 0 and sy == 0
      return
    end
    
    abs_sx = sx.abs
    abs_sy = sy.abs
    if abs_sx == abs_sy
      rand(2) == 0 ? abs_sx += 1 : abs_sy += 1
    end
    
    if abs_sx > abs_sy
      sx > 0 ? move_left : move_right
      if not moving? and sy != 0
        sy > 0 ? move_up : move_down
      end
    else
      sy > 0 ? move_up : move_down
      if not moving? and sx != 0
        sx > 0 ? move_left : move_right
      end
    end
  end

  def move_away_from_event(id)
    sx = @x - $game_map.events[id].x
    sy = @y - $game_map.events[id].y
    if sx == 0 and sy == 0
      return
    end
    
    abs_sx = sx.abs
    abs_sy = sy.abs
    if abs_sx == abs_sy
      rand(2) == 0 ? abs_sx += 1 : abs_sy += 1
    end
    
    if abs_sx > abs_sy
      sx > 0 ? move_right : move_left
      if not moving? and sy != 0
        sy > 0 ? move_down : move_up
      end
    else
      sy > 0 ? move_down : move_up
      if not moving? and sx != 0
        sx > 0 ? move_right : move_left
      end
    end
  end

  def move_toward_position(x, y)
    sx = @x - x
    sy = @y - y
    if sx == 0 and sy == 0
      return
    end
    
    abs_sx = sx.abs
    abs_sy = sy.abs
    if abs_sx == abs_sy
      rand(2) == 0 ? abs_sx += 1 : abs_sy += 1
    end
    
    if abs_sx > abs_sy
      sx > 0 ? move_left : move_right
      if not moving? and sy != 0
        sy > 0 ? move_up : move_down
      end
    else
      sy > 0 ? move_up : move_down
      if not moving? and sx != 0
        sx > 0 ? move_left : move_right
      end
    end
  end

  def move_away_from_position(x, y)
    sx = @x - x
    sy = @y - y
    if sx == 0 and sy == 0
      return
    end
    
    abs_sx = sx.abs
    abs_sy = sy.abs
    if abs_sx == abs_sy
      rand(2) == 0 ? abs_sx += 1 : abs_sy += 1
    end
    
    if abs_sx > abs_sy
      sx > 0 ? move_right : move_left
      if not moving? and sy != 0
        sy > 0 ? move_down : move_up
      end
    else
      sy > 0 ? move_down : move_up
      if not moving? and sx != 0
        sx > 0 ? move_right : move_left
      end
    end
  end

  def turn_toward_event(id)
    sx = @x - $game_map.events[id].x
    sy = @y - $game_map.events[id].y
    if sx == 0 and sy == 0
      return
    end
    
    if sx.abs > sy.abs
      sx > 0 ? turn_left : turn_right
    else
      sy > 0 ? turn_up : turn_down
    end
  end

  def turn_away_from_event(id)
    sx = @x - $game_map.events[id].x
    sy = @y - $game_map.events[id].y
    if sx == 0 and sy == 0
      return
    end
    
    if sx.abs > sy.abs
      sx > 0 ? turn_right : turn_left
    else
      sy > 0 ? turn_down : turn_up
    end
  end

  def turn_toward_position(x, y)
    sx = @x - x
    sy = @y - y
    if sx == 0 and sy == 0
      return
    end
    
    if sx.abs > sy.abs
      sx > 0 ? turn_left : turn_right
    else
      sy > 0 ? turn_up : turn_down
    end
  end

  def turn_away_from_position(x, y)
    sx = @x - x
    sy = @y - y
    if sx == 0 and sy == 0
      return
    end
    
    if sx.abs > sy.abs
      sx > 0 ? turn_right : turn_left
    else
      sy > 0 ? turn_down : turn_up
    end
  end

  def move_random_area(x, y, distance)
    sx = @x - x
    sy = @y - y
    if sx.abs + sy.abs > distance
      move_toward_position(x, y)
      return
    end
    
    case rand(4)
    when 0  
      if sx.abs + sy < distance
        move_down(false)
      end
    when 1  
      if -sx + sy.abs < distance
        move_left(false)
      end
    when 2  
      if sx + sy.abs < distance
        move_right(false)
      end
    when 3  
      if sx.abs - sy < distance
        move_up(false)
      end
    end
  end

  def set_graphic_party(n)
    actor = $game_party.actors[n - 1]
    if actor == nil
      @character_name = ""
      return
    end
    
    @tile_id = 0
    @character_name = actor.character_name
    @character_hue = actor.character_hue
  end
end