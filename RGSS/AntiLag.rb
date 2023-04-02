module Update_Range
  def in_range?(object)
    display_x = $game_map.display_x - 512
    display_y = $game_map.display_y - 512
    display_width = $game_map.display_x + 2916
    display_height = $game_map.display_y + 2570
    if object.real_x <= display_x or
      object.real_x >= display_width or
      object.real_y <= display_y or
      object.real_y >= display_height
      return false
    end
    return true
  end  
end
  
class Game_Map
  include Update_Range
  def update
    if $game_map.need_refresh
      refresh
    end
    if @scroll_rest > 0
      distance = 2 ** @scroll_speed
      case @scroll_direction
      when 2
        scroll_down(distance)
      when 4 
        scroll_left(distance)
      when 6  
        scroll_right(distance)
      when 8  
        scroll_up(distance)
      end
      @scroll_rest -= distance
    end
  
    for event in @events.values
      if event.trigger == 3 or event.trigger == 4 or event.lag_include or in_range?(event)
        event.update
      end
    end
  
    for common_event in @common_events.values
      common_event.update
    end
    @fog_ox -= @fog_sx / 8.0
    @fog_oy -= @fog_sy / 8.0
    if @fog_tone_duration >= 1
      d = @fog_tone_duration
      target = @fog_tone_target
      @fog_tone.red = (@fog_tone.red * (d - 1) + target.red) / d
      @fog_tone.green = (@fog_tone.green * (d - 1) + target.green) / d
      @fog_tone.blue = (@fog_tone.blue * (d - 1) + target.blue) / d
      @fog_tone.gray = (@fog_tone.gray * (d - 1) + target.gray) / d
      @fog_tone_duration -= 1
    end
    if @fog_opacity_duration >= 1
      d = @fog_opacity_duration
      @fog_opacity = (@fog_opacity * (d - 1) + @fog_opacity_target) / d
      @fog_opacity_duration -= 1
    end
  end
end
  
class Spriteset_Map
  include Update_Range
  def update
    if @panorama_name != $game_map.panorama_name or
       @panorama_hue != $game_map.panorama_hue
      @panorama_name = $game_map.panorama_name
      @panorama_hue = $game_map.panorama_hue
      if @panorama.bitmap != nil
        @panorama.bitmap.dispose
        @panorama.bitmap = nil
      end
      if @panorama_name != ""
        @panorama.bitmap = RPG::Cache.panorama(@panorama_name, @panorama_hue)
      end
      Graphics.frame_reset
    end
    if @fog_name != $game_map.fog_name or @fog_hue != $game_map.fog_hue
      @fog_name = $game_map.fog_name
      @fog_hue = $game_map.fog_hue
      if @fog.bitmap != nil
        @fog.bitmap.dispose
        @fog.bitmap = nil
      end
      if @fog_name != ""
        @fog.bitmap = RPG::Cache.fog(@fog_name, @fog_hue)
      end
      Graphics.frame_reset
    end

    @tilemap.ox = $game_map.display_x / 4
    @tilemap.oy = $game_map.display_y / 4
    @tilemap.update
    @panorama.ox = $game_map.display_x / 8
    @panorama.oy = $game_map.display_y / 8
    @fog.zoom_x = $game_map.fog_zoom / 100.0
    @fog.zoom_y = $game_map.fog_zoom / 100.0
    @fog.opacity = $game_map.fog_opacity
    @fog.blend_type = $game_map.fog_blend_type
    @fog.ox = $game_map.display_x / 4 + $game_map.fog_ox
    @fog.oy = $game_map.display_y / 4 + $game_map.fog_oy
    @fog.tone = $game_map.fog_tone
  
    for sprite in @character_sprites
      if sprite.character.is_a?(Game_Event)
      if sprite.character.trigger == 3 or sprite.character.trigger == 4 or
        sprite.character.lag_include or in_range?(sprite.character)
          sprite.update         
      end
      else
        sprite.update
      end
    end
    
    @weather.type = $game_screen.weather_type
    @weather.max = $game_screen.weather_max
    @weather.ox = $game_map.display_x / 4
    @weather.oy = $game_map.display_y / 4
    @weather.update
    for sprite in @picture_sprites
      sprite.update
    end
    @timer_sprite.update
    @viewport1.tone = $game_screen.tone
    @viewport1.ox = $game_screen.shake
    @viewport3.color = $game_screen.flash_color
    @viewport1.update
    @viewport3.update
  end
end
  
class Interpreter
  unless self.method_defined?('anti_lag_command_209')
    alias anti_lag_command_209 command_209
  end
  
  def command_209
    anti_lag_command_209
    character = get_character(@parameters[0])
    if character == nil or character.is_a?(Game_Player)
    return true
    end
    character.lag_include = true
  end
end
  
class Game_Event < Game_Character
  attr_accessor:lag_include
  unless self.method_defined?('anti_lag_initialize')
    alias anti_lag_initialize initialize
  end
  
  def initialize(map_id, event, *args)
    anti_lag_initialize(map_id, event, *args)
    check_name_tags(event)    
  end
  
  def check_name_tags(event)
    event.name.gsub(/\\al_update/i) {@lag_include = true}
  end
end