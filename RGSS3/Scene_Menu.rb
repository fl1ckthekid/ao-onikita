class Scene_Menu
  def initialize(menu_index = 0)
    @menu_index = menu_index
  end
  def main
    s1 = $data_system.words.item
    s2 = "Save"
    s3 = "Quit"
    @command_window = Window_Command.new(160, [s1, s2, s3])
    @command_window.index = @menu_index
    if $game_party.actors.size == 0
      @command_window.disable_item(0)
      @command_window.disable_item(1)
      @command_window.disable_item(2)
      @command_window.disable_item(3)
    end
    if $game_system.save_disabled
      @command_window.disable_item(4)
    end
    @playtime_window = Window_PlayTime.new
    @playtime_window.x = 0
    @playtime_window.y = 224
    @steps_window = Window_Steps.new
    @steps_window.x = 0
    @steps_window.y = 320
    @status_window = Window_MenuStatus.new
    @status_window.x = 160
    @status_window.y = 0
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
    @command_window.dispose
    @playtime_window.dispose
    @steps_window.dispose
    @status_window.dispose
  end
  def update
    @command_window.update
    @playtime_window.update
    @steps_window.update
    @status_window.update
    if @command_window.active
      update_command
      return
    end
    if @status_window.active
      update_status
      return
    end
  end
  def update_command
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      $scene = Scene_Map.new
      return
    end
    if Input.trigger?(Input::C)
      if $game_party.actors.size == 0 and @command_window.index < 4
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      case @command_window.index
      when 0
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_Item.new
      when 1
        if $game_system.save_disabled
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_Save.new
      when 2
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_End.new
      end
      return
    end
  end
  def update_status
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      @command_window.active = true
      @status_window.active = false
      @status_window.index = -1
      return
    end
    if Input.trigger?(Input::C)
      case @command_window.index
      when 1
        if $game_party.actors[@status_window.index].restriction >= 2
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_Skill.new(@status_window.index)
      when 2
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_Equip.new(@status_window.index)
      when 3
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_Status.new(@status_window.index)
      end
      return
    end
  end
end