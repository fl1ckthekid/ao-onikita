class Scene_Map
  def main
    @spriteset = Spriteset_Map.new
    @message_window = Window_Message.new
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
    @spriteset.dispose
    @message_window.dispose
    if $scene.is_a?(Scene_Title)
      Graphics.transition
      Graphics.freeze
    end
  end
  def update
    loop do
      $game_map.update
      $game_system.map_interpreter.update
      $game_player.update
      $game_system.update
      $game_screen.update
      unless $game_temp.player_transferring
        break
      end
      transfer_player
      if $game_temp.transition_processing
        break
      end
    end
    @spriteset.update
    @message_window.update
    if $game_temp.gameover
      $scene = Scene_Gameover.new
      return
    end
    if $game_temp.to_title
      $scene = Scene_Title.new
      return
    end
    if $game_temp.transition_processing
      $game_temp.transition_processing = false
      if $game_temp.transition_name == ""
        Graphics.transition(20)
      else
        Graphics.transition(40, "Graphics/Transitions/" +
          $game_temp.transition_name)
      end
    end
    if $game_temp.message_window_showing
      return
    end
    if $game_player.encounter_count == 0 and $game_map.encounter_list != []
      unless $game_system.map_interpreter.running? or
             $game_system.encounter_disabled
        n = rand($game_map.encounter_list.size)
        troop_id = $game_map.encounter_list[n]
        if $data_troops[troop_id] != nil
          $game_temp.battle_calling = true
          $game_temp.battle_troop_id = troop_id
          $game_temp.battle_can_escape = true
          $game_temp.battle_can_lose = false
          $game_temp.battle_proc = nil
        end
      end
    end
    if Input.trigger?(Input::B)
      unless $game_system.map_interpreter.running? or
             $game_system.menu_disabled
        $game_temp.menu_calling = true
        $game_temp.menu_beep = true
      end
    end
    if $DEBUG and Input.press?(Input::F9)
      $game_temp.debug_calling = true
    end
    unless $game_player.moving?
      if $game_temp.battle_calling
        call_battle
      elsif $game_temp.shop_calling
        call_shop
      elsif $game_temp.name_calling
        call_name
      elsif $game_temp.menu_calling
        call_menu
      elsif $game_temp.save_calling
        call_save
      elsif $game_temp.debug_calling
        call_debug
      end
    end
  end
  def call_battle
    $game_temp.battle_calling = false
    $game_temp.menu_calling = false
    $game_temp.menu_beep = false
    $game_player.make_encounter_count
    $game_temp.map_bgm = $game_system.playing_bgm
    $game_system.bgm_stop
    $game_system.se_play($data_system.battle_start_se)
    $game_system.bgm_play($game_system.battle_bgm)
    $game_player.straighten
    $scene = Scene_Battle.new
  end
  def call_shop
    $game_temp.shop_calling = false
    $game_player.straighten
    $scene = Scene_Shop.new
  end
  def call_name
    $game_temp.name_calling = false
    $game_player.straighten
    $scene = Scene_Name.new
  end
  def call_menu
    $game_temp.menu_calling = false
    if $game_temp.menu_beep
      $game_system.se_play($data_system.decision_se)
      $game_temp.menu_beep = false
    end
    $game_player.straighten
    $scene = Scene_Menu.new
  end
  def call_save
    $game_player.straighten
    $scene = Scene_Save.new
  end
  def call_debug
    $game_temp.debug_calling = false
    $game_system.se_play($data_system.decision_se)
    $game_player.straighten
    $scene = Scene_Debug.new
  end
  def transfer_player
    $game_temp.player_transferring = false
    if $game_map.map_id != $game_temp.player_new_map_id
      $game_map.setup($game_temp.player_new_map_id)
    end
    $game_player.moveto($game_temp.player_new_x, $game_temp.player_new_y)
    case $game_temp.player_new_direction
    when 2
      $game_player.turn_down
    when 4
      $game_player.turn_left
    when 6
      $game_player.turn_right
    when 8
      $game_player.turn_up
    end
    $game_player.straighten
    $game_map.update
    @spriteset.dispose
    @spriteset = Spriteset_Map.new
    if $game_temp.transition_processing
      $game_temp.transition_processing = false
      Graphics.transition(20)
    end
    $game_map.autoplay
    Graphics.frame_reset
    Input.update
  end
end