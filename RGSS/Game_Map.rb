class Game_Map
  attr_accessor:tileset_name             
  attr_accessor:autotile_names           
  attr_accessor:panorama_name            
  attr_accessor:panorama_hue             
  attr_accessor:fog_name                 
  attr_accessor:fog_hue                  
  attr_accessor:fog_opacity              
  attr_accessor:fog_blend_type           
  attr_accessor:fog_zoom                 
  attr_accessor:fog_sx                   
  attr_accessor:fog_sy                   
  attr_accessor:battleback_name          
  attr_accessor:display_x                
  attr_accessor:display_y                
  attr_accessor:need_refresh             
  attr_reader:passages                 
  attr_reader:priorities               
  attr_reader:terrain_tags             
  attr_reader:events                   
  attr_reader:fog_ox                   
  attr_reader:fog_oy                   
  attr_reader:fog_tone                 

  def initialize
    @map_id = 0
    @display_x = 0
    @display_y = 0
  end

  def setup(map_id)
    @map_id = map_id
    @map = load_data(sprintf("Data/Map%03d.rxdata", @map_id))
    tileset = $data_tilesets[@map.tileset_id]
    @tileset_name = tileset.tileset_name
    @autotile_names = tileset.autotile_names
    @panorama_name = tileset.panorama_name
    @panorama_hue = tileset.panorama_hue
    @fog_name = tileset.fog_name
    @fog_hue = tileset.fog_hue
    @fog_opacity = tileset.fog_opacity
    @fog_blend_type = tileset.fog_blend_type
    @fog_zoom = tileset.fog_zoom
    @fog_sx = tileset.fog_sx
    @fog_sy = tileset.fog_sy
    @battleback_name = tileset.battleback_name
    @passages = tileset.passages
    @priorities = tileset.priorities
    @terrain_tags = tileset.terrain_tags
    
    @display_x = 0
    @display_y = 0
    
    @need_refresh = false
    
    @events = {}
    for i in @map.events.keys
      @events[i] = Game_Event.new(@map_id, @map.events[i])
    end
    
    @common_events = {}
    for i in 1...$data_common_events.size
      @common_events[i] = Game_CommonEvent.new(i)
    end
    
    @fog_ox = 0
    @fog_oy = 0
    @fog_tone = Tone.new(0, 0, 0, 0)
    @fog_tone_target = Tone.new(0, 0, 0, 0)
    @fog_tone_duration = 0
    @fog_opacity_duration = 0
    @fog_opacity_target = 0
    
    @scroll_direction = 2
    @scroll_rest = 0
    @scroll_speed = 4
  end

  def map_id
    return @map_id
  end

  def width
    return @map.width
  end

  def height
    return @map.height
  end

  def encounter_list
    return @map.encounter_list
  end

  def encounter_step
    return @map.encounter_step
  end

  def data
    return @map.data
  end

  def autoplay
    if @map.autoplay_bgm
      $game_system.bgm_play(@map.bgm)
    end
    if @map.autoplay_bgs
      $game_system.bgs_play(@map.bgs)
    end
  end

  def refresh
    if @map_id > 0
      for event in @events.values
        event.refresh
      end
      for common_event in @common_events.values
        common_event.refresh
      end
    end
    @need_refresh = false
  end

  def scroll_down(distance)
    @display_y = [@display_y + distance, (self.height - 15) * 128].min
  end

  def scroll_left(distance)
    @display_x = [@display_x - distance, 0].max
  end

  def scroll_right(distance)
    @display_x = [@display_x + distance, (self.width - 20) * 128].min
  end

  def scroll_up(distance)
    @display_y = [@display_y - distance, 0].max
  end

  def valid?(x, y)
    return (x >= 0 and x < width and y >= 0 and y < height)
  end

  def passable?(x, y, d, self_event = nil)
    unless valid?(x, y)
      return false
    end
    
    bit = (1 << (d / 2 - 1)) & 0x0f
    for event in events.values
      if event.tile_id >= 0 and event != self_event and
          event.x == x and event.y == y and not event.through
        if @passages[event.tile_id] & bit != 0
          return false
        elsif @passages[event.tile_id] & 0x0f == 0x0f
          return false
        elsif @priorities[event.tile_id] == 0
          return true
        end
      end
    end
    for i in [2, 1, 0]
      tile_id = data[x, y, i]
      if tile_id == nil
        return false
      elsif @passages[tile_id] & bit != 0
        return false
      elsif @passages[tile_id] & 0x0f == 0x0f
        return false
      elsif @priorities[tile_id] == 0
        return true
      end
    end
    return true
  end

  def bush?(x, y)
    if @map_id != 0
      for i in [2, 1, 0]
        tile_id = data[x, y, i]
        if tile_id == nil
          return false
        elsif @passages[tile_id] & 0x40 == 0x40
          return true
        end
      end
    end
    return false
  end

  def counter?(x, y)
    if @map_id != 0
      for i in [2, 1, 0]
        tile_id = data[x, y, i]
        if tile_id == nil
          return false
        elsif @passages[tile_id] & 0x80 == 0x80
          return true
        end
      end
    end
    return false
  end

  def terrain_tag(x, y)
    if @map_id != 0
      for i in [2, 1, 0]
        tile_id = data[x, y, i]
        if tile_id == nil
          return 0
        elsif @terrain_tags[tile_id] > 0
          return @terrain_tags[tile_id]
        end
      end
    end
    return 0
  end

  def check_event(x, y)
    for event in $game_map.events.values
      if event.x == x and event.y == y
        return event.id
      end
    end
  end

  def start_scroll(direction, distance, speed)
    @scroll_direction = direction
    @scroll_rest = distance * 128
    @scroll_speed = speed
  end

  def scrolling?
    return @scroll_rest > 0
  end

  def start_fog_tone_change(tone, duration)
    @fog_tone_target = tone.clone
    @fog_tone_duration = duration
    if @fog_tone_duration == 0
      @fog_tone = @fog_tone_target.clone
    end
  end

  def start_fog_opacity_change(opacity, duration)
    @fog_opacity_target = opacity * 1.0
    @fog_opacity_duration = duration
    if @fog_opacity_duration == 0
      @fog_opacity = @fog_opacity_target
    end
  end

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
      event.update
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