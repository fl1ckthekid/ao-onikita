module SIMP
  LOGO = ""
  LOGO_SE = ""
  LOGO_SE_VOLUME = 80
  LOGO_SE_PITCH = 100
  RANDAM = false
  TITLE_SIMPLE_TEXT = ""
  TITLE_SIMPLE_X = 0
  TITLE_SIMPLE_Y = 0
  c = Color.new(255, 255, 255, 255)
  TITLE_SIMPLE_COLOR = c
  TITLE_SIMPLE_SIZE = 50
  TITLE_SIMPLE_FONT = "MS Mincho"
  TITLE_SKIN = "wskin_n"
  TITLE_X = 320 - 192 / 2
  TITLE_Y = 188
  TITLE_WIDTH = 192
  TITLE_OPACITY = 0
  TITLE_BACK_OPACITY = 0
  NEWGAME = "New Game"
  CONTINUE = "Continue"
  HELP = "Help"
  SITE = "Homepage"
  SCREEN = "Screen"
  SHUTDOWN = "Quit"
  CONTINUE_USE = true
  SCREEN_USE = false
  SITE_URL = ""
  SITE_EXIT = true
  HELP_FILE = ""
  TITLE_TRANSITION1 = 20
  TITLE_TRANSITION2 = 20
  TITLE_TRANSITION3 = 20
end

class Scene_Title
  def main
    if $BTEST
      battle_test
      return
    end    
    $data_actors = load_data("Data/Actors.rxdata")
    $data_classes = load_data("Data/Classes.rxdata")
    $data_skills = load_data("Data/Skills.rxdata")
    $data_items = load_data("Data/Items.rxdata")
    $data_weapons = load_data("Data/Weapons.rxdata")
    $data_armors = load_data("Data/Armors.rxdata")
    $data_enemies = load_data("Data/Enemies.rxdata")
    $data_troops = load_data("Data/Troops.rxdata")
    $data_states = load_data("Data/States.rxdata")
    $data_animations = load_data("Data/Animations.rxdata")
    $data_tilesets = load_data("Data/Tilesets.rxdata")
    $data_common_events = load_data("Data/CommonEvents.rxdata")
    $data_system = load_data("Data/System.rxdata")
    $game_system = Game_System.new
    @sprite = Sprite.new
    unless SIMP::LOGO == ""
      @sprite.bitmap = RPG::Cache.picture(SIMP::LOGO)
      @sprite.x = (640 - @sprite.bitmap.width) / 2
      @sprite.y = (480 - @sprite.bitmap.height) / 2
      unless SIMP::LOGO_SE == ""
        filename = "Audio/SE/" + SIMP::LOGO_SE
        Audio.se_play(filename, SIMP::LOGO_SE_VOLUME, SIMP::LOGO_SE_PITCH)
      end
      Graphics.transition(SIMP::TITLE_TRANSITION1)
      loop do
        Graphics.update
        Input.update
        if Input.trigger?(Input::B) or Input.trigger?(Input::C)
          Graphics.freeze
          @sprite.bitmap.dispose
          @sprite.x = @sprite.y = 0
          Graphics.transition(SIMP::TITLE_TRANSITION2)
          Graphics.freeze
          break
        end
      end
    end
    if SIMP::RANDAM
      size = $data_system.title_name.size - 2
      basic = $data_system.title_name[0, size]
      i = 1
      loop do
        i += 1
        n = "0" + i.to_s if i < 10
        unless title_exist?(basic + n)
          break
        end
      end
      n = rand(i) + 1
      n = "0" + n.to_s if n < 10
      name = basic + n
    else
      name = $data_system.title_name
    end
    @sprite.bitmap = RPG::Cache.title(name)
    unless SIMP::TITLE_SIMPLE_TEXT == ""
      x = SIMP::TITLE_SIMPLE_X
      y = SIMP::TITLE_SIMPLE_Y
      height = SIMP::TITLE_SIMPLE_SIZE + 10
      @sprite.bitmap.font.color = SIMP::TITLE_SIMPLE_COLOR
      @sprite.bitmap.font.size = SIMP::TITLE_SIMPLE_SIZE
      @sprite.bitmap.font.name = SIMP::TITLE_SIMPLE_FONT
      @sprite.bitmap.draw_text(x, y, 640, height, SIMP::TITLE_SIMPLE_TEXT)
    end
    s1 = SIMP::NEWGAME
    s2 = SIMP::CONTINUE
    s3 = SIMP::HELP
    s4 = SIMP::SITE
    s5 = SIMP::SCREEN
    s6 = SIMP::SHUTDOWN
    @commands = [s1]
    if SIMP::CONTINUE_USE
      @commands.push(s2)
    end
    unless SIMP::HELP_FILE == ""
      @commands.push(s3)
    end
    unless SIMP::SITE_URL == ""
      @commands.push(s4)
    end
    if SIMP::SCREEN_USE
      @commands.push(s5)
    end
    @commands.push(s6)
    @command_window = Window_Command.new(SIMP::TITLE_WIDTH, @commands)
    @command_window.windowskin = RPG::Cache.windowskin(SIMP::TITLE_SKIN)
    @command_window.opacity = SIMP::TITLE_OPACITY
    @command_window.back_opacity = SIMP::TITLE_BACK_OPACITY
    @command_window.x = SIMP::TITLE_X
    @command_window.y = SIMP::TITLE_Y
    @continue_enabled = false
    for i in 0..3
      if FileTest.exist?("Save#{i+1}.rxdata")
        @continue_enabled = true
      end
    end
    if @continue_enabled
      @command_window.index = 1
    else
      @command_window.disable_item(1)
    end
    $game_system.bgm_play($data_system.title_bgm)
    Audio.me_stop
    Audio.bgs_stop
    Graphics.transition(SIMP::TITLE_TRANSITION3)
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
    @title.dispose unless SIMP::TITLE_SIMPLE_TEXT == ""
    @sprite.bitmap.dispose
    @sprite.dispose
  end
  def title_exist?(filename)
    begin
      RPG::Cache.title(filename)
    rescue
      return false
    end
    return true
  end
  def update
    @command_window.update
    if Input.trigger?(Input::C)
      case @commands[@command_window.index]
      when SIMP::NEWGAME
        command_new_game
      when SIMP::CONTINUE
        command_continue
      when SIMP::HELP
        command_help
      when SIMP::SITE
        command_site
      when SIMP::SCREEN
        command_screen
      when SIMP::SHUTDOWN
        command_shutdown
      end
    end
  end
  def command_help
    $game_system.se_play($data_system.decision_se)
    $scene = Scene_Help.new
  end
  def command_site
    $game_system.se_play($data_system.decision_se)
    Thread.start do
      system("explorer.exe", SIMP::SITE_URL)
    end
    exit if SIMP::SITE_EXIT
  end
  def command_screen
    $game_system.se_play($data_system.decision_se)
    keybd = Win32API.new 'user32.dll', 'keybd_event', ['i', 'i', 'l', 'l'], 'v'
    keybd.call 0xA4, 0, 0, 0
    keybd.call 13, 0, 0, 0
    keybd.call 13, 0, 2, 0
    keybd.call 0xA4, 0, 2, 0
  end
end

class Scene_Help
  def main
    @sprite = Sprite.new
    @sprite.bitmap = RPG::Cache.gameover(SIMP::HELP_FILE)
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
    @sprite.bitmap.dispose
    @sprite.dispose
    Graphics.transition
    Graphics.freeze
  end
  def update
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      $scene = Scene_Title.new
    end
  end
end