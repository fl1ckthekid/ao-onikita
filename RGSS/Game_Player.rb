class Game_Player < Game_Character
  CENTER_X = (320 - 16) * 4   
  CENTER_Y = (240 - 16) * 4   

  def passable?(x, y, d)
    new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
    unless $game_map.valid?(new_x, new_y)
      return false
    end
    if $DEBUG and Input.press?(Input::CTRL)
      return true
    end
    super
  end

  def center(x, y)
    max_x = ($game_map.width - 20) * 128
    max_y = ($game_map.height - 15) * 128
    $game_map.display_x = [0, [x * 128 - CENTER_X, max_x].min].max
    $game_map.display_y = [0, [y * 128 - CENTER_Y, max_y].min].max
  end

  def moveto(x, y)
    super
    center(x, y)
    make_encounter_count
  end

  def increase_steps
    super
    unless @move_route_forcing
      $game_party.increase_steps
      if $game_party.steps % 2 == 0
        $game_party.check_map_slip_damage
      end
    end
  end

  def encounter_count
    return @encounter_count
  end

  def make_encounter_count
    if $game_map.map_id != 0
      n = $game_map.encounter_step
      @encounter_count = rand(n) + rand(n) + 1
    end
  end

  def refresh
    if $game_party.actors.size == 0
      @character_name = ""
      @character_hue = 0
      return
    end
    actor = $game_party.actors[0]
    @character_name = actor.character_name
    @character_hue = actor.character_hue
    @opacity = 255
    @blend_type = 0
  end

  def check_event_trigger_here(triggers)
    result = false
    if $game_system.map_interpreter.running?
      return result
    end
    
    for event in $game_map.events.values
      if event.x == @x and event.y == @y and triggers.include?(event.trigger)
        if not event.jumping? and event.over_trigger?
          event.start
          result = true
        end
      end
    end
    return result
  end
  
  def check_event_trigger_there(triggers)
    result = false
    if $game_system.map_interpreter.running?
      return result
    end
    
    new_x = @x + (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
    new_y = @y + (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
    
    for event in $game_map.events.values
      if event.x == new_x and event.y == new_y and
          triggers.include?(event.trigger)
        if not event.jumping? and not event.over_trigger?
          event.start
          result = true
        end
      end
    end
    
    if result == false
      if $game_map.counter?(new_x, new_y)
        new_x += (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
        new_y += (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
        for event in $game_map.events.values
          if event.x == new_x and event.y == new_y and
              triggers.include?(event.trigger)
            if not event.jumping? and not event.over_trigger?
              event.start
              result = true
            end
          end
        end
      end
    end
    return result
  end

  def check_event_trigger_touch(x, y)
    result = false
    if $game_system.map_interpreter.running?
      return result
    end
    for event in $game_map.events.values
      if event.x == x and event.y == y and [1,2].include?(event.trigger)
        if not event.jumping? and not event.over_trigger?
          event.start
          result = true
        end
      end
    end
    return result
  end

  def update
    last_moving = moving?
    unless moving? or $game_system.map_interpreter.running? or
      @move_route_forcing or $game_temp.message_window_showing
      case Input.dir4
      when 2
        move_down
      when 4
        move_left
      when 6
        move_right
      when 8
        move_up
      end
    end
    
    last_real_x = @real_x
    last_real_y = @real_y
    super
    
    if @real_y > last_real_y and @real_y - $game_map.display_y > CENTER_Y
      $game_map.scroll_down(@real_y - last_real_y)
    end
    
    if @real_x < last_real_x and @real_x - $game_map.display_x < CENTER_X
      $game_map.scroll_left(last_real_x - @real_x)
    end
    
    if @real_x > last_real_x and @real_x - $game_map.display_x > CENTER_X
      $game_map.scroll_right(@real_x - last_real_x)
    end
    
    if @real_y < last_real_y and @real_y - $game_map.display_y < CENTER_Y
      $game_map.scroll_up(last_real_y - @real_y)
    end
    
    unless moving?
      if last_moving
        result = check_event_trigger_here([1,2])
        if result == false
          unless $DEBUG and Input.press?(Input::CTRL)
            if @encounter_count > 0
              @encounter_count -= 1
            end
          end
        end
      end
      if Input.trigger?(Input::C)
        check_event_trigger_here([0])
        check_event_trigger_there([0,1,2])
      end
    end
  end
end