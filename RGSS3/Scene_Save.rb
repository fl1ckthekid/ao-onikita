class Scene_Save < Scene_File
  def initialize
    super("Where do you want to save?")
  end
  def on_decision(filename)
    $game_system.se_play($data_system.save_se)
    file = File.open(filename, "wb")
    write_save_data(file)
    file.close
    if $game_temp.save_calling
      $game_temp.save_calling = false
      $scene = Scene_Map.new
      return
    end
    $scene = Scene_Menu.new(1)
  end
  def on_cancel
    $game_system.se_play($data_system.cancel_se)
    if $game_temp.save_calling
      $game_temp.save_calling = false
      $scene = Scene_Map.new
      return
    end
    $scene = Scene_Menu.new(1)
  end
  def write_save_data(file)
    characters = []
    for i in 0...$game_party.actors.size
      actor = $game_party.actors[i]
      characters.push([actor.character_name, actor.character_hue])
    end
    Marshal.dump(characters, file)
    Marshal.dump(Graphics.frame_count, file)
    $game_system.save_count += 1
    $game_system.magic_number = $data_system.magic_number
    Marshal.dump($game_system, file)
    Marshal.dump($game_switches, file)
    Marshal.dump($game_variables, file)
    Marshal.dump($game_self_switches, file)
    Marshal.dump($game_screen, file)
    Marshal.dump($game_actors, file)
    Marshal.dump($game_party, file)
    Marshal.dump($game_troop, file)
    Marshal.dump($game_map, file)
    Marshal.dump($game_player, file)
  end
end