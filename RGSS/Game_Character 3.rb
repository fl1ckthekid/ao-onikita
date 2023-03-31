class Game_Character
  def move_down(turn_enabled = true)
    if turn_enabled
      turn_down
    end
    if passable?(@x, @y, 2)
      turn_down
      @y += 1
      increase_steps
    else
      check_event_trigger_touch(@x, @y+1)
    end
  end

  def move_left(turn_enabled = true)
    if turn_enabled
      turn_left
    end
    if passable?(@x, @y, 4)
      turn_left
      @x -= 1
      increase_steps
    else
      check_event_trigger_touch(@x-1, @y)
    end
  end

  def move_right(turn_enabled = true)
    if turn_enabled
      turn_right
    end
    if passable?(@x, @y, 6)
      turn_right
      @x += 1
      increase_steps
    else
      check_event_trigger_touch(@x+1, @y)
    end
  end

  def move_up(turn_enabled = true)
    if turn_enabled
      turn_up
    end
    if passable?(@x, @y, 8)
      turn_up
      @y -= 1
      increase_steps
    else
      check_event_trigger_touch(@x, @y-1)
    end
  end

  def move_lower_left
    unless @direction_fix
      @direction = (@direction == 6 ? 4 : @direction == 8 ? 2 : @direction)
    end
    
    if (passable?(@x, @y, 2) and passable?(@x, @y + 1, 4)) or
        (passable?(@x, @y, 4) and passable?(@x - 1, @y, 2))
      @x -= 1
      @y += 1
      increase_steps
    end
  end

  def move_lower_right
    unless @direction_fix
      @direction = (@direction == 4 ? 6 : @direction == 8 ? 2 : @direction)
    end
    
    if (passable?(@x, @y, 2) and passable?(@x, @y + 1, 6)) or
        (passable?(@x, @y, 6) and passable?(@x + 1, @y, 2))
      @x += 1
      @y += 1
      increase_steps
    end
  end

  def move_upper_left
    unless @direction_fix
      @direction = (@direction == 6 ? 4 : @direction == 2 ? 8 : @direction)
    end
    
    if (passable?(@x, @y, 8) and passable?(@x, @y - 1, 4)) or
        (passable?(@x, @y, 4) and passable?(@x - 1, @y, 8))
      @x -= 1
      @y -= 1
      increase_steps
    end
  end

  def move_upper_right
    unless @direction_fix
      @direction = (@direction == 4 ? 6 : @direction == 2 ? 8 : @direction)
    end
    
    if (passable?(@x, @y, 8) and passable?(@x, @y - 1, 6)) or
        (passable?(@x, @y, 6) and passable?(@x + 1, @y, 8))
      @x += 1
      @y -= 1
      increase_steps
    end
  end

  def move_random
    case rand(4)
    when 0  
      move_down(false)
    when 1  
      move_left(false)
    when 2  
      move_right(false)
    when 3  
      move_up(false)
    end
  end

  def move_toward_player
    sx = @x - $game_player.x
    sy = @y - $game_player.y
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

  def move_away_from_player
    sx = @x - $game_player.x
    sy = @y - $game_player.y
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

  def move_forward
    case @direction
    when 2
      move_down(false)
    when 4
      move_left(false)
    when 6
      move_right(false)
    when 8
      move_up(false)
    end
  end

  def move_backward
    last_direction_fix = @direction_fix
    @direction_fix = true
    case @direction
    when 2  
      move_up(false)
    when 4  
      move_right(false)
    when 6  
      move_left(false)
    when 8  
      move_down(false)
    end
    @direction_fix = last_direction_fix
  end

  def jump(x_plus, y_plus)
    if x_plus != 0 or y_plus != 0
      if x_plus.abs > y_plus.abs
        x_plus < 0 ? turn_left : turn_right
      else
        y_plus < 0 ? turn_up : turn_down
      end
    end
    
    new_x = @x + x_plus
    new_y = @y + y_plus
    
    if (x_plus == 0 and y_plus == 0) or passable?(new_x, new_y, 0)
      straighten
      @x = new_x
      @y = new_y
      distance = Math.sqrt(x_plus * x_plus + y_plus * y_plus).round
      @jump_peak = 10 + distance - @move_speed
      @jump_count = @jump_peak * 2
      @stop_count = 0
    end
  end

  def turn_down
    unless @direction_fix
      @direction = 2
      @stop_count = 0
    end
  end

  def turn_left
    unless @direction_fix
      @direction = 4
      @stop_count = 0
    end
  end

  def turn_right
    unless @direction_fix
      @direction = 6
      @stop_count = 0
    end
  end

  def turn_up
    unless @direction_fix
      @direction = 8
      @stop_count = 0
    end
  end

  def turn_right_90
    case @direction
    when 2
      turn_left
    when 4
      turn_up
    when 6
      turn_down
    when 8
      turn_right
    end
  end

  def turn_left_90
    case @direction
    when 2
      turn_right
    when 4
      turn_down
    when 6
      turn_up
    when 8
      turn_left
    end
  end

  def turn_180
    case @direction
    when 2
      turn_up
    when 4
      turn_right
    when 6
      turn_left
    when 8
      turn_down
    end
  end

  def turn_right_or_left_90
    if rand(2) == 0
      turn_right_90
    else
      turn_left_90
    end
  end

  def turn_random
    case rand(4)
    when 0
      turn_up
    when 1
      turn_right
    when 2
      turn_left
    when 3
      turn_down
    end
  end

  def turn_toward_player
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    if sx == 0 and sy == 0
      return
    end
    
    if sx.abs > sy.abs
      sx > 0 ? turn_left : turn_right
    else
      sy > 0 ? turn_up : turn_down
    end
  end

  def turn_away_from_player
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    if sx == 0 and sy == 0
      return
    end
    
    if sx.abs > sy.abs
      sx > 0 ? turn_right : turn_left
    else
      sy > 0 ? turn_down : turn_up
    end
  end
end