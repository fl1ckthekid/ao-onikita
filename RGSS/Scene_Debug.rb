class Scene_Debug
  def main
    @left_window = Window_DebugLeft.new
    @right_window = Window_DebugRight.new
    @help_window = Window_Base.new(192, 352, 448, 128)
    @help_window.contents = Bitmap.new(406, 96)
    @left_window.top_row = $game_temp.debug_top_row
    @left_window.index = $game_temp.debug_index
    @right_window.mode = @left_window.mode
    @right_window.top_id = @left_window.top_id
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      if $scene != self
        break
      end
    end
    $game_map.refresh
    Graphics.freeze
    @left_window.dispose
    @right_window.dispose
    @help_window.dispose
  end
  def update
    @right_window.mode = @left_window.mode
    @right_window.top_id = @left_window.top_id
    @left_window.update
    @right_window.update
    $game_temp.debug_top_row = @left_window.top_row
    $game_temp.debug_index = @left_window.index
    if @left_window.active
      update_left
      return
    end
    if @right_window.active
      update_right
      return
    end
  end
  def update_left
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      $scene = Scene_Map.new
      return
    end
    if Input.trigger?(Input::C)
      $game_system.se_play($data_system.decision_se)
      if @left_window.mode == 0
        text1 = "C (Enter) : ON / OFF"
        @help_window.contents.draw_text(4, 0, 406, 32, text1)
      else
        text1 = "← : -1   → : +1"
        text2 = "L (Pageup) : -10"
        text3 = "R (Pagedown) : +10"
        @help_window.contents.draw_text(4, 0, 406, 32, text1)
        @help_window.contents.draw_text(4, 32, 406, 32, text2)
        @help_window.contents.draw_text(4, 64, 406, 32, text3)
      end
      @left_window.active = false
      @right_window.active = true
      @right_window.index = 0
      return
    end
  end
  def update_right
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      @left_window.active = true
      @right_window.active = false
      @right_window.index = -1
      @help_window.contents.clear
      return
    end
    current_id = @right_window.top_id + @right_window.index
    if @right_window.mode == 0
      if Input.trigger?(Input::C)
        $game_system.se_play($data_system.decision_se)
        $game_switches[current_id] = (not $game_switches[current_id])
        @right_window.refresh
        return
      end
    end
    if @right_window.mode == 1
      if Input.repeat?(Input::RIGHT)
        $game_system.se_play($data_system.cursor_se)
        $game_variables[current_id] += 1
        if $game_variables[current_id] > 99999999
          $game_variables[current_id] = 99999999
        end
        @right_window.refresh
        return
      end
      if Input.repeat?(Input::LEFT)
        $game_system.se_play($data_system.cursor_se)
        $game_variables[current_id] -= 1
        if $game_variables[current_id] < -99999999
          $game_variables[current_id] = -99999999
        end
        @right_window.refresh
        return
      end
      if Input.repeat?(Input::R)
        $game_system.se_play($data_system.cursor_se)
        $game_variables[current_id] += 10
        if $game_variables[current_id] > 99999999
          $game_variables[current_id] = 99999999
        end
        @right_window.refresh
        return
      end
      if Input.repeat?(Input::L)
        $game_system.se_play($data_system.cursor_se)
        $game_variables[current_id] -= 10
        if $game_variables[current_id] < -99999999
          $game_variables[current_id] = -99999999
        end
        @right_window.refresh
        return
      end
    end
  end
end