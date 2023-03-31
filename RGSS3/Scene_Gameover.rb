class Scene_Gameover
  def main
    @sprite = Sprite.new
    @sprite.bitmap = RPG::Cache.gameover($data_system.gameover_name)
    $game_system.bgm_play(nil)
    $game_system.bgs_play(nil)
    $game_system.me_play($data_system.gameover_me)
    Graphics.transition(120)
    loop do
      Graphics.update
      Input.update
      update
      if $scene != self
        break
      end
    end
    Graphics.freeze
    @sprite.bitmap.dispose
    @sprite.dispose
    Graphics.transition(40)
    Graphics.freeze
    if $BTEST
      $scene = nil
    end
  end
  def update
    if Input.trigger?(Input::C)
      $scene = Scene_Title.new
    end
  end
end