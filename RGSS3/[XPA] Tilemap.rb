#-------------------------------------------------------------------------------
# The game window's screen resolution. RPG Maker XP's default is [640, 480].
# Do note that a larger resolution is prone to sprite lag.
# Anything larger than the default resolution will enable the custom Plane class.
#-------------------------------------------------------------------------------
SCREEN_RESOLUTION = [640, 480]

#-------------------------------------------------------------------------------
# The largest level of priority your game uses. This value should be between
# 1 and 5. If using a large resolution, lowering the number of priority layers
# will help in reducing the lag.
#-------------------------------------------------------------------------------
MAX_PRIORITY_LAYERS = 3

#-------------------------------------------------------------------------------
# If using a larger resolution than 640x480, the default weather effects will
# not cover the entire map. It is recommended that you set this to true to
# compensate for that, unless you are using some custom weather script that can
# address this.
#-------------------------------------------------------------------------------
WEATHER_ADJUSTMENT = false

#-------------------------------------------------------------------------------
# When the map’s display_x/y variables extend beyond its borders, the map wraps 
# around to fill in the gaps. Setting this to true will prevent that, showing 
# black borders instead.
# If you want some maps to wrap around, putting [WRAP] in a map's name will
# allow this.
# Note that the custom Plane class will be enabled in order to create this
# effect regardless of your resolution size.
#-------------------------------------------------------------------------------
DISABLE_WRAP = false

#-------------------------------------------------------------------------------
# Choose a form of fullscreen for your game. The available choices are:
#  0 = Default RPG Maker fullscreen (changes monitor resolution to 640x480)
#  1 = Stetches game window to player's monitor size (only for XPA)
#  2 = Disable the ability to go into fullscreen
# Please note that if you choose anything other than 0, it disables everything
# on the player's computer from being able to use ALT + ENTER.
#-------------------------------------------------------------------------------
FULLSCREEN_METHOD = 0

#-------------------------------------------------------------------------------
# (only for XPA)
# Button to trigger 2x window size. Disable by setting it to false
#-------------------------------------------------------------------------------
TWICE_SIZE_BUTTON = Input::F5

#-------------------------------------------------------------------------------
# (only for XPA)
# Button to trigger 0.5x window size. Disable by setting it to false
#-------------------------------------------------------------------------------
HALF_SIZE_BUTTON = Input::F6

def autotile_framerate(filename)
  case filename
  when '001-G_Water01' then [8, 8, 8, 8]
  when '009-G2_Water01' then [20, 20, 20, 20]
  when '024-Ocean01' then [32, 16, 32, 16]
  else
    return nil if filename == ''
    w = RPG::Cache.autotile(filename).width
    h = RPG::Cache.autotile(filename).height
    if (h == 32 && w / 32 == 1) || (h == 192 && w / 256 == 1)
      return nil
    else
      return h == 32 ? Array.new(w/32){|i| 16} : Array.new(w/256){|i| 16}
    end
  end
end

FULLSCREEN_METHOD = 0 unless FULLSCREEN_METHOD.between?(0,2)
if FULLSCREEN_METHOD != 0
  reghotkey = Win32API.new('user32', 'RegisterHotKey', 'LIII', 'I')
  reghotkey.call(0, 1, 1, 0x0D)
end

XPACE = RUBY_VERSION == "1.9.2"

MAX_PRIORITY_LAYERS = 5 unless (1..5).include?(MAX_PRIORITY_LAYERS)

if XPACE
  module Input
    GetActiveWindow = Win32API.new('user32', 'GetActiveWindow', '', 'L')
    SetWindowLong = Win32API.new('user32', 'SetWindowLong', 'LIL', 'L')
    SetWindowPos  = Win32API.new('user32', 'SetWindowPos', 'LLIIIII', 'I')
    GetSystemMetrics = Win32API.new('user32', 'GetSystemMetrics', 'I', 'I')
    GetAsyncKeyState = Win32API.new('user32', 'GetAsyncKeyState', 'I', 'I')
    
    @fullscreenKeysReleased = true
    @current_state = 0
    NORMAL_STATE = 0
    FULLSCREEN_STATE = 1
    TWICESIZE_STATE = 2
    HALFSIZE_STATE = 3
    
    class << self
      alias get_fullscreen_keys update
      def update
        enterkey_state = GetAsyncKeyState.call(0x0D)
        if FULLSCREEN_METHOD == 1 && @fullscreenKeysReleased && Input.press?(Input::ALT) && enterkey_state != 0
          @current_state = @current_state == FULLSCREEN_STATE ? NORMAL_STATE : FULLSCREEN_STATE
          @fullscreenKeysReleased = false
          if @current_state == FULLSCREEN_STATE
            full_screen_size
          else
            normal_screen_size
          end
        elsif TWICE_SIZE_BUTTON && Input.trigger?(TWICE_SIZE_BUTTON)
          simulate_alt_enter if fullscreen?
          @current_state = @current_state == TWICESIZE_STATE ? NORMAL_STATE : TWICESIZE_STATE
          if @current_state == TWICESIZE_STATE
            double_screen_size
          else
            normal_screen_size
          end
        elsif HALF_SIZE_BUTTON && Input.trigger?(HALF_SIZE_BUTTON)
          simulate_alt_enter if fullscreen?
          @current_state = @current_state == HALFSIZE_STATE ? NORMAL_STATE : HALFSIZE_STATE
          if @current_state == HALFSIZE_STATE
            half_screen_size
          else
            normal_screen_size
          end
        else
          @fullscreenKeysReleased = (!Input.press?(Input::ALT) || enterkey_state == 0)
        end
        get_fullscreen_keys
      end
      
      def double_screen_size
        rw = GetSystemMetrics.call(0)
        rh = GetSystemMetrics.call(1)
        nw = SCREEN_RESOLUTION[0] * 2
        nh = SCREEN_RESOLUTION[1] * 2
        x = (rw - nw) / 2
        y = (rh - nh) / 2
        w = nw + (GetSystemMetrics.call(5) + GetSystemMetrics.call(45)) * 2
        h = nh + (GetSystemMetrics.call(6) + GetSystemMetrics.call(45)) * 2 + GetSystemMetrics.call(4)
        SetWindowLong.call(GetActiveWindow.call, -16, 0x14CA0000)
        SetWindowPos.call(GetActiveWindow.call, 0, x, y, w, h, 0x0020)
      end
      
      def half_screen_size
        rw = GetSystemMetrics.call(0)
        rh = GetSystemMetrics.call(1)
        nw = SCREEN_RESOLUTION[0] / 2
        nh = SCREEN_RESOLUTION[1] / 2
        x = (rw - nw) / 2
        y = (rh - nh) / 2
        w = nw + (GetSystemMetrics.call(5) + GetSystemMetrics.call(45)) * 2
        h = nh + (GetSystemMetrics.call(6) + GetSystemMetrics.call(45)) * 2 + GetSystemMetrics.call(4)
        SetWindowLong.call(GetActiveWindow.call, -16, 0x14CA0000)
        SetWindowPos.call(GetActiveWindow.call, 0, x, y, w, h, 0x0020)
      end
      
      def full_screen_size
        rw = GetSystemMetrics.call(0)
        rh = GetSystemMetrics.call(1)
        SetWindowLong.call(GetActiveWindow.call, -16, 0x10000000)
        SetWindowPos.call(GetActiveWindow.call, 0, 0, 0, rw, rh, 0)
      end
      
      def normal_screen_size
        rw = GetSystemMetrics.call(0)
        rh = GetSystemMetrics.call(1)
        x = (rw - SCREEN_RESOLUTION[0]) / 2
        y = (rh - SCREEN_RESOLUTION[1]) / 2
        w = SCREEN_RESOLUTION[0] + (GetSystemMetrics.call(5) + GetSystemMetrics.call(45)) * 2
        h = SCREEN_RESOLUTION[1] + (GetSystemMetrics.call(6) + GetSystemMetrics.call(45)) * 2 + GetSystemMetrics.call(4)
        SetWindowLong.call(GetActiveWindow.call, -16, 0x14CA0000)
        SetWindowPos.call(GetActiveWindow.call, 0, x, y, w, h, 0x0020)
      end
      
      def simulate_alt_enter
        keybd = Win32API.new 'user32.dll', 'keybd_event', ['i', 'i', 'l', 'l'], 'v'
        keybd.call(0xA4, 0, 0, 0)
        keybd.call(13, 0, 0, 0)
        keybd.call(13, 0, 2, 0)
        keybd.call(0xA4, 0, 2, 0)
      end
      
      def fullscreen?
        return false if FULLSCREEN_METHOD != 0
        if GetSystemMetrics.call(0) == 640 && GetSystemMetrics.call(1) == 480
          @current_state = FULLSCREEN_STATE
          return true
        end
      end
    end
  end
end

if !XPACE
  module RPG
    @@_ini_file = nil
    def self.ini_file(prepend='')
      return prepend + @@_ini_file unless @@_ini_file.nil?
      len = Dir.pwd.size + 128
      buf = "\0" * len
      Win32API.new('kernel32', 'GetModuleFileName', 'PPL', '').call(nil, buf, len)
      @@_ini_file = buf.delete("\0")[len - 127, buf.size-1].sub(/(.+)\.exe/, '\1.ini')
      prepend + @@_ini_file
    end
  end

  module Resolution
    def self.resize_game
      ini = Win32API.new('kernel32', 'GetPrivateProfileStringA','PPPPLP', 'L')
      title = "\0" * 256
      ini.call('Game', 'Title', '', title, 256, RPG.ini_file('.\\'))
      title.delete!("\0")
      @window = Win32API.new('user32', 'FindWindow', 'PP', 'I').call('RGSS Player', title)
      set_window_long = Win32API.new('user32', 'SetWindowLong', 'LIL', 'L')
      set_window_pos = Win32API.new('user32', 'SetWindowPos', 'LLIIIII', 'I')
      @metrics = Win32API.new('user32', 'GetSystemMetrics', 'I', 'I')
      default_size = Resolution.size 
      x = (@metrics.call(0) - SCREEN_RESOLUTION[0]) / 2
      y = (@metrics.call(1) - SCREEN_RESOLUTION[1]) / 2
      set_window_long.call(@window, -16, 0x14CA0000)
      set_window_pos.call(@window, 0, x, y, SCREEN_RESOLUTION[0] + 6, SCREEN_RESOLUTION[1] + 26, 0)
      @window = Win32API.new('user32', 'FindWindow', 'PP', 'I').call('RGSS Player', title)
    end
    def self.size
      [@metrics.call(0), @metrics.call(1)]
    end
  end
end

class NilClass
  unless method_defined?(:dispose)
    def dispose; end
    def disposed?; end
  end
end
class Bitmap
  attr_accessor:filename
  alias set_filename_of_bitmap initialize
  def initialize(*args)
    @filename = args.size == 1 ? File.basename(args[0], '.*') : ''
    set_filename_of_bitmap(*args)
  end
end
module RPG::Cache
  AUTO_INDEX = [
    [27,28,33,34], [5,28,33,34], [27,6,33,34], [5,6,33,34],
    [27,28,33,12], [5,28,33,12], [27,6,33,12], [5,6,33,12],
    [27,28,11,34], [5,28,11,34], [27,6,11,34], [5,6,11,34],
    [27,28,11,12], [5,28,11,12], [27,6,11,12], [5,6,11,12],
    [25,26,31,32], [25,6,31,32], [25,26,31,12], [25,6,31,12],
    [15,16,21,22], [15,16,21,12], [15,16,11,22], [15,16,11,12],
    [29,30,35,36], [29,30,11,36], [5,30,35,36], [5,30,11,36],
    [39,40,45,46], [5,40,45,46], [39,6,45,46], [5,6,45,46],
    [25,30,31,36], [15,16,45,46], [13,14,19,20], [13,14,19,12],
    [17,18,23,24], [17,18,11,24], [41,42,47,48], [5,42,47,48],
    [37,38,43,44], [37,6,43,44], [13,18,19,24], [13,14,43,44],
    [37,42,43,48], [17,18,47,48], [13,18,43,48], [1,2,7,8]
  ]
  
  def self.autotile(filename)
    key = "Graphics/Autotiles/#{filename}"
    if !@cache.include?(key) || @cache[key].disposed? 
      orig_bm = self.load_bitmap('Graphics/Autotiles/', filename)
      new_bm = self.format_autotiles(orig_bm, filename)
      if new_bm != orig_bm
        @cache[key].dispose
        @cache[key] = new_bm
      end
    end
    @cache[key]
  end

  def self.format_autotiles(bitmap, filename)
    if bitmap.height > 32 && bitmap.height < 192
      frames = bitmap.width / 96
      template = Bitmap.new(256 * frames, 192)
      template.filename = filename
      (0..frames-1).each{|frame|
      (0...6).each {|i| (0...8).each {|j| AUTO_INDEX[8*i+j].each {|number|
        number -= 1
        x, y = 16 * (number % 6), 16 * (number / 6)
        rect = Rect.new(x + (frame * 96), y, 16, 16)
        template.blt((32 * j + x % 32) + (frame * 256), 32 * i + y % 32, bitmap, rect)
      }}}}
      return template
    else
      return bitmap
    end
  end
end

module CallBackController
  @@callback = {}
  
  def self.clear
    @@callback.clear
  end
  
  def self.setup_callback(obj, proc)
    @@callback[obj.object_id] = proc
  end

  def self.get_callback(obj)
    @@callback[obj.object_id]
  end
  
  def self.call(obj, *args)
    @@callback[obj.object_id].call(*args) if @@callback[obj.object_id]
    true
  end
  
  def self.delete(obj)
    @@callback.delete(obj.object_id)
  end
end

class Viewport
  attr_accessor :offset_x, :offset_y, :attached_planes
  
  alias zer0_viewport_resize_init initialize
  def initialize(x=0, y=0, width=SCREEN_RESOLUTION[0], height=SCREEN_RESOLUTION[1], override=false)
    @offset_x = @offset_y = 0
    
    if x.is_a?(Rect)
      zer0_viewport_resize_init(x)
    elsif [x, y, width, height] == [0, 0, 640, 480] && !override 
      zer0_viewport_resize_init(Rect.new(0, 0, SCREEN_RESOLUTION[0], SCREEN_RESOLUTION[1]))
    else
      zer0_viewport_resize_init(Rect.new(x, y, width, height))
    end
  end
  
  def resize(*args)
    if args[0].is_a?(Rect)
      args[0].x += @offset_x
      args[0].y += @offset_y
      self.rect.set(args[0].x, args[0].y, args[0].width, args[0].height)
    else
      args[0] += @offset_x
      args[1] += @offset_y
      self.rect.set(*args)
    end
  end
end

class Tilemap
  attr_accessor :tileset, :autotiles, :map_data, :priorities, :ground_sprite
  attr_reader :wrapping

  def initialize(viewport = nil)
    CallBackController.clear
    
    @viewport = viewport
    @layer_sprites = []
    @autotile_frame = []
    @autotile_framedata = []
    
    bitmap_width = ((SCREEN_RESOLUTION[0] / 32.0).ceil + 1) * 32
    ((SCREEN_RESOLUTION[1]/32.0).ceil + MAX_PRIORITY_LAYERS).times{|i|
      s = Sprite.new(@viewport)
      s.bitmap = Bitmap.new(bitmap_width, MAX_PRIORITY_LAYERS * 32)
      @layer_sprites.push(s)
    }
    
    bitmap_height = ((SCREEN_RESOLUTION[1] / 32.0).ceil + 1) * 32
    s = Sprite.new(@viewport)
    s.bitmap = Bitmap.new(bitmap_width, bitmap_height)
    @ground_sprite = s
    @ground_sprite.z = 0

    @redraw_tilemap = true
    @tileset = nil
    @autotiles = []
    proc = Proc.new { |x,y| @redraw_tilemap = true; setup_autotile(x) }
    CallBackController.setup_callback(@autotiles, proc)
    
    @map_data = nil
    @priorities = nil
    @old_ox = 0
    @old_oy = 0
    @ox = 0
    @oy = 0
    @ox_float = 0.0
    @oy_float = 0.0
    @shift = 0
    @wrapping = (!DISABLE_WRAP || (XPAT_MAP_INFOS[$game_map.map_id].name =~ /.*\[[Ww][Rr][Aa][Pp]\].*/) == 0) ? 1 : 0
    create_border_sprites
    
    @@update = Win32API.new('XPA_Tilemap', 'DrawMapsBitmap2', 'pppp', 'i')
    @@autotile_update = Win32API.new('XPA_Tilemap', 'UpdateAutotiles', 'pppp', 'i')
    @@initial_draw = Win32API.new('XPA_Tilemap', 'DrawMapsBitmap', 'pppp', 'i')
    @empty_tile = Bitmap.new(32,32)
    Win32API.new('XPA_Tilemap','InitEmptyTile','l','i').call(@empty_tile.object_id)
    @black_tile = Bitmap.new(32,32)
    @black_tile.fill_rect(0,0,32,32,Color.new(0,0,0))
    Win32API.new('XPA_Tilemap','InitBlackTile','l','i').call(@black_tile.object_id)
  end

  def setup_autotile(i)
    bitmap = @autotiles[i]
    frames = bitmap.nil? ? nil : autotile_framerate(bitmap.filename)
    if frames.nil?
      @autotile_frame[i] = [0,0]
      @autotile_framedata[i] = nil
    else
      @autotile_framedata[i] = frames
      total = 0
      frame_checkpoints = []
      frames.each_index{|j| f = frames[j]
        total += f
        frame_checkpoints[j] = total
      }

      current_frame = Graphics.frame_count % total
      frame_checkpoints.each_index{|j| c = frame_checkpoints[j]
        next if c.nil?
        if c > current_frame
          @autotile_frame[i] = [j, c - current_frame]
          break
        end
      }
    end
  end

  def create_border_sprites
    @border_sprites = []
    return if @wrapping == 1
    for i in 0..3
      s = Sprite.new(@viewport)
      s.z = 99999
      if i % 2 == 0
        b = Bitmap.new(SCREEN_RESOLUTION[0] + 64,32)
        s.x = -32
        s.y = i == 0 ? -32 : $game_map.height * 32
      else
        b = Bitmap.new(32,SCREEN_RESOLUTION[1] + 64)
        s.x = i == 1 ? -32 : $game_map.width * 32
        s.y = -32
      end
      b.fill_rect(0, 0, b.width, b.height, Color.new(0,0,0))
      s.bitmap = b
      @border_sprites.push(s)
    end
  end

  def dispose
    @layer_sprites.each{|sprite| sprite.dispose}
    @ground_sprite.dispose
    @border_sprites.each{|sprite| sprite.dispose}
    CallBackController.clear
  end

  def disposed?
    @layer_sprites[0].disposed?
  end

  def viewport
    @viewport
  end

  def visible
    layer_sprites[0].visible
  end

  def visible=(bool)
    @layer_sprites.each{|sprite| sprite.visible = bool}
    @ground_sprite.visible = bool
  end

  def tileset=(bitmap)
    @tileset = bitmap
    if @tileset.width % 32 != 0 || @tileset.height % 32 != 0
      file = bitmap.filename
      raise "Your tileset graphic #{file} needs to be divisible by 32!"
    end
    @redraw_tilemap = true
  end

  def autotiles=(array)
    CallBackController.delete(@autotiles)
    @autotiles = array
    proc = Proc.new { |i| @redraw_tilemap = true; setup_autotile(i) }
    CallBackController.setup_callback(@autotiles, proc)
    @redraw_tilemap = true
  end

  def map_data=(table)
    CallBackController.delete(@map_data)
    @map_data = table
    proc = Proc.new { @redraw_tilemap = true }
    CallBackController.setup_callback(@map_data, proc)
    @redraw_tilemap = true
  end

  def priorities=(table)
    CallBackController.delete(@priorities)
    @priorities = table
    proc = Proc.new { @redraw_tilemap = true }
    CallBackController.setup_callback(@priorities, proc)
    @redraw_tilemap = true
  end

  def ox
    @ox + @ox_float
  end

  def oy
    @oy + @oy_float
  end

  def ox=(ox)
    @ox_float = (ox - ox.to_i) % 1
    @ox = ox.floor
    @border_sprites.each{|s| 
      next if s.bitmap.height == 32
      s.ox = @ox
    }
  end

  def oy=(oy)
    @oy_float = (oy - oy.to_i) % 1
    @oy = oy.floor
    @border_sprites.each{|s| 
      next if s.bitmap.width == 32
      s.oy = @oy
    }
  end

  def update; end;

  def draw
    x = @old_ox - @ox
    @old_ox = @ox
    x += @ground_sprite.x

    y = @old_oy - @oy
    @old_oy = @oy
    y += @ground_sprite.y

    if !@redraw_tilemap
      if x < @viewport.ox - 31
        if x + 32 < @viewport.ox - 31
          @redraw_tilemap = true
        else
          x += 32
          @ground_sprite.bitmap.fill_rect(0, 0, 32, @ground_sprite.bitmap.height, Color.new(0,0,0,0))
          @layer_sprites.each{|sprite| 
            sprite.bitmap.fill_rect(0, 0, 32, sprite.bitmap.height, Color.new(0,0,0,0))
          }
          @shift += 1
        end
      elsif x > @viewport.ox
        if x - 32 > @viewport.ox
          @redraw_tilemap = true
        else
          x -= 32
          @ground_sprite.bitmap.fill_rect(@ground_sprite.bitmap.width - 32, 0, 32, @ground_sprite.bitmap.height, Color.new(0,0,0,0))
          @layer_sprites.each{|sprite| 
            sprite.bitmap.fill_rect(sprite.bitmap.width - 32, 0, 32, sprite.bitmap.height, Color.new(0,0,0,0))
          }
          @shift += 2
        end
      end

      if !@redraw_tilemap
        @ground_sprite.x = x
        @layer_sprites.each{|sprite| sprite.x = x}

        if y < @viewport.oy - 31
          if y + 32 < @viewport.oy - 31
            @redraw_tilemap = true
          else 
            y += 32
            layer = @layer_sprites.shift
            layer.bitmap.clear
            @layer_sprites.push(layer)
            width = @layer_sprites[0].bitmap.width
            num = @layer_sprites.size
            (1..MAX_PRIORITY_LAYERS).each{ |index|
              @layer_sprites[num-index].bitmap.fill_rect(0, (index - 1) * 32, width, 32, Color.new(0,0,0,0))
            }
            @shift += 4
          end
        elsif y > @viewport.oy
          if y - 32 > @viewport.oy
            @redraw_tilemap = true
          else
            y -= 32
            layer = @layer_sprites.pop
            layer.bitmap.clear
            @layer_sprites.unshift(layer)
            width = @layer_sprites[0].bitmap.width
            (1...MAX_PRIORITY_LAYERS).each{ |index|
              @layer_sprites[index].bitmap.fill_rect(0, (MAX_PRIORITY_LAYERS - 1 - index) * 32, width, 32, Color.new(0,0,0,0))
            }
            @shift += 8
          end
        end
        if !@redraw_tilemap
          @ground_sprite.y = y
          @layer_sprites.each_index{ |i| sprite = @layer_sprites[i]
            sprite.y = y - 32 * (MAX_PRIORITY_LAYERS - 1 - i)
            sprite.z = sprite.y + (192 - (5 - MAX_PRIORITY_LAYERS) * 32)
          }
        end
      end
    end

    autotile_need_update = []
    for i in 0..6
      autotile_need_update[i] = false
      next if @autotile_framedata[i].nil?
      @autotile_frame[i][1] -= 1
      if @autotile_frame[i][1] == 0
        @autotile_frame[i][0] = (@autotile_frame[i][0] + 1) % @autotile_framedata[i].size
        @autotile_frame[i][1] = @autotile_framedata[i][@autotile_frame[i][0]]
        autotile_need_update[i] = true
      end
    end
    
    return unless @redraw_tilemap || @shift != 0 || !autotile_need_update.index(true).nil?

    layers = [@layer_sprites.size + 1]
    @layer_sprites.each{|sprite| layers.push(sprite.bitmap.object_id) }
    layers.push(@ground_sprite.bitmap.object_id)
    tile_bms = [self.tileset.object_id]

    self.autotiles.each{|autotile| tile_bms.push(autotile.object_id) }
    autotiledata = []
    for i in 0..6
      autotiledata.push(@autotile_frame[i][0])
      autotiledata.push(autotile_need_update[i] ? 1 : 0)
    end

    misc_data = [@ox + @viewport.ox, @oy + @viewport.oy,
      self.map_data.object_id, self.priorities.object_id, @shift, 
      MAX_PRIORITY_LAYERS, @wrapping]
    
    if @redraw_tilemap
      @ground_sprite.bitmap.clear
      @ground_sprite.x = (@viewport.ox - @viewport.ox % 32) - (@ox % 32)
      @ground_sprite.x += 32 if @ground_sprite.x < @viewport.ox - 31
      @ground_sprite.y = (@viewport.oy - @viewport.oy % 32) - (@oy % 32)
      @ground_sprite.y += 32 if @ground_sprite.y < @viewport.oy - 31

      y_buffer = 32 * (MAX_PRIORITY_LAYERS - 1)
      z_buffer = MAX_PRIORITY_LAYERS * 32 + 32
      @layer_sprites.each_index{|i| layer = @layer_sprites[i]
        layer.bitmap.clear
        layer.x = @ground_sprite.x
        layer.y = @ground_sprite.y - y_buffer + 32 * i
        layer.z = layer.y + z_buffer
      }
      @@initial_draw.call(layers.pack("L*"), tile_bms.pack("L*"), autotiledata.pack("L*"), misc_data.pack("L*"))
    elsif @shift != 0
      @@update.call(layers.pack("L*"), tile_bms.pack("L*"), autotiledata.pack("L*"), misc_data.pack("L*"))
    end
    if !@redraw_tilemap && !autotile_need_update.index(true).nil?
      @@autotile_update.call(layers.pack("L*"), tile_bms.pack("L*"), autotiledata.pack("L*"), misc_data.pack("L*"))
    end
    @redraw_tilemap = false
    @shift = 0
  end
end

class Game_Player
  CENTER_X = ((SCREEN_RESOLUTION[0] / 2) - 16) * 4
  CENTER_Y = ((SCREEN_RESOLUTION[1] / 2) - 16) * 4
  
  def center(x, y)
    max_x = (($game_map.width - (SCREEN_RESOLUTION[0]/32.0)) * 128).to_i
    max_y = (($game_map.height - (SCREEN_RESOLUTION[1]/32.0)) * 128).to_i
    $game_map.display_x = [0, [x * 128 - CENTER_X, max_x].min].max
    $game_map.display_y = [0, [y * 128 - CENTER_Y, max_y].min].max
  end
end

class Game_Map
  alias zer0_map_edge_setup setup
  def setup(map_id)
    zer0_map_edge_setup(map_id)
    @map_edge = [self.width - (SCREEN_RESOLUTION[0]/32.0), self.height - (SCREEN_RESOLUTION[1]/32.0)]
    @map_edge.collect! {|size| size < 0 ? 0 : (size * 128).round }
    if $game_map.width < SCREEN_RESOLUTION[0] / 32
      Game_Player.const_set(:CENTER_X, $game_map.width * 128)
    else
      Game_Player.const_set(:CENTER_X, ((SCREEN_RESOLUTION[0] / 2) - 16) * 4)
    end
    if $game_map.height < SCREEN_RESOLUTION[1] / 32
      Game_Player.const_set(:CENTER_Y, $game_map.height * 128)
    else
      Game_Player.const_set(:CENTER_Y, ((SCREEN_RESOLUTION[1] / 2) - 16) * 4)
    end
  end

  alias scroll_down_xpat scroll_down
  def scroll_down(distance)
    pre_alias = @display_y + distance
    scroll_down_xpat(distance)
    @display_y = pre_alias if @display_y == (self.height - 15) * 128
    @display_y = [@display_y, @map_edge[1]].min
  end

  alias scroll_right_xpat scroll_right
  def scroll_right(distance)
    pre_alias = @display_x + distance
    scroll_right_xpat(distance)
    @display_x = pre_alias if @display_x == (self.width - 20) * 128
    @display_x = [@display_x, @map_edge[0]].min
  end
end

class Array
  alias flag_changes_to_set []=
  def []=(x, y)
    flag_changes_to_set(x, y)
    CallBackController.call(self, x, y)
  end
end

class Table
  alias flag_changes_to_set []=
  def []=(*args)
    flag_changes_to_set(*args)
    CallBackController.call(self, *args)
  end
end

if WEATHER_ADJUSTMENT
  class RPG::Weather
    alias add_more_weather_sprites initialize
    def initialize(vp = nil)
      add_more_weather_sprites(vp)
      total_sprites = SCREEN_RESOLUTION[0] * SCREEN_RESOLUTION[1] / 7680
      if total_sprites > 40
        for i in 1..(total_sprites - 40)
          sprite = Sprite.new(vp)
          sprite.z = 1000
          sprite.visible = false
          sprite.opacity = 0
          @sprites.push(sprite)
        end
      end
    end
    
    def type=(type)
      return if @type == type
      @type = type
      case @type
      when 1
        bitmap = @rain_bitmap
      when 2
        bitmap = @storm_bitmap
      when 3
        bitmap = @snow_bitmap
      else
        bitmap = nil
      end
      for i in 1..@sprites.size
        sprite = @sprites[i]
        if sprite != nil
          sprite.visible = (i <= @max)
          sprite.bitmap = bitmap
        end
      end
    end
    
    def max=(max)
      return if @max == max;
      @max = [[max, 0].max, @sprites.size].min
      for i in 1..@sprites.size
        sprite = @sprites[i]
        if sprite != nil
          sprite.visible = (i <= @max)
        end
      end
    end
    
    def update
      return if @type == 0
      for i in 1..@max
        sprite = @sprites[i]
        if sprite == nil
          break
        end
        if @type == 1
          sprite.x -= 2
          sprite.y += 16
          sprite.opacity -= 8
        end
        if @type == 2
          sprite.x -= 8
          sprite.y += 16
          sprite.opacity -= 12
        end
        if @type == 3
          sprite.x -= 2
          sprite.y += 8
          sprite.opacity -= 8
        end
        x = sprite.x - @ox
        y = sprite.y - @oy
        if sprite.opacity < 64
          sprite.x = rand(SCREEN_RESOLUTION[0] + 100) - 100 + @ox
          sprite.y = rand(SCREEN_RESOLUTION[0] + 200) - 200 + @oy
          sprite.opacity = 160 + rand(96)
        end
      end
    end
  end

  class Game_Screen
    def weather(type, power, duration)
      @weather_type_target = type
      if @weather_type_target != 0
        @weather_type = @weather_type_target
      end
      if @weather_type_target == 0
        @weather_max_target = 0.0
      else
        num = SCREEN_RESOLUTION[0] * SCREEN_RESOLUTION[1] / 76800.0
        @weather_max_target = (power + 1) * num
      end
      @weather_duration = duration
      if @weather_duration == 0
        @weather_type = @weather_type_target
        @weather_max = @weather_max_target
      end
    end
  end
end

class Spriteset_Map
  alias init_for_centered_small_maps initialize
  def initialize
    @center_offsets = [0,0]
    if $game_map.width < (SCREEN_RESOLUTION[0] / 32.0).ceil
      x = (SCREEN_RESOLUTION[0] - $game_map.width * 32) / 2
    else
      x = 0
    end
    if $game_map.height < (SCREEN_RESOLUTION[1] / 32.0).ceil
      y = (SCREEN_RESOLUTION[1] - $game_map.height * 32) / 2
    else
      y = 0
    end
    init_for_centered_small_maps
    w = [$game_map.width  * 32 , SCREEN_RESOLUTION[0]].min
    h = [$game_map.height * 32 , SCREEN_RESOLUTION[1]].min
    @viewport1.resize(x,y,w,h)
  end
  alias update_tilemap_for_real update
  def update
    update_tilemap_for_real
    @tilemap.draw
  end
end

unless XPACE && SCREEN_RESOLUTION != [640, 480]
  class Bitmap
    def address
      @rtlmemory_pi ||= Win32API.new('kernel32','RtlMoveMemory','pii','i')
      @address ||= (@rtlmemory_pi.call(a="\0"*4, __id__*2+16, 4)
        @rtlmemory_pi.call(a, a.unpack('L')[0]+8, 4)
        @rtlmemory_pi.call(a, a.unpack('L')[0]+16, 4)
        a.unpack('L')[0])
    end
  end
  module Graphics
    class << self
      define_method(:width){SCREEN_RESOLUTION[0]}
      define_method(:height){SCREEN_RESOLUTION[1]}
      def snap_to_bitmap
        @window ||= Win32API.new('user32','GetActiveWindow', '', 'L')
        @getdc ||= Win32API.new('user32','GetDC','i','i')
        @ccdc ||= Win32API.new('gdi32','CreateCompatibleDC','i','i')
        @selectobject ||= Win32API.new('gdi32','SelectObject','ii','i')
        @deleteobject ||= Win32API.new('gdi32','DeleteObject','i','i')
        @setdibits ||= Win32API.new('gdi32','SetDIBits','iiiiipi','i')
        @getdibits ||= Win32API.new('gdi32','GetDIBits','iiiiipi','i')
        @bitblt ||= Win32API.new('gdi32','BitBlt','iiiiiiiii','i')
        @ccbitmap ||= Win32API.new('gdi32','CreateCompatibleBitmap','iii','i')
        
        bitmap = Bitmap.new(w = Graphics.width,h = Graphics.height)
        @deleteobject.call(@selectobject.call((hDC = @ccdc.call((dc = @getdc.call(@window.call)))),(hBM = @ccbitmap.call(dc,w,h))))
        @setdibits.call(hDC, hBM, 0, h, (a = bitmap.address), (info = [40,w,h,1,32,0,0,0,0,0,0].pack('LllSSLLllLL')), 0)
        @bitblt.call(hDC, 0, 0, w, h, dc, 0, 0, 0xCC0020)
        @getdibits.call(hDC, hBM, 0, h, a, info, 0)
        @deleteobject.call(hBM)
        @deleteobject.call(hDC)
        return bitmap
      end  
      def wait(frame = 1)
        frame.times {|s| update }
      end
    end
  end
end

if SCREEN_RESOLUTION != [640, 480]
  module Graphics
    @@transition = Win32API.new('XPA_Tilemap', 'Transition', 'lliii', 'i')
    @@transition_rect = Rect.new(0,0, SCREEN_RESOLUTION[0], SCREEN_RESOLUTION[1])
    @@transition_bitmap = nil
    @@frozen_sprite = nil
    
    class << self
      def freeze
        @@transition_bitmap = Bitmap.new(SCREEN_RESOLUTION[0], SCREEN_RESOLUTION[1]) if @@transition_bitmap.nil? || @@transition_bitmap.disposed?
        @@frozen_sprite = Sprite.new if @@frozen_sprite.nil? || @@frozen_sprite.disposed?
        @@frozen_sprite.bitmap = snap_to_bitmap
        @@frozen_sprite.z = 999999
      end

      def transition(duration=12, filename='', vague=40)
        if filename && !filename.empty?
          transition_bitmap = Bitmap.new(filename) rescue nil
          if transition_bitmap.nil?
            p "Transition graphic #{filename} not found"
            filename = nil
          end
        end
        @@frozen_sprite.opacity = 255
        if filename.nil? || filename.empty?
          interval = 255.0 / duration
          duration.times do |i|
            @@frozen_sprite.opacity = 255.0 - interval * i
            Graphics.update
          end
        else
          src_rect = Rect.new(0,0,transition_bitmap.width, transition_bitmap.height)
          @@transition_bitmap.stretch_blt(@@transition_rect, transition_bitmap, src_rect)
          transition_bitmap.dispose
          duration.times do |i|
            @@transition.call(@@frozen_sprite.bitmap.object_id, @@transition_bitmap.object_id, 
              i, duration, vague)
            Graphics.update
          end
        end
        @@frozen_sprite.bitmap.dispose
      end
    end
  end
end

if DISABLE_WRAP || SCREEN_RESOLUTION[0] > 640 || SCREEN_RESOLUTION[1] > 480
  module Graphics
    @@super_sprite = Sprite.new
    @@super_sprite.z = (2 ** (0.size * 8 - 2) - 1)
    
    class << self
      def reform_sprite_bitmap
        @@super_sprite.bitmap = Bitmap.new(Graphics.width, Graphics.height)
        @@super_sprite.bitmap.fill_rect(@@super_sprite.bitmap.rect, Color.new(0, 0, 0, 255))
      end
      
      def fadeout(frames)
        incs = 255.0 / frames
        frames.times do |i|
          i += 1
          Graphics.brightness = 255 - incs * i
          Graphics.wait(1)
        end
      end
      
      def fadein(frames)
        incs = 255.0 / frames
        frames.times do |i|
          Graphics.brightness = incs * i
          Graphics.wait(1)
        end
      end
  
      def brightness=(i)
        @@super_sprite.opacity = 255.0 - i
      end
      
      def brightness
        255 - @@super_sprite.opacity
      end
      
      if XPACE
        alias :th_large_screen_resize_screen :resize_screen
        def resize_screen(width, height)
          wt, ht = width.divmod(32), height.divmod(32)
          wh = lambda {|w,h,off| [w + off, h + off].pack('l2').scan(/.{4}/) }
          w, h = wh.call(width, height,0)
          ww, hh = wh.call(width, height, 32)
          www, hhh = wh.call(wt.first.succ, ht.first.succ,0)
          base = DL::CPtr.new(0x00410016)[0, 4].unpack('l*').first << 16

          mod = lambda {|adr,val| (DL::CPtr.new(base + adr))[0, val.size] = val}
          mod.call(0x20F6, w) && mod.call(0x20FF, w)
          mod.call(0x2106, h) && mod.call(0x210F, h)
          zero = [0].pack(?l)

          th_large_screen_resize_screen(width, height)
        end
      end
    end
  end

  class Viewport
    attr_accessor :parent, :children
    
    alias init_children_vps initialize
    def initialize(*args)
      @children = []
      @attached_planes = []
      @parent = false

      init_children_vps(*args)
    end

    def parent=(bool)
      if bool
        proc = Proc.new { self.resize_planes }
        CallBackController.setup_callback(rect, proc)
      end
      @parent = bool
    end

    def resize_planes
      @attached_planes.each { |plane| plane.resize_children }
    end

    alias call_back_for_set_rect rect=
    def rect=(rect)
      call_back_for_set_rect(rect)
      CallBackController.call(rect) if @parent
      rect
    end
    
    alias dispose_parent dispose
    def dispose
      if @parent
        @children.each{|child| child.dispose}
        CallBackController.delete(self.rect)
      end
      dispose_parent
    end
    
    alias flash_parent flash
    def flash(color, duration)
      if @parent
        @children.each{|child| child.flash_parent(color, duration)}
      else
        flash_parent(color, duration)
      end
    end
    
    alias update_parent update
    def update
      @children.each{|child| child.update} if @parent
      update_parent
    end

    alias set_trigger_vp_ox ox=
    def ox=(nx)
      return if self.ox == nx
      set_trigger_vp_ox(nx)
      @children.each{|child| child.ox = nx}
    end
    
    alias set_trigger_vp_oy oy=
    def oy=(ny)
      return if self.oy == ny
      set_trigger_vp_oy(ny)
      @children.each{|child| child.oy = ny}
    end
    
    alias tone_parent tone=
    def tone=(t)
      if @parent
        @children.each{|child| child.tone_parent(t)}
      else
        tone_parent(t)
      end
    end

  end

  class Plane
    attr_accessor :offset_x, :offset_y
    
    alias parent_initialize initialize
    def initialize(viewport = nil, parent = true)
      @parent = parent && viewport
      @children = []
      parent_initialize(viewport)
      @offset_x = 0
      @offset_y = 0
      if @parent
        viewport.parent = true
        viewport.attached_planes << self
        create_children
        resize_children
      end
    end
    
    def create_children
      gw, gh = SCREEN_RESOLUTION

      w = (gw - 1) / 640
      h = (gh - 1) / 480
      
      vp_x = self.viewport.rect.x
      vp_y = self.viewport.rect.y

      for y in 0..h
        for x in 0..w
          width = w > 0 && x == w ? gw - 640 : 640
          height = h > 0 && y == h ? gh - 480 : 480
          vp = Viewport.new(x * 640 + vp_x, y * 480 + vp_y, width, height, true)
          vp.offset_x = x * 640
          vp.offset_y = y * 480
          vp.z = self.viewport.z - 1
          self.viewport.children << vp
          plane = Plane.new(vp,false)
          plane.offset_x = x * 640
          plane.ox = self.ox
          plane.offset_y = y * 480
          plane.oy = self.oy
          @children << plane
        end
      end
    end

    def resize_children
      rect = self.viewport.rect
      @children.each do |child|
        width = child.offset_x + 640 <= rect.width ? 640 : [rect.width - child.offset_x, 0].max
        height = child.offset_y + 480 <= rect.height ? 480 : [rect.height - child.offset_y, 0].max

        child.viewport.rect.set(child.offset_x + rect.x, child.offset_y + rect.y, width, height)
      end
    end

    alias dispose_parent dispose
    def dispose
      if @parent
        @children.each{|child| child.dispose}
        self.viewport.attached_planes.delete(self)
      end
      dispose_parent
    end
    
    alias zoom_x_parent zoom_x=
    def zoom_x=(new_val)
      new_val = 0 if new_val < 0
      @children.each{|child| child.zoom_x_parent(new_val)} if @parent
      zoom_x_parent(new_val)
    end
    
    alias zoom_y_parent zoom_y=
    def zoom_y=(new_val)
      new_val = 0 if new_val < 0
      @children.each{|child| child.zoom_y_parent(new_val)} if @parent
      zoom_y_parent(new_val)
    end
    
    alias ox_parent ox=
    def ox=(new_val)
      @children.each{|child| child.ox = new_val} if @parent
      ox_parent(new_val + @offset_x)
    end
    
    alias oy_parent oy=
    def oy=(new_val)
      @children.each{|child| child.oy = new_val} if @parent
      oy_parent(new_val + @offset_y)
    end
    
    alias bitmap_parent bitmap=
    def bitmap=(new_val)
      if @parent
        @children.each{|child| child.bitmap_parent(new_val)}
      else
        bitmap_parent(new_val)
      end
      
    end
    
    alias visible_parent visible=
    def visible=(new_val)
      @children.each{|child| child.visible_parent(new_val)} if @parent
      visible_parent(new_val)
    end
    
    alias z_parent z=
    def z=(new_val)
      if @parent && @children[0]
        child = @children[0]
        if new_val > 0 && child.viewport.z < self.viewport.z
          @children.each{|child| child.viewport.z += 1}
        elsif new_val <= 0 && child.viewport.z >= self.viewport.z
          @children.each{|child| child.viewport.z -= 1}
        end
      end
      
      @children.each{|child| child.z_parent(new_val)} if @parent
      z_parent(new_val)
    end
    
    alias opacity_parent opacity=
    def opacity=(new_val)
      @children.each{|child| child.opacity_parent(new_val)} if @parent
      opacity_parent(new_val)
    end
    
    alias color_parent color=
    def color=(new_val)
      if @parent
        @children.each{|child| child.color_parent(new_val)}
      else
        color_parent(new_val)
      end
    end
    
    alias blend_type_parent blend_type=
    def blend_type=(new_val)
      @children.each{|child| child.blend_type_parent(new_val)} if @parent
      blend_type_parent(new_val)
    end 
    
    alias tone_parent tone=
    def tone=(new_val)
      if @parent
        @children.each{|child| child.tone_parent(new_val)}
      else
        tone_parent(new_val)
      end
    end
  end
end

Resolution.resize_game unless XPACE
XPAT_MAP_INFOS = load_data("Data/MapInfos.rxdata")