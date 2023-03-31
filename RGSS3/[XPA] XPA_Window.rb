if XPA_CONFIG::XPA_WINDOW

module XPA_Window
  module Config
    BACKGROUND_CACHE_SIZE = 200
    CURSOR_CACHE_SIZE = 200
    MARGIN = 16
    BORDER_THICKNESS = 16
    BACKGROUND_MARGIN = 2
    CURSOR_BORDER = 2
    ARROW_OFFSET = 4
    PAUSE_FRAME_STEP = 8
    CURSOR_BLINK_FRAMES = 32
    BACKGROUND_RECT = Rect.new(0, 0, 128, 128)
    CURSOR_RECT = Rect.new(128, 64, 32, 32)
    BORDER_RECTS = [
        Rect.new(144, 0, 32, 16),
        Rect.new(144, 48, 32, 16),
        Rect.new(128, 16, 16, 32),
        Rect.new(176, 16, 16, 32)
    ]
    CORNER_RECTS = [
        Rect.new(128, 0, 16, 16),
        Rect.new(176, 0, 16, 16),
        Rect.new(128, 48, 16, 16),
        Rect.new(176, 48, 16, 16)
    ]
    ARROW_RECTS = [
        Rect.new(152, 16, 16, 8),
        Rect.new(152, 40, 16, 8),
        Rect.new(144, 24, 8, 16),
        Rect.new(168, 24, 8, 16)
    ]
    PAUSE_RECTS = [
        Rect.new(160, 64, 16, 16),
        Rect.new(176, 64, 16, 16),
        Rect.new(160, 80, 16, 16),
        Rect.new(176, 80, 16, 16)
    ]
    LinearWrite = Win32API.new('System/XPA_Window', 'LinearWrite', 'liiiiliiii', 'i')
    MAX_BORDERS = 4
    MAX_CORNERS = 4
    MAX_ARROWS = 4
    
    $xpa_window = 1.4
  
  end
  
end


class Bitmap
  
  def linear_write(dest, src_bitmap, src)
    XPA_Window::Config::LinearWrite.call(self.object_id, dest.x, dest.y,
        dest.width, dest.height, src_bitmap.object_id, src.x, src.y, src.width,
        src.height)
  end
  
end
  


module XPA_Window
  
  
  module Skin
    
    @@skins = {}
    
    def self.get_border_horizontal(bitmap, index, width)
      return nil if bitmap == nil || width <= 0
      @@skins[bitmap] = SkinContainer.new(bitmap) if !@@skins.has_key?(bitmap)
      return @@skins[bitmap].get_border_horizontal(index, width)
    end
    
    def self.get_border_vertical(bitmap, index, height)
      return nil if bitmap == nil || height <= 0
      @@skins[bitmap] = SkinContainer.new(bitmap) if !@@skins.has_key?(bitmap)
      return @@skins[bitmap].get_border_vertical(index, height)
    end
    
    def self.get_cursor(bitmap, width, height)
      return nil if bitmap == nil || width <= 0 || height <= 0
      @@skins[bitmap] = SkinContainer.new(bitmap) if !@@skins.has_key?(bitmap)
      return @@skins[bitmap].get_cursor(width, height)
    end
    
    def self.get_background(bitmap, width, height)
      return nil if bitmap == nil || width <= 0 || height <= 0
      @@skins[bitmap] = SkinContainer.new(bitmap) if !@@skins.has_key?(bitmap)
      return @@skins[bitmap].get_background(width, height)
    end
    
    def self.get_tiled_background(bitmap, width, height)
      return nil if bitmap == nil || width <= 0 || height <= 0
      @@skins[bitmap] = SkinContainer.new(bitmap) if !@@skins.has_key?(bitmap)
      return @@skins[bitmap].get_tiled_background(width, height)
    end
    
  
    class SkinContainer
      
      attr_reader :cursor_colors
      
      def initialize(bitmap)
        @bitmap = bitmap
        @borders = [nil, nil, nil, nil]
        @background_tiled = nil
        @cursors = {}
        @background_base = Bitmap.new(XPA_Window::Config::BACKGROUND_RECT.width,
            XPA_Window::Config::BACKGROUND_RECT.height)
        @background_base.blt(0, 0, @bitmap, XPA_Window::Config::BACKGROUND_RECT)
        @backgrounds = {}
        @tiled_backgrounds = {}
      end
      
      def _pot_ceil(value)
        value &= 0xFFFFFFFF
        value -= 1
        value |= value >> 1
        value |= value >> 2
        value |= value >> 4
        value |= value >> 8
        value |= value >> 16
        value += 1
        return value
      end
      
      def _extend_width(bitmap, old_bitmap)
        width = old_bitmap.width
        bitmap.blt(0, 0, old_bitmap, Rect.new(0, 0, width, bitmap.height))
        while width < bitmap.width
          bitmap.blt(width, 0, bitmap, Rect.new(0, 0, width, bitmap.height))
          width *= 2
        end
      end
      
      def _extend_height(bitmap, old_bitmap)
        height = old_bitmap.height
        bitmap.blt(0, 0, old_bitmap, Rect.new(0, 0, bitmap.width, height))
        while height < bitmap.height
          bitmap.blt(0, height, bitmap, Rect.new(0, 0, bitmap.width, height))
          height *= 2
        end
      end
      
      def _try_create_border(index)
        if @borders[index] == nil
          rect = XPA_Window::Config::BORDER_RECTS[index]
          @borders[index] = Bitmap.new(rect.width, rect.height)
          @borders[index].blt(0, 0, @bitmap, rect)
        end
      end
      
      def get_border_horizontal(index, width)
        self._try_create_border(index)
        pot_width = self._pot_ceil(width)
        if @borders[index].width < pot_width
          old_bitmap = @borders[index]
          @borders[index] = Bitmap.new(pot_width,
              XPA_Window::Config::BORDER_RECTS[index].height)
          self._extend_width(@borders[index], old_bitmap)
        end
        return @borders[index]
      end
      
      def get_border_vertical(index, height)
        index += 2
        self._try_create_border(index)
        pot_height = self._pot_ceil(height)
        if @borders[index].height < pot_height
          old_bitmap = @borders[index]
          @borders[index] = Bitmap.new(
              XPA_Window::Config::BORDER_RECTS[index].width, pot_height)
          self._extend_height(@borders[index], old_bitmap)
        end
        return @borders[index]
      end
      
      def get_cursor(width, height)
        size = [width, height]
        if !@cursors.has_key?(size)
          if @cursors.size >= XPA_Window::Config::BACKGROUND_CACHE_SIZE
            @cursors.clear
          end
          cursor = Bitmap.new(width, height)
          @cursors[size] = cursor
          c = XPA_Window::Config::CURSOR_BORDER
          c2 = c * 2
          right = width - c
          bottom = height - c
          rect = XPA_Window::Config::CURSOR_RECT
          b_right = rect.width - c
          b_bottom = rect.height - c
          cursor.blt(0, 0, @bitmap, Rect.new(rect.x, rect.y, c, c))
          cursor.blt(right, 0, @bitmap, Rect.new(rect.x + b_right, rect.y, c, c))
          cursor.blt(0, bottom, @bitmap, Rect.new(rect.x, rect.y + b_bottom, c,
              c))
          cursor.blt(right, bottom, @bitmap, Rect.new(rect.x + b_right,
              rect.y + b_bottom, c, c))
          if width > c2
            cursor.stretch_blt(Rect.new(c, 0, width - c2, c),
                @bitmap, Rect.new(rect.x + c, rect.y, rect.width - c2, c))
            cursor.stretch_blt(Rect.new(c, bottom, width - c2, c),
                @bitmap, Rect.new(rect.x + c, rect.y + b_bottom, rect.width - c2,
                c))
          end
          if height > c2
            cursor.stretch_blt(Rect.new(0, c, c, height - c2),
                @bitmap, Rect.new(rect.x, rect.y + c, c, rect.height - c2))
            cursor.stretch_blt(Rect.new(right, c, c, height - c2),
                @bitmap, Rect.new(rect.x + b_right, rect.y + c, c,
                rect.height - c2))
          end
          if width > c2 && height > c2
            cursor.linear_write(Rect.new(c, c, width - c2, height - c2),
                @bitmap, Rect.new(c + rect.x, c + rect.y, rect.width - c2,
                rect.height - c2))
          end
        end
        return @cursors[size]
      end
      
      def get_background(width, height)
        size = [width, height]
        if !@backgrounds.has_key?(size)
          if @backgrounds.size >= XPA_Window::Config::BACKGROUND_CACHE_SIZE
            @backgrounds.clear
          end
          background = Bitmap.new(width, height)
          @backgrounds[size] = background
          background.linear_write(Rect.new(0, 0, width, height),
              @bitmap, XPA_Window::Config::BACKGROUND_RECT)
        end
        return @backgrounds[size]
      end
      
      def get_tiled_background(width, height)
        pot_width = self._pot_ceil(width)
        pot_height = self._pot_ceil(height)
        size = [pot_width, pot_height]
        if !@tiled_backgrounds.has_key?(size)
          if @tiled_backgrounds.size >= XPA_Window::Config::BACKGROUND_CACHE_SIZE
            @tiled_backgrounds.clear
          end
          background = Bitmap.new(pot_width, pot_height)
          @tiled_backgrounds[size] = background
          self._extend_width(background, @background_base)
          self._extend_height(background, @background_base)
        end
        return @tiled_backgrounds[size]
      end
      
    end
    
  end
  
  
  class TrackingRect < Rect
    
    def initialize(window, rect, sprite)
      super(0, 0, 0, 0)
      @_window = window
      @_rect = rect
      @_sprite = sprite
      @_sprite.visible = false
    end
    
    def x=(value)
      self.set(value, self.y, self.width, self.height)
    end
    
    def y=(value)
      self.set(self.x, value, self.width, self.height)
    end
    
    def width=(value)
      self.set(self.x, self.y, value, self.height)
    end
    
    def height=(value)
      self.set(self.x, self.y, self.width, value)
    end
    
    def set(x, y, width, height)
      super
      if @_window.visible && width > 0 && height > 0
        dx = x + XPA_Window::Config::MARGIN
        dy = y + XPA_Window::Config::MARGIN
        if x < -XPA_Window::Config::MARGIN
          ox = -dx
          dx = 0
        else
          ox = 0
        end
        if y < -XPA_Window::Config::MARGIN
          oy = -dy
          dy = 0
        else
          oy = 0
        end
        cursor_width = width
        cursor_height = height
        cursor_width = @_rect.width - dx if cursor_width > @_rect.width - dx
        cursor_height = @_rect.height - dy if cursor_height > @_rect.height - dy
        if cursor_width > 0 && cursor_height > 0
          @_sprite.visible = true
          @_sprite.x = @_rect.x + dx
          @_sprite.y = @_rect.y + dy
          @_sprite.bitmap = Skin.get_cursor(@_sprite.windowskin, width, height)
          @_sprite.src_rect.set(ox, oy, cursor_width, cursor_height)
        else
          @_sprite.visible = false
        end
      else
        @_sprite.visible = false
      end
    end
  
    def empty
      super
      @_sprite.visible = false
    end
    
    def refresh
      self.set(self.x, self.y, self.width, self.height)
    end
    
  end
  
  
  class Sprite_Cursor < ::Sprite
    
    attr_accessor :windowskin
    
    def initialize(*args)
      super
      @windowskin = nil
    end
    
  end
    
  
  class Window
    
    def initialize(viewport = nil)
      @_rect = Rect.new(0, 0, 0, 0)
      @_visible = true
      @_viewport = viewport
      @_z = 0
      @_ox = 0
      @_oy = 0
      @_disposed = false
      @_opacity = 255
      @_back_opacity = 255
      @_contents_opacity = 255
      @_active = true
      @_pause = false
      @_stretch = true
      @_pause_update_count = 0
      @_cursor_update_count = 0
      @_windowskin = nil
      @_sprite_background = Sprite.new(@_viewport)
      @_sprite_borders = []
      (0...XPA_Window::Config::MAX_BORDERS).each {|i|
          @_sprite_borders.push(Sprite.new(@_viewport))
      }
      @_sprite_corners = []
      (0...XPA_Window::Config::MAX_CORNERS).each {|i|
          @_sprite_corners.push(Sprite.new(@_viewport))
      }
      @_sprite_arrows = []
      (0...XPA_Window::Config::MAX_ARROWS).each {|i|
          @_sprite_arrows.push(Sprite.new(@_viewport))
      }
      @_sprite_cursor = Sprite_Cursor.new(@_viewport)
      @_sprite_contents = Sprite.new(@_viewport)
      @_sprite_pause = Sprite.new(@_viewport)
      @_sprite_background.x = XPA_Window::Config::BACKGROUND_MARGIN
      @_sprite_background.y = XPA_Window::Config::BACKGROUND_MARGIN
      @_sprite_background.z = -20
      @_sprite_borders[0].x = XPA_Window::Config::BORDER_THICKNESS
      @_sprite_borders[1].x = XPA_Window::Config::BORDER_THICKNESS
      @_sprite_borders[2].y = XPA_Window::Config::BORDER_THICKNESS
      @_sprite_borders[3].y = XPA_Window::Config::BORDER_THICKNESS
      @_sprite_contents.x = XPA_Window::Config::MARGIN
      @_sprite_contents.y = XPA_Window::Config::MARGIN
      @_sprite_pause.z = 20
      @_sprite_arrows.each {|sprite| sprite.z = 10}
      @_cursor_rect = TrackingRect.new(self, @_rect, @_sprite_cursor)
      @_windowskin = RPG::Cache.windowskin($game_system.windowskin_name)
      self._update_visible
    end
  
    def dispose
      return if self.disposed?
      @_disposed = true
      @_cursor_rect = nil
      @_windowskin = nil
      if @_sprite_background != nil
        @_sprite_background.dispose
        @_sprite_background = nil
      end
      @_sprite_borders.each {|sprite| sprite.dispose}
      @_sprite_borders.clear
      @_sprite_corners.each {|sprite| sprite.dispose}
      @_sprite_corners.clear
      @_sprite_arrows.each {|sprite| sprite.dispose}
      @_sprite_arrows.clear
      if @_sprite_cursor != nil
        @_sprite_cursor.dispose
        @_sprite_cursor = nil
      end
      if @_sprite_contents != nil
        @_sprite_contents.dispose
        @_sprite_contents = nil
      end
      if @_sprite_pause != nil
        @_sprite_pause.dispose
        @_sprite_pause = nil
      end
      if @_viewport != nil
        @_viewport.dispose
        @_viewport = nil
      end
    end
    
    def disposed?
      return @_disposed
    end
    
    def viewport
      self._check_disposed
      return @_viewport
    end
    
    def cursor_rect
      self._check_disposed
      return @_cursor_rect
    end
    
    def cursor_rect=(value)
      self._check_disposed
      @_cursor_rect.set(value.x, value.y, value.width, value.height)
      return @_cursor_rect
    end
    
    def visible
      self._check_disposed
      return @_visible
    end
    
    def visible=(value)
      self._check_disposed
      if @_visible != value
        @_visible = value
        @_sprite_background.visible = value
        @_sprite_borders.each {|sprite| sprite.visible = value}
        @_sprite_corners.each {|sprite| sprite.visible = value}
        @_sprite_arrows.each {|sprite| sprite.visible = value}
        @_sprite_cursor.visible = value
        @_sprite_contents.visible = value
        @_sprite_pause.visible = value
        self._update_visible
      end
      return @visible
    end
    
    def x
      self._check_disposed
      return @_rect.x
    end
    
    def x=(value)
      self._check_disposed
      if @_rect.x != value
        @_rect.x = value
        @_sprite_contents.x = value + XPA_Window::Config::MARGIN
        self._update_x if @_visible
      end
      return @_rect.x
    end
    
    def y
      self._check_disposed
      return @_rect.y
    end
    
    def y=(value)
      self._check_disposed
      if @_rect.y != value
        @_rect.y = value
        @_sprite_contents.y = value + XPA_Window::Config::MARGIN
        self._update_y if @_visible
      end
      return @_rect.y
    end
    
    def width
      self._check_disposed
      return @_rect.width
    end
    
    def width=(value)
      self._check_disposed
      if @_rect.width != value
        @_rect.width = value
        @_sprite_contents.src_rect.width = value -
            XPA_Window::Config::MARGIN * 2
        if @_visible
          self._update_background
          self._update_width
        end
      end
      return @_rect.width
    end
    
    def height
      self._check_disposed
      return @_rect.height
    end
    
    def height=(value)
      self._check_disposed
      if @_rect.height != value
        @_rect.height = value
        @_sprite_contents.src_rect.height = value -
            XPA_Window::Config::MARGIN * 2
        if @_visible
          self._update_background
          self._update_height
        end
      end
      return @_rect.height
    end
    
    def z
      self._check_disposed
      return @_z
    end
    
    def z=(value)
      self._check_disposed
      if @_z != value
        @_z = value
        self._update_z if @_visible
      end
      return @_z
    end
    
    def ox
      self._check_disposed
      return @_ox
    end
    
    def ox=(value)
      self._check_disposed
      if @_ox != value
        @_ox = value
        @_sprite_contents.src_rect.x = value
        self._update_arrows if @_visible
      end
      return @_ox
    end
    
    def oy
      self._check_disposed
      return @_oy
    end
    
    def oy=(value)
      self._check_disposed
      if @_oy != value
        @_oy = value
        @_sprite_contents.src_rect.y = value
        self._update_arrows if @_visible
      end
      return @_oy
    end
    
    def opacity
      self._check_disposed
      return @_opacity
    end
    
    def opacity=(value)
      self._check_disposed
      if value < 0
        value = 0
      elsif value > 255
        value = 255
      end
      if @_opacity != value
        @_opacity = value
        self._update_opacity if @_visible
      end
      return @_opacity
    end
    
    def back_opacity
      self._check_disposed
      return @_back_opacity
    end
    
    def back_opacity=(value)
      self._check_disposed
      if value < 0
        value = 0
      elsif value > 255
        value = 255
      end
      if @_back_opacity != value
        @_back_opacity = value
        self._update_back_opacity if @_visible
      end
      return @_back_opacity
    end
    
    def contents_opacity
      self._check_disposed
      return @_contents_opacity
    end
    
    def contents_opacity=(value)
      self._check_disposed
      if value < 0
        value = 0
      elsif value > 255
        value = 255
      end
      if @_contents_opacity != value
        @_contents_opacity = value
        self._update_contents_opacity if @_visible
      end
      return @_contents_opacity
    end
    
    def active
      self._check_disposed
      return @_active
    end
    
    def active=(value)
      self._check_disposed
      @_active = value
      return @_active
    end
    
    def pause
      self._check_disposed
      return @_pause
    end
    
    def pause=(value)
      self._check_disposed
      if @_pause != value
        @_pause = value
        if @_pause
          @_pause_update_count = 0 if @_pause_update_count < 0
        else
          @_pause_update_count = 4 if @_pause_update_count > 4
        end
        self._update_pause if @_visible
      end
      return @_pause
    end
    
    def stretch
      self._check_disposed
      return @_stretch
    end
    
    def stretch=(value)
      self._check_disposed
      if @_stretch != value
        @_stretch = value
        self._update_background if @_visible
      end
      return @_stretch
    end
    
    def windowskin
      self._check_disposed
      return @_windowskin
    end
    
    def windowskin=(value)
      self._check_disposed
      if @_windowskin != value
        @_windowskin = value
        self._update_skin if @_visible
      end
      return @_windowskin
    end
    
    def contents
      self._check_disposed
      return @_sprite_contents.bitmap
    end
    
    def contents=(value)
      self._check_disposed
      @_sprite_contents.bitmap = value
      if value != nil
        width = value.width
        height = value.height
        if width > @_rect.width - XPA_Window::Config::MARGIN * 2
          width = @_rect.width - XPA_Window::Config::MARGIN * 2
        end
        if height > @_rect.height - XPA_Window::Config::MARGIN * 2
          height = @_rect.height - XPA_Window::Config::MARGIN * 2
        end
        @_sprite_contents.src_rect.set(@_ox, @_oy, width, height)
      end
      if @_visible
        self._update_arrow_down
        self._update_arrow_right
      end
      return @_sprite_contents.bitmap
    end
    
    def _check_disposed
      raise RGSSError.new("disposed window") if self.disposed?
    end
    
    def update
      self._check_disposed
      if @_pause
        @_pause_update_count += 1
      else
        @_pause_update_count -= 1
      end
      self._update_pause_src_rect
      self._update_cursor
    end
    
    def _update_visible
      return if !@_visible
      self._update_x
      self._update_y
      self._update_z
      self._update_skin
      self._update_opacity
      self._update_contents_opacity
      self._update_pause
      self._update_arrows
    end
    
    def _update_background
      background_width = @_rect.width - 2 *
          XPA_Window::Config::BACKGROUND_MARGIN
      background_height = @_rect.height - 2 *
          XPA_Window::Config::BACKGROUND_MARGIN
      if @_stretch
        @_sprite_background.bitmap = Skin.get_background(@_windowskin,
            background_width, background_height)
      else
        @_sprite_background.bitmap = Skin.get_tiled_background(@_windowskin,
            background_width, background_height)
        @_sprite_background.src_rect.width = background_width
        @_sprite_background.src_rect.height = background_height
      end
    end
    
    def _update_x
      @_sprite_background.x = @_rect.x + XPA_Window::Config::BACKGROUND_MARGIN
      @_sprite_borders[0].x = @_rect.x + XPA_Window::Config::BORDER_THICKNESS
      @_sprite_borders[1].x = @_rect.x + XPA_Window::Config::BORDER_THICKNESS
      @_sprite_borders[2].x = @_rect.x
      @_sprite_corners[0].x = @_rect.x
      @_sprite_corners[2].x = @_rect.x
      self._update_width_only
      self._update_arrows
    end
    
    def _update_y
      @_sprite_background.y = @_rect.y + XPA_Window::Config::BACKGROUND_MARGIN
      @_sprite_borders[0].y = @_rect.y
      @_sprite_borders[2].y = @_rect.y + XPA_Window::Config::BORDER_THICKNESS
      @_sprite_borders[3].y = @_rect.y + XPA_Window::Config::BORDER_THICKNESS
      @_sprite_corners[0].y = @_rect.y
      @_sprite_corners[1].y = @_rect.y
      self._update_height_only
      self._update_arrows
    end
    
    def _update_z
      @_sprite_background.z = @_z
      @_sprite_cursor.z = @_z
      @_sprite_pause.z = @_z + 20
      @_sprite_borders.each {|sprite| sprite.z = @_z + 10}
      @_sprite_corners.each {|sprite| sprite.z = @_z + 10}
      @_sprite_arrows.each {|sprite| sprite.z = @_z + 10}
      @_sprite_contents.z = @_z + 2
    end
    
    def _update_width_only
      @_sprite_borders[3].x = @_rect.x + @_rect.width -
          XPA_Window::Config::BORDER_THICKNESS
      @_sprite_corners[1].x = @_rect.x + @_rect.width -
          XPA_Window::Config::BORDER_THICKNESS
      @_sprite_corners[3].x = @_rect.x + @_rect.width -
          XPA_Window::Config::BORDER_THICKNESS
      @_sprite_pause.x = @_rect.x + (@_rect.width -
          XPA_Window::Config::PAUSE_RECTS[0].width) / 2
      @_cursor_rect.refresh
      self._update_horizontal_borders
    end
    
    def _update_width
      self._update_width_only
      self._update_arrows
    end
    
    def _update_height_only
      @_sprite_borders[1].y = @_rect.y + @_rect.height -
          XPA_Window::Config::BORDER_THICKNESS
      @_sprite_corners[2].y = @_rect.y + @_rect.height -
          XPA_Window::Config::BORDER_THICKNESS
      @_sprite_corners[3].y = @_rect.y + @_rect.height -
          XPA_Window::Config::BORDER_THICKNESS
      @_sprite_pause.y = @_rect.y + @_rect.height -
          XPA_Window::Config::PAUSE_RECTS[0].height
      @_cursor_rect.refresh
      self._update_vertical_borders
    end
    
    def _update_height
      self._update_height_only
      self._update_arrows
    end
    
    def _update_skin
      self._update_background
      @_sprite_cursor.windowskin = @_windowskin
      @_cursor_rect.refresh
      self._update_horizontal_borders
      self._update_vertical_borders
      @_sprite_corners.each_index {|i|
          @_sprite_corners[i].bitmap = @_windowskin
          if @_windowskin != nil
            @_sprite_corners[i].src_rect = XPA_Window::Config::CORNER_RECTS[i]
          end
      }
      @_sprite_pause.bitmap = @_windowskin
      self._update_pause_src_rect
      @_sprite_arrows.each_index {|i|
          @_sprite_arrows[i].bitmap = @_windowskin
          @_sprite_arrows[i].src_rect = XPA_Window::Config::ARROW_RECTS[i]
      }
    end
    
    def _update_horizontal_borders
      width = @_rect.width -
          2 * XPA_Window::Config::BORDER_THICKNESS
      (0...(XPA_Window::Config::MAX_BORDERS / 2)).each {|i|
          @_sprite_borders[i].bitmap = Skin.get_border_horizontal(@_windowskin,
              i, width)
          if @_sprite_borders[i].bitmap != nil
            @_sprite_borders[i].src_rect.set(0, 0, width,
                XPA_Window::Config::BORDER_RECTS[i].height)
          end
      }
    end
    
    def _update_vertical_borders
      height = @_rect.height -
          2 * XPA_Window::Config::BORDER_THICKNESS
      (0...(XPA_Window::Config::MAX_BORDERS / 2)).each {|i|
          @_sprite_borders[i + 2].bitmap = Skin.get_border_vertical(
              @_windowskin, i, height)
          if @_sprite_borders[i + 2].bitmap != nil
            @_sprite_borders[i + 2].src_rect.set(0, 0,
                XPA_Window::Config::BORDER_RECTS[i + 2].width, height)
          end
      }
    end
    
    def _update_opacity
      @_sprite_borders.each {|sprite| sprite.opacity = @_opacity}
      @_sprite_corners.each {|sprite| sprite.opacity = @_opacity}
      self._update_back_opacity
    end
    
    def _update_back_opacity
      @_sprite_background.opacity = @_opacity * @_back_opacity / 255
    end
    
    def _update_contents_opacity
      @_sprite_contents.opacity = @_contents_opacity
      self._update_cursor
    end
    
    def _update_cursor
      frames = XPA_Window::Config::CURSOR_BLINK_FRAMES
      @_cursor_update_count = (@_cursor_update_count + 1) % frames if @_active
      count = @_cursor_update_count
      count = frames - count if count >= frames / 2
      @_sprite_cursor.opacity = @_contents_opacity * (frames - count) / frames
    end
    
    def _update_pause
      @_sprite_pause.visible = @_pause
    end
    
    def _update_pause_src_rect
      index = @_pause_update_count % (XPA_Window::Config::PAUSE_FRAME_STEP * 4) /
          XPA_Window::Config::PAUSE_FRAME_STEP
      @_sprite_pause.src_rect = XPA_Window::Config::PAUSE_RECTS[index]
    end
    
    def _update_arrows
      self._update_arrow_up
      self._update_arrow_down
      self._update_arrow_left
      self._update_arrow_right
    end
    
    def _update_arrow_up
      @_sprite_arrows[0].x = (@_rect.x + @_rect.width -
          XPA_Window::Config::ARROW_RECTS[0].width) / 2
      @_sprite_arrows[0].y = @_rect.y + XPA_Window::Config::ARROW_OFFSET
      @_sprite_arrows[0].visible = (@_sprite_contents.bitmap != nil &&
          @_sprite_contents.src_rect.y > 0)
    end
    
    def _update_arrow_down
      @_sprite_arrows[1].x = (@_rect.x + @_rect.width -
          XPA_Window::Config::ARROW_RECTS[1].width) / 2
      @_sprite_arrows[1].y = @_rect.y + @_rect.height -
          XPA_Window::Config::ARROW_RECTS[1].height -
          XPA_Window::Config::ARROW_OFFSET
      @_sprite_arrows[1].visible = (@_sprite_contents.bitmap != nil &&
          @_sprite_contents.bitmap.height - @_sprite_contents.src_rect.y >
              @_rect.height - XPA_Window::Config::MARGIN * 2)
    end
    
    def _update_arrow_left
      @_sprite_arrows[2].x = @_rect.x + XPA_Window::Config::ARROW_OFFSET
      @_sprite_arrows[2].y = (@_rect.y + @_rect.height -
          XPA_Window::Config::ARROW_RECTS[2].width) / 2
      @_sprite_arrows[2].visible = (@_sprite_contents.bitmap != nil &&
          @_sprite_contents.src_rect.x > 0)
    end
    
    def _update_arrow_right
      @_sprite_arrows[3].x = @_rect.x + @_rect.width -
          XPA_Window::Config::ARROW_RECTS[3].width -
          XPA_Window::Config::ARROW_OFFSET
      @_sprite_arrows[3].y = (@_rect.y + @_rect.height -
          XPA_Window::Config::ARROW_RECTS[3].height) / 2
      @_sprite_arrows[3].visible = (@_sprite_contents.bitmap != nil &&
          @_sprite_contents.bitmap.width - @_sprite_contents.src_rect.x >
              @_rect.width - XPA_Window::Config::MARGIN * 2)
    end
    
  end
  
end

Window = XPA_Window::Window

end