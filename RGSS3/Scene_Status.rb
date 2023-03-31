class Scene_Status
  def initialize(actor_index = 0, equip_index = 0)
    @actor_index = actor_index
  end
  def main
    @actor = $game_party.actors[@actor_index]
    @status_window = Window_Status.new(@actor)
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
    @status_window.dispose
  end
  def update
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      $scene = Scene_Menu.new(3)
      return
    end
    if Input.trigger?(Input::R)
      $game_system.se_play($data_system.cursor_se)
      @actor_index += 1
      @actor_index %= $game_party.actors.size
      $scene = Scene_Status.new(@actor_index)
      return
    end
    if Input.trigger?(Input::L)
      $game_system.se_play($data_system.cursor_se)
      @actor_index += $game_party.actors.size - 1
      @actor_index %= $game_party.actors.size
      $scene = Scene_Status.new(@actor_index)
      return
    end
  end
end