class Game_System
  FADE_VARIABLE = 10
end

class Game_Temp
  attr_accessor:bgm_fade_time            
  attr_accessor:bgs_fade_time            

  alias zenith15_initialize initialize
  def initialize
    zenith15_initialize
    @bgm_fade_time = 0
    @bgs_fade_time = 0
  end
end

class Game_System
  alias zenith15_bgm_play bgm_play
  def bgm_play(bgm)
    if $game_temp == nil or $game_variables == nil
      zenith15_bgm_play(bgm)
      return
    end
    
    $game_temp.bgm_fade_time = $game_variables[FADE_VARIABLE] * 40
    if $game_temp.bgm_fade_time == 0
      zenith15_bgm_play(bgm)
      return
    end
    
    $game_variables[FADE_VARIABLE] = 0
    @playing_bgm = bgm
    if bgm == nil or bgm.name == ""
      Audio.bgm_stop
      $game_temp.bgm_fade_time = 0
    end
    Graphics.frame_reset
  end

  alias zenith15_bgm_stop bgm_stop
  def bgm_stop
    $game_temp.bgm_fade_time = 0 if $game_temp != nil
    zenith15_bgm_stop
  end

  alias zenith15_bgm_fade bgm_fade
  def bgm_fade(time)
    $game_temp.bgm_fade_time = 0 if $game_temp != nil
    zenith15_bgm_fade(time)
  end

  alias zenith15_bgs_play bgs_play
  def bgs_play(bgs)
    if $game_temp == nil
      zenith15_bgm_play(bgm)
      return
    end
    
    $game_temp.bgs_fade_time = $game_variables[FADE_VARIABLE] * 40
    if $game_temp.bgs_fade_time == 0
      zenith15_bgs_play(bgs)
      return
    end
    
    $game_variables[FADE_VARIABLE] = 0
    @playing_bgs = bgs
    if bgs == nil or bgs.name == ""
      Audio.bgs_stop
      $game_temp.bgs_fade_time = 0
    end
    Graphics.frame_reset
  end

  alias zenith15_bgs_fade bgs_fade
  def bgs_fade(time)
    $game_temp.bgs_fade_time = 0 if $game_temp != nil
    zenith15_bgs_fade(time)
  end

  alias zenith15_update update
  def update
    zenith15_update
    audio_fade_in
  end

  def audio_fade_in
    if $game_temp.bgm_fade_time > 0
      @bgm_fade_count += 1
      bgm = @playing_bgm
      volume = bgm.volume * @bgm_fade_count / $game_temp.bgm_fade_time
      Audio.bgm_play("Audio/BGM/" + bgm.name, volume, bgm.pitch)
      if @bgm_fade_count >= $game_temp.bgm_fade_time
        $game_temp.bgm_fade_time = 0
      end
    else
      @bgm_fade_count = 0
    end
    
    if $game_temp.bgs_fade_time > 0
      @bgs_fade_count += 1
      bgs = @playing_bgs
      volume = bgs.volume * @bgs_fade_count / $game_temp.bgs_fade_time
      Audio.bgs_play("Audio/BGS/" + bgs.name, volume, bgs.pitch)
      if @bgs_fade_count >= $game_temp.bgs_fade_time
        $game_temp.bgs_fade_time = 0
      end
    else
      @bgs_fade_count = 0
    end
  end
end