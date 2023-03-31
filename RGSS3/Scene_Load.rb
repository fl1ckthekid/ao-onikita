class Scene_Load < Scene_File
  def initialize
    $game_temp = Game_Temp.new
    $game_temp.last_file_index = 0
    latest_time = Time.at(0)
    for i in 0..3
      filename = make_filename(i)
      if FileTest.exist?(filename)
        file = File.open(filename, "r")
        if file.mtime > latest_time
          latest_time = file.mtime
          $game_temp.last_file_index = i
        end
        file.close
      end
    end
    super("Which file do you want to load?")
  end
  def on_decision(filename)
    unless FileTest.exist?(filename)
      $game_system.se_play($data_system.buzzer_se)
      return
    end
    $game_system.se_play($data_system.load_se)
    file = File.open(filename, "rb")
    read_save_data(file)
    file.close
    $game_system.bgm_play($game_system.playing_bgm)
    $game_system.bgs_play($game_system.playing_bgs)
    $game_map.update
    $scene = Scene_Map.new
  end
  def on_cancel
    $game_system.se_play($data_system.cancel_se)
    $scene = Scene_Title.new
  end
  def read_save_data(file)
    characters = Marshal.load(file)
    Graphics.frame_count = Marshal.load(file)
    $game_system        = Marshal.load(file)
    $game_switches      = Marshal.load(file)
    $game_variables     = Marshal.load(file)
    $game_self_switches = Marshal.load(file)
    $game_screen        = Marshal.load(file)
    $game_actors        = Marshal.load(file)
    $game_party         = Marshal.load(file)
    $game_troop         = Marshal.load(file)
    $game_map           = Marshal.load(file)
    $game_player        = Marshal.load(file)
    if $game_system.magic_number != $data_system.magic_number
      $game_map.setup($game_map.map_id)
      $game_player.center($game_player.x, $game_player.y)
    end
    $game_party.refresh
  end
end