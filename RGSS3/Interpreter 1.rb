class Interpreter

  def initialize(depth = 0, main = false)
    @depth = depth
    @main = main
    if depth > 100
      print("Common event calls have exceeded the limit.")
      exit
    end
    clear
  end

  def clear
    @map_id = 0                       
    @event_id = 0                     
    @message_waiting = false          
    @move_route_waiting = false       
    @button_input_variable_id = 0     
    @wait_count = 0                   
    @child_interpreter = nil          
    @branch = {}                      
  end

  def setup(list, event_id)
    clear
    @map_id = $game_map.map_id
    @event_id = event_id
    @list = list
    @index = 0
    @branch.clear
  end

  def running?
    return @list != nil
  end

  def setup_starting_event
    if $game_map.need_refresh
      $game_map.refresh
    end
    
    if $game_temp.common_event_id > 0
      setup($data_common_events[$game_temp.common_event_id].list, 0)
      $game_temp.common_event_id = 0
      return
    end
    
    for event in $game_map.events.values
      if event.starting
        if event.trigger < 3
          event.clear_starting
          event.lock
        end
        
        setup(event.list, event.id)
        return
      end
    end
    
    for common_event in $data_common_events.compact
      if common_event.trigger == 1 and
          $game_switches[common_event.switch_id] == true
        setup(common_event.list, 0)
        return
      end
    end
  end

  def update
    @loop_count = 0
    loop do
      @loop_count += 1
      if @loop_count > 100
        Graphics.update
        @loop_count = 0
      end
      
      if $game_map.map_id != @map_id
        @event_id = 0
      end
      
      if @child_interpreter != nil
        @child_interpreter.update
        unless @child_interpreter.running?
          @child_interpreter = nil
        end
        if @child_interpreter != nil
          return
        end
      end
      
      if @message_waiting
        return
      end
      
      if @move_route_waiting
        if $game_player.move_route_forcing
          return
        end
        for event in $game_map.events.values
          if event.move_route_forcing
            return
          end
        end
        @move_route_waiting = false
      end
      
      if @button_input_variable_id > 0
        input_button
        return
      end
      
      if @wait_count > 0
        @wait_count -= 1
        return
      end
      
      if $game_temp.forcing_battler != nil
        return
      end
      
      if $game_temp.battle_calling or
          $game_temp.shop_calling or
          $game_temp.name_calling or
          $game_temp.menu_calling or
          $game_temp.save_calling or
          $game_temp.gameover
        return
      end
      
      if @list == nil
        if @main
          setup_starting_event
        end
        if @list == nil
          return
        end
      end
      
      if execute_command == false
        return
      end
      
      @index += 1
    end
  end

  def input_button
    n = 0
    for i in 1..18
      if Input.trigger?(i)
        n = i
      end
    end
    
    if n > 0
      $game_variables[@button_input_variable_id] = n
      $game_map.need_refresh = true
      @button_input_variable_id = 0
    end
  end

  def setup_choices(parameters)
    $game_temp.choice_max = parameters[0].size
    for text in parameters[0]
      $game_temp.message_text += text + "\n"
    end
    $game_temp.choice_cancel_type = parameters[1]
    
    current_indent = @list[@index].indent
    $game_temp.choice_proc = Proc.new { |n| @branch[current_indent] = n }
  end

  def iterate_actor(parameter)
    if parameter == 0
      for actor in $game_party.actors
        yield actor
      end
    else
      actor = $game_actors[parameter]
      yield actor if actor != nil
    end
  end

  def iterate_enemy(parameter)
    if parameter == -1
      for enemy in $game_troop.enemies
        yield enemy
      end
    else
      enemy = $game_troop.enemies[parameter]
      yield enemy if enemy != nil
    end
  end

  def iterate_battler(parameter1, parameter2)
    if parameter1 == 0
      iterate_enemy(parameter2) do |enemy|
        yield enemy
      end
    else
      if parameter2 == -1
        for actor in $game_party.actors
          yield actor
        end
      else
        actor = $game_party.actors[parameter2]
        yield actor if actor != nil
      end
    end
  end
end