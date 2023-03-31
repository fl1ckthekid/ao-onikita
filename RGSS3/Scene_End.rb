class Scene_End
  def main
    s1 = "Back to Title"
    s2 = "Quit"
    s3 = "Cancel"
    @command_window = Window_Command.new(192, [s1, s2, s3])
    @command_window.x = 320 - @command_window.width / 2
    @command_window.y = 240 - @command_window.height / 2
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
    if $scene.is_a?(Scene_Title)
      Graphics.transition
      Graphics.freeze
    end
  end
  def update
    @command_window.update
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      $scene = Scene_Menu.new(2)
      return
    end
    if Input.trigger?(Input::C)
      case @command_window.index
      when 0
        command_to_title
      when 1
        command_shutdown
      when 2
        command_cancel
      end
      return
    end
  end
  def command_to_title
    $game_system.se_play($data_system.decision_se)
    Audio.bgm_fade(800)
    Audio.bgs_fade(800)
    Audio.me_fade(800)
    $scene = Scene_Title.new
  end
  def command_shutdown
    $game_system.se_play($data_system.decision_se)
    Audio.bgm_fade(800)
    Audio.bgs_fade(800)
    Audio.me_fade(800)
    $scene = nil
  end
  def command_cancel
    $game_system.se_play($data_system.decision_se)
    $scene = Scene_Menu.new(2)
  end
end