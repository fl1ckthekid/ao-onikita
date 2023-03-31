class Scene_Name
  def main
    @actor = $game_actors[$game_temp.name_actor_id]
    @edit_window = Window_NameEdit.new(@actor, $game_temp.name_max_char)
    @input_window = Window_NameInput.new
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      if $scene != self
        break
      end
    end
    Graphics.freeze
    @edit_window.dispose
    @input_window.dispose
  end
  def update
    @edit_window.update
    @input_window.update
    if Input.repeat?(Input::B)
      if @edit_window.index == 0
        return
      end
      $game_system.se_play($data_system.cancel_se)
      @edit_window.back
      return
    end
    if Input.trigger?(Input::C)
      if @input_window.character == nil
        if @edit_window.name == ""
          @edit_window.restore_default
          if @edit_window.name == ""
            $game_system.se_play($data_system.buzzer_se)
            return
          end
          $game_system.se_play($data_system.decision_se)
          return
        end
        @actor.name = @edit_window.name
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_Map.new
        return
      end
      if @edit_window.index == $game_temp.name_max_char
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      if @input_window.character == ""
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      $game_system.se_play($data_system.decision_se)
      @edit_window.add(@input_window.character)
      return
    end
  end
end