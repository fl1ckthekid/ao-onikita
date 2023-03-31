class Game_Character
  def update
    if jumping?
      update_jump
    elsif moving?
      update_move
    else
      update_stop
    end

    if @anime_count > 18 - @move_speed * 2
      if not @step_anime and @stop_count > 0
        @pattern = @original_pattern
      else
        @pattern = (@pattern + 1) % 4
      end
      @anime_count = 0
    end
    
    if @wait_count > 0
      @wait_count -= 1
      return
    end
    
    if @move_route_forcing
      move_type_custom
      return
    end
    
    if @starting or lock?
      return
    end
    
    if @stop_count > (40 - @move_frequency * 2) * (6 - @move_frequency)
      case @move_type
      when 1  
        move_type_random
      when 2  
        move_type_toward_player
      when 3  
        move_type_custom
      end
    end
  end

  def update_jump
    @jump_count -= 1
    @real_x = (@real_x * @jump_count + @x * 128) / (@jump_count + 1)
    @real_y = (@real_y * @jump_count + @y * 128) / (@jump_count + 1)
  end

  def update_move
    distance = 2 ** @move_speed
    if @y * 128 > @real_y
      @real_y = [@real_y + distance, @y * 128].min
    end
    if @x * 128 < @real_x
      @real_x = [@real_x - distance, @x * 128].max
    end
    if @x * 128 > @real_x
      @real_x = [@real_x + distance, @x * 128].min
    end
    if @y * 128 < @real_y
      @real_y = [@real_y - distance, @y * 128].max
    end

    if @walk_anime
      @anime_count += 1.5
    elsif @step_anime
      @anime_count += 1
    end
  end

  def update_stop
    if @step_anime
      @anime_count += 1
    elsif @pattern != @original_pattern
      @anime_count += 1.5
    end
    unless @starting or lock?
      @stop_count += 1
    end
  end
  
  def move_type_random
    case rand(6)
    when 0..3  
      move_random
    when 4  
      move_forward
    when 5  
      @stop_count = 0
    end
  end

  def move_type_toward_player
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    
    abs_sx = sx > 0 ? sx : -sx
    abs_sy = sy > 0 ? sy : -sy
    
    if sx + sy >= 20
      move_random
      return
    end
    
    case rand(6)
    when 0..3  
      move_toward_player
    when 4  
      move_random
    when 5  
      move_forward
    end
  end

  def move_type_custom
    if jumping? or moving?
      return
    end
    
    while @move_route_index < @move_route.list.size
      command = @move_route.list[@move_route_index]
      if command.code == 0
        if @move_route.repeat
          @move_route_index = 0
        end
        
        unless @move_route.repeat
          if @move_route_forcing and not @move_route.repeat
            @move_route_forcing = false
            @move_route = @original_move_route
            @move_route_index = @original_move_route_index
            @original_move_route = nil
          end
          @stop_count = 0
        end
        return
      end
      
      if command.code <= 14
        case command.code
        when 1  
          move_down
        when 2  
          move_left
        when 3  
          move_right
        when 4  
          move_up
        when 5  
          move_lower_left
        when 6  
          move_lower_right
        when 7  
          move_upper_left
        when 8  
          move_upper_right
        when 9  
          move_random
        when 10  
          move_toward_player
        when 11  
          move_away_from_player
        when 12  
          move_forward
        when 13  
          move_backward
        when 14  
          jump(command.parameters[0], command.parameters[1])
        end
        if not @move_route.skippable and not moving? and not jumping?
          return
        end
        @move_route_index += 1
        return
      end
      
      if command.code == 15
        @wait_count = command.parameters[0] * 2 - 1
        @move_route_index += 1
        return
      end
      
      if command.code >= 16 and command.code <= 26
        case command.code
        when 16  
          turn_down
        when 17  
          turn_left
        when 18  
          turn_right
        when 19  
          turn_up
        when 20  
          turn_right_90
        when 21  
          turn_left_90
        when 22  
          turn_180
        when 23  
          turn_right_or_left_90
        when 24  
          turn_random
        when 25  
          turn_toward_player
        when 26  
          turn_away_from_player
        end
        @move_route_index += 1
        return
      end
      
      if command.code >= 27
        case command.code
        when 27  
          $game_switches[command.parameters[0]] = true
          $game_map.need_refresh = true
        when 28  
          $game_switches[command.parameters[0]] = false
          $game_map.need_refresh = true
        when 29  
          @move_speed = command.parameters[0]
        when 30  
          @move_frequency = command.parameters[0]
        when 31  
          @walk_anime = true
        when 32  
          @walk_anime = false
        when 33  
          @step_anime = true
        when 34  
          @step_anime = false
        when 35  
          @direction_fix = true
        when 36  
          @direction_fix = false
        when 37  
          @through = true
        when 38  
          @through = false
        when 39  
          @always_on_top = true
        when 40  
          @always_on_top = false
        when 41  
          @tile_id = 0
          @character_name = command.parameters[0]
          @character_hue = command.parameters[1]
          if @original_direction != command.parameters[2]
            @direction = command.parameters[2]
            @original_direction = @direction
            @prelock_direction = 0
          end
          if @original_pattern != command.parameters[3]
            @pattern = command.parameters[3]
            @original_pattern = @pattern
          end
        when 42  
          @opacity = command.parameters[0]
        when 43  
          @blend_type = command.parameters[0]
        when 44  
          $game_system.se_play(command.parameters[0])
        when 45  
          result = eval(command.parameters[0])
        end
        @move_route_index += 1
      end
    end
  end

  def increase_steps
    @stop_count = 0
  end
end