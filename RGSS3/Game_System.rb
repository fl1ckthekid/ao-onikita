class Game_System
  attr_reader:map_interpreter
  attr_reader:battle_interpreter
  attr_accessor:timer
  attr_accessor:timer_working
  attr_accessor:save_disabled
  attr_accessor:menu_disabled
  attr_accessor:encounter_disabled
  attr_accessor:message_position
  attr_accessor:message_frame
  attr_accessor:save_count
  attr_accessor:magic_number

  def initialize
    @map_interpreter = Interpreter.new(0, true)
    @battle_interpreter = Interpreter.new(0, false)
    @timer = 0
    @timer_working = false
    @save_disabled = false
    @menu_disabled = false
    @encounter_disabled = false
    @message_position = 2
    @message_frame = 0
    @save_count = 0
    @magic_number = 0
  end

  def bgm_play(bgm)
    @playing_bgm = bgm
    if bgm != nil and bgm.name != ""
      Audio.bgm_play("Audio/BGM/" + bgm.name, bgm.volume, bgm.pitch)
    else
      Audio.bgm_stop
    end
    Graphics.frame_reset
  end

  def bgm_stop
    Audio.bgm_stop
  end

  def bgm_fade(time)
    @playing_bgm = nil
    Audio.bgm_fade(time * 1000)
  end

  def bgm_memorize
    @memorized_bgm = @playing_bgm
  end

  def bgm_restore
    bgm_play(@memorized_bgm)
  end

  def bgs_play(bgs)
    @playing_bgs = bgs
    if bgs != nil and bgs.name != ""
      Audio.bgs_play("Audio/BGS/" + bgs.name, bgs.volume, bgs.pitch)
    else
      Audio.bgs_stop
    end
    Graphics.frame_reset
  end

  def bgs_fade(time)
    @playing_bgs = nil
    Audio.bgs_fade(time * 1000)
  end

  def bgs_memorize
    @memorized_bgs = @playing_bgs
  end

  def bgs_restore
    bgs_play(@memorized_bgs)
  end

  def me_play(me)
    if me != nil and me.name != ""
      Audio.me_play("Audio/ME/" + me.name, me.volume, me.pitch)
    else
      Audio.me_stop
    end
    Graphics.frame_reset
  end

  def se_play(se)
    if se != nil and se.name != ""
      Audio.se_play("Audio/SE/" + se.name, se.volume, se.pitch)
    end
  end

  def se_stop
    Audio.se_stop
  end

  def playing_bgm
    return @playing_bgm
  end

  def playing_bgs
    return @playing_bgs
  end

  def windowskin_name
    if @windowskin_name == nil
      return $data_system.windowskin_name
    else
      return @windowskin_name
    end
  end

  def windowskin_name=(windowskin_name)
    @windowskin_name = windowskin_name
  end

  def battle_bgm
    if @battle_bgm == nil
      return $data_system.battle_bgm
    else
      return @battle_bgm
    end
  end

  def battle_bgm=(battle_bgm)
    @battle_bgm = battle_bgm
  end

  def battle_end_me
    if @battle_end_me == nil
      return $data_system.battle_end_me
    else
      return @battle_end_me
    end
  end

  def battle_end_me=(battle_end_me)
    @battle_end_me = battle_end_me
  end

  def update
    if @timer_working and @timer > 0
      @timer -= 1
    end
  end
end