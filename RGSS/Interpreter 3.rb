class Interpreter

  def command_101
    if $game_temp.message_text != nil
      return false
    end
    
    @message_waiting = true
    $game_temp.message_proc = Proc.new { @message_waiting = false }
    $game_temp.message_text = @list[@index].parameters[0] + "\n"
    line_count = 1
    
    loop do
      if @list[@index+1].code == 401
        $game_temp.message_text += @list[@index+1].parameters[0] + "\n"
        line_count += 1
      else
        if @list[@index+1].code == 102
          if @list[@index+1].parameters[0].size <= 4 - line_count
            @index += 1
            $game_temp.choice_start = line_count
            setup_choices(@list[@index].parameters)
          end
        elsif @list[@index+1].code == 103
          if line_count < 4
            @index += 1
            $game_temp.num_input_start = line_count
            $game_temp.num_input_variable_id = @list[@index].parameters[0]
            $game_temp.num_input_digits_max = @list[@index].parameters[1]
          end
        end
        return true
      end
      @index += 1
    end
  end

  def command_102
    if $game_temp.message_text != nil
      return false
    end
    
    @message_waiting = true
    $game_temp.message_proc = Proc.new { @message_waiting = false }
    $game_temp.message_text = ""
    $game_temp.choice_start = 0
    setup_choices(@parameters)
    
    return true
  end

  def command_402
    if @branch[@list[@index].indent] == @parameters[0]
      @branch.delete(@list[@index].indent)
      return true
    end
    return command_skip
  end

  def command_403
    if @branch[@list[@index].indent] == 4
      @branch.delete(@list[@index].indent)
      return true
    end
    return command_skip
  end

  def command_103
    if $game_temp.message_text != nil
      return false
    end
    
    @message_waiting = true
    $game_temp.message_proc = Proc.new { @message_waiting = false }
    $game_temp.message_text = ""
    $game_temp.num_input_start = 0
    $game_temp.num_input_variable_id = @parameters[0]
    $game_temp.num_input_digits_max = @parameters[1]
    
    return true
  end

  def command_104
    if $game_temp.message_window_showing
      return false
    end
    
    $game_system.message_position = @parameters[0]
    $game_system.message_frame = @parameters[1]
    return true
  end

  def command_105
    @button_input_variable_id = @parameters[0]
    @index += 1
    return false
  end

  def command_106
    @wait_count = @parameters[0] * 2
    return true
  end

  def command_111
    result = false
    case @parameters[0]
    when 0  
      result = ($game_switches[@parameters[1]] == (@parameters[2] == 0))
    when 1  
      value1 = $game_variables[@parameters[1]]
      if @parameters[2] == 0
        value2 = @parameters[3]
      else
        value2 = $game_variables[@parameters[3]]
      end
      case @parameters[4]
      when 0  
        result = (value1 == value2)
      when 1  
        result = (value1 >= value2)
      when 2  
        result = (value1 <= value2)
      when 3  
        result = (value1 > value2)
      when 4  
        result = (value1 < value2)
      when 5  
        result = (value1 != value2)
      end
    when 2  
      if @event_id > 0
        key = [$game_map.map_id, @event_id, @parameters[1]]
        if @parameters[2] == 0
          result = ($game_self_switches[key] == true)
        else
          result = ($game_self_switches[key] != true)
        end
      end
    when 3  
      if $game_system.timer_working
        sec = $game_system.timer / Graphics.frame_rate
        if @parameters[2] == 0
          result = (sec >= @parameters[1])
        else
          result = (sec <= @parameters[1])
        end
      end
    when 4  
      actor = $game_actors[@parameters[1]]
      if actor != nil
        case @parameters[2]
        when 0  
          result = ($game_party.actors.include?(actor))
        when 1  
          result = (actor.name == @parameters[3])
        when 2  
          result = (actor.skill_learn?(@parameters[3]))
        when 3  
          result = (actor.weapon_id == @parameters[3])
        when 4  
          result = (actor.armor1_id == @parameters[3] or
                    actor.armor2_id == @parameters[3] or
                    actor.armor3_id == @parameters[3])
        when 5  
          result = (actor.state?(@parameters[3]))
        end
      end
    when 5  
      enemy = $game_troop.enemies[@parameters[1]]
      if enemy != nil
        case @parameters[2]
        when 0  
          result = (enemy.exist?)
        when 1  
          result = (enemy.state?(@parameters[3]))
        end
      end
    when 6  
      character = get_character(@parameters[1])
      if character != nil
        result = (character.direction == @parameters[2])
      end
    when 7  
      if @parameters[2] == 0
        result = ($game_party.gold >= @parameters[1])
      else
        result = ($game_party.gold <= @parameters[1])
      end
    when 8  
      result = ($game_party.item_number(@parameters[1]) > 0)
    when 9  
      result = ($game_party.weapon_number(@parameters[1]) > 0)
    when 10  
      result = ($game_party.armor_number(@parameters[1]) > 0)
    when 11  
      result = (Input.press?(@parameters[1]))
    when 12  
      result = eval(@parameters[1])
    end
    
    @branch[@list[@index].indent] = result
    if @branch[@list[@index].indent] == true
      @branch.delete(@list[@index].indent)
      return true
    end
    
    return command_skip
  end

  def command_411
    if @branch[@list[@index].indent] == false
      @branch.delete(@list[@index].indent)
      return true
    end
    return command_skip
  end

  def command_112
    return true
  end

  def command_413
    indent = @list[@index].indent
    loop do
      @index -= 1
      if @list[@index].indent == indent
        return true
      end
    end
  end

  def command_113
    indent = @list[@index].indent
    temp_index = @index
    
    loop do
      temp_index += 1
      if temp_index >= @list.size-1
        return true
      end
      
      if @list[temp_index].code == 413 and @list[temp_index].indent < indent
        @index = temp_index
        return true
      end
    end
  end

  def command_115
    command_end
    return true
  end

  def command_116
    if @event_id > 0
      $game_map.events[@event_id].erase
    end
    
    @index += 1
    return false
  end

  def command_117
    common_event = $data_common_events[@parameters[0]]
    if common_event != nil
      @child_interpreter = Interpreter.new(@depth + 1)
      @child_interpreter.setup(common_event.list, @event_id)
    end
    return true
  end

  def command_118
    return true
  end

  def command_119
    label_name = @parameters[0]
    temp_index = 0
    
    loop do
      if temp_index >= @list.size-1
        return true
      end
      if @list[temp_index].code == 118 and
          @list[temp_index].parameters[0] == label_name
        @index = temp_index
        return true
      end
      temp_index += 1
    end
  end
end