class Scene_File
  def initialize(help_text)
    @help_text = help_text
  end
  def main
    @help_window = Window_Help.new
    @help_window.set_text(@help_text)
    @savefile_windows = []
    for i in 0..3
      @savefile_windows.push(Window_SaveFile.new(i, make_filename(i)))
    end
    @file_index = $game_temp.last_file_index
    @savefile_windows[@file_index].selected = true
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
    @help_window.dispose
    for i in @savefile_windows
      i.dispose
    end
  end
  def update
    @help_window.update
    for i in @savefile_windows
      i.update
    end
    if Input.trigger?(Input::C)
      on_decision(make_filename(@file_index))
      $game_temp.last_file_index = @file_index
      return
    end
    if Input.trigger?(Input::B)
      on_cancel
      return
    end
    if Input.repeat?(Input::DOWN)
      if Input.trigger?(Input::DOWN) or @file_index < 3
        $game_system.se_play($data_system.cursor_se)
        @savefile_windows[@file_index].selected = false
        @file_index = (@file_index + 1) % 4
        @savefile_windows[@file_index].selected = true
        return
      end
    end
    if Input.repeat?(Input::UP)
      if Input.trigger?(Input::UP) or @file_index > 0
        $game_system.se_play($data_system.cursor_se)
        @savefile_windows[@file_index].selected = false
        @file_index = (@file_index + 3) % 4
        @savefile_windows[@file_index].selected = true
        return
      end
    end
  end
  def make_filename(file_index)
    return "Save#{file_index + 1}.rxdata"
  end
end