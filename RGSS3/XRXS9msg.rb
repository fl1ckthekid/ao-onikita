class Window_Message < Window_Selectable
  DEFAULT_FONT_NAME      = ""
  DEFAULT_FONT_SIZE      =  20
  DEFAULT_LINE_SPACE     =  26
  DEFAULT_BG_PICTURE     = ""
  DEFAULT_BG_X           =   0
  DEFAULT_BG_Y           = 320
  DEFAULT_RECT           = Rect.new(80, 304, 496, 160)
  DEFAULT_BACK_OPACITY   = 255
  DEFAULT_STRETCH_ENABLE = true
  INFO_RECT              = Rect.new(-16, 64, 672, DEFAULT_LINE_SPACE + 32)
  DEFAULT_TYPING_ENABLE = true
  DEFAULT_TYPING_SPEED  = 1
  KEY_SHOW_ALL          = Input::B
  KEY_MESSAGE_SKIP      = Input::L
  HISKIP_ENABLE_SWITCH_ID = 0
  SKIP_BAN_SWITCH_ID      = 5
  FACE_STRETCH_ENABLE    = false
  FACE_WIDTH             =  96
  FACE_HEIGHT            =  96
  CHARPOP_HEIGHT         =  56
end
module XRXS9
  NAME_WINDOW_TEXT_COLOR  = Color.new(192,240,255,255)
  NAME_WINDOW_TEXT_SIZE   =  20
  NAME_WINDOW_SPACE       =  10
  NAME_WINDOW_OFFSET_X    =   0
  NAME_WINDOW_OFFSET_Y    = -26
  FOBT_DURATION           =  20
end
class Game_System
  attr_accessor :speak_se
  def speak_se_play
    self.se_play(self.speak_se) if self.speak_se != nil
  end
end
class Window_Message < Window_Selectable
  NOT_SOUND_CHARACTERS = [" ", "　", "・", "、", "。", "─"]
end
class Sprite_Pause < Sprite
  def initialize
    super
    self.bitmap = RPG::Cache.windowskin($game_system.windowskin_name)
    self.x = 604
    self.y = 456
    self.z = 6001
    @count = 0
    @wait_count = 0
    update
  end
  def update
    super
    if @wait_count > 0
      @wait_count -= 1
    else
      @count = (@count + 1)%4
      x = 160 + @count % 2
      y =  64 + @count / 2
      self.src_rect.set(x, y, 16, 16)
      @wait_count = 4
    end
  end
end
class Window_Message < Window_Selectable
  AUTO   = 0
  LEFT   = 1
  CENTER = 2
  RIGHT  = 3
  def line_height
    return DEFAULT_LINE_SPACE
  end
  alias xrxs9_initialize initialize
  def initialize
    @stand_pictuers = []
    @held_windows = []
    @extra_windows = []
    @extra_sprites = []
    @pause = Sprite_Pause.new
    xrxs9_initialize
    @pause.visible = false
    @pause.z = self.z + 1
  end
  alias xrxs9_dispose dispose
  def dispose
    @held_windows.each {|window| window.dispose}
    @held_windows.clear
    @pause.dispose
    if @gaiji_cache != nil
      @gaiji_cache.dispose
      @gaiji_cache = nil
    end
    xrxs9_dispose
  end
  alias xrxs9_terminate_message terminate_message
  def terminate_message
    @passable = false
    $game_player.messaging_moving = false
    if @bgframe_sprite != nil
      @bgframe_sprite.dispose
    end
    if @window_hold
      @held_windows.push(Window_Copy.new(self))
      for window in @extra_windows
        next if window.disposed?
        @held_windows.push(Window_Copy.new(window))
      end
      for sprite in @extra_sprites
        next if sprite.disposed?
        @held_windows.push(Sprite_Copy.new(sprite))
      end
      self.opacity = 0
      self.contents_opacity = 0
      @extra_windows.clear
      @extra_sprites.clear
    else
      @held_windows.each {|object| object.dispose}
      @held_windows.clear
    end
    if @name_window_frame != nil
      @name_window_frame.dispose
      @name_window_frame = nil
    end
    if @name_window_text  != nil
      @name_window_text.dispose
      @name_window_text  = nil
    end
    xrxs9_terminate_message
  end
  def pop_character=(character_id)
    @pop_character = character_id
  end
  def pop_character
    return @pop_character
  end
  def clear
    self.contents.clear
    self.contents.font.color = normal_color
    self.contents.font.size  = DEFAULT_FONT_SIZE
    self.contents.font.name = DEFAULT_FONT_NAME if DEFAULT_FONT_NAME != ""
    self.opacity          = 255
    self.back_opacity     = DEFAULT_BACK_OPACITY
    self.contents_opacity = 255
    @mid_stop     = false
    @face_file    = nil
    @current_name = nil
    @window_hold  = false
    @stand_pictuer_hold = false
    @passable     = false
    @inforesize   = false
    @auto_align   = LEFT
    @default_rect = DEFAULT_RECT
    @default_rect = DEFAULT_RECT
    @x = @y = @indent = @line_index = 0
    @cursor_width = @write_wait = @lines_max = 0
    @write_speed = DEFAULT_TYPING_SPEED
    @line_widths = []
    @line_aligns = []
    self.pop_character = nil
  end
  def refresh
    if DEFAULT_BG_PICTURE != ""
      bitmap = RPG::Cache.picture(DEFAULT_BG_PICTURE)
      @bgframe_sprite = Sprite.new
      @bgframe_sprite.x = DEFAULT_BG_X
      @bgframe_sprite.y = DEFAULT_BG_Y
      @bgframe_sprite.bitmap = bitmap
      @bgframe_sprite.z += 5
    end
    self.clear
    if $game_temp.message_text != nil
      @now_text = $game_temp.message_text
      if (/\\_\n/.match(@now_text)) != nil
        $game_temp.choice_start -= 1
        @now_text.gsub!(/\\_\n/) { "" }
      end
      if (/\\[Ff]\[(.+?)(?:,(\d+))?\]/.match(@now_text)) != nil
        if RPG_FileTest.picture_exist?($1)
          @face_file = $1 + ".png"
          @face_index = $2.to_i
          src = RPG::Cache.picture(@face_file)
          if FACE_STRETCH_ENABLE
            @indent += FACE_WIDTH
          elsif $2 == nil
            @indent += src.width
            @face_index = -1
          else
            @indent += src.width/4
          end
        end
        @now_text.gsub!(/\\[Ff]\[(.*?)\]/) { "" }
      end
      @inforesize = (@now_text.gsub!(/\\info/) { "" } != nil)
      @window_hold = (@now_text.gsub!(/\\hold/) { "" } != nil)
      @now_text.gsub!(/\\[v]\[([0-9]+)\]/) { $game_variables[$1.to_i].to_s }
      begin
        last_text = @now_text.clone
        @now_text.gsub!(/\\[V]\[([IiWwAaSs]?)([0-9]+)\]/) { convart_value($1, $2.to_i) }
      end until @now_text == last_text
      @now_text.gsub!(/\\[Nn]\[([0-9]+)\]/) do
        $game_actors[$1.to_i] != nil ? $game_actors[$1.to_i].name : ""
      end
      if @now_text.sub!(/\\[Nn]ame\[(.*?)\]/) { "" }
        @current_name = $1
      end
      if @now_text.gsub!(/\\[Pp]\[([0-9]+)\]/) { "" }
        self.pop_character = $1.to_i
      end
      if (/\\n/.match(@now_text)) != nil
        $game_temp.choice_start += 1
        @now_text.gsub!(/\\n/) { "\n" }
      end
      if @now_text.gsub!(/\\fade/) { "" }
        @fade_count_before_terminate = XRXS9::FOBT_DURATION
      end
      if @now_text.gsub!(/\\pass/) { "" }
        @passable = true
        $game_player.messaging_moving = true
      end
      nil while( @now_text.sub!(/\n\n\z/) { "\n" } )
      @lines_max = @now_text.scan(/\n/).size
      rxs = [/\\\w\[(\w+)\]/, /\\[.]/, /\\[|]/, /\\[>]/, /\\[<]/, /\\[!]/,
              /\\[~]/, /\\[i]/, /\\[Oo]\[([0-9]+)\]/, /\\[Hh]\[([0-9]+)\]/,
              /\\[b]\[([0-9]+)\]/, /\\[Rr]\[(.*?)\]/, /\\[B]/, /\\[I]/]
      @max_choice_x = 0
      @line_aligns[0] = CENTER if @inforesize
      lines = @now_text.split(/\n/)
      for i in 0..@lines_max
        line = lines[@lines_max - i]
        next if line == nil
        line.gsub!(/\\[Ee]\[([0-9]+)\]/) { "\022[#{$1}]" }
        for rx in rxs
          line.gsub!(rx) { "" }
        end
        @line_aligns[@lines_max - i] =
          line.sub!(/\\center/) {""} ? CENTER :
          line.sub!(/\\right/)  {""} ? RIGHT :
          line.sub!(/\\left/)   {""} ? LEFT :
                                       AUTO
        cx = contents.text_size(line).width
        @line_widths[@lines_max - i] = cx
      end
      choices = @line_widths[$game_temp.choice_start, @line_widths.size]
      @max_choice_x = choices == nil ? 0 : choices.max + 8
      @now_text.gsub!(/\\center/) {""}
      @now_text.gsub!(/\\right/) {""}
      @now_text.gsub!(/\\left/) {""}
      if self.pop_character != nil and self.pop_character >= 0
        max_x = @line_widths.max.to_i
        self.width = max_x + 32 + @indent + DEFAULT_FONT_SIZE/2
        self.height = [@lines_max * line_height, @indent].max  + 32
      end
      @now_text.gsub!(/\\\\/) { "\000" }
      @now_text.gsub!(/\\[Cc]\[([0-9]+)\]/) { "\001[#{$1}]" }
      @now_text.gsub!(/\\[Gg]/) { "\002" }
      @now_text.gsub!(/\\[Ss]\[([0-9]+)\]/) { "\003[#{$1}]" }
      @now_text.gsub!(/\\[Aa]\[(.*?)\]/) { "\004[#{$1}]" }
      @now_text.gsub!(/\\[.]/) { "\005" }
      @now_text.gsub!(/\\[|]/) { "\006" }
      @now_text.gsub!(/\\[>]/) { "\016" }
      @now_text.gsub!(/\\[<]/) { "\017" }
      @now_text.gsub!(/\\[!]/) { "\020" }
      @now_text.gsub!(/\\[~]/) { "\021" }
      @now_text.gsub!(/\\[Ee]\[([0-9]+)\]/) { "\022[#{$1}]" }
      @now_text.gsub!(/\\[i]/) { "\023" }
      @now_text.gsub!(/\\[Oo]\[([0-9]+)\]/) { "\024[#{$1}]" }
      @now_text.gsub!(/\\[Hh]\[([0-9]+)\]/) { "\025[#{$1}]" }
      @now_text.gsub!(/\\[b]\[([0-9]+)\]/) { "\026[#{$1}]" }
      @now_text.gsub!(/\\[Rr]\[(.*?)\]/) { "\027[#{$1}]" }
      @now_text.gsub!(/\\[B]/) { "\031" }
      @now_text.gsub!(/\\[I]/) { "\032" }
      reset_window
      if @current_name != nil
        self.contents.font.size = XRXS9::NAME_WINDOW_TEXT_SIZE
        x = self.x + XRXS9::NAME_WINDOW_OFFSET_X
        y = self.y + XRXS9::NAME_WINDOW_OFFSET_Y
        w = self.contents.text_size(@current_name).width + 8 + XRXS9::NAME_WINDOW_SPACE
        h = 26 + XRXS9::NAME_WINDOW_SPACE
        @name_window_frame = Window_Base.new(x, y, w, h)
        @name_window_frame.opacity = 160
        @name_window_frame.z = self.z + 2
        x = self.x + XRXS9::NAME_WINDOW_OFFSET_X + 3 + XRXS9::NAME_WINDOW_SPACE / 2
        y = self.y + XRXS9::NAME_WINDOW_OFFSET_Y + 1 + XRXS9::NAME_WINDOW_SPACE / 2
        @name_window_text = Air_Text.new(x,y, @current_name, XRXS9::NAME_WINDOW_TEXT_SIZE, XRXS9::NAME_WINDOW_TEXT_COLOR)
        @name_window_text.z = self.z + 3
        self.contents.font.size = DEFAULT_FONT_SIZE
        @extra_windows.push(@name_window_frame)
        @extra_windows.push(@name_window_text)
      end
    end
    reset_window
    self.contents = Bitmap.new(self.width - 32, self.height - 32)
    self.contents.font.color = normal_color
    self.contents.font.name = DEFAULT_FONT_NAME if DEFAULT_FONT_NAME != ""
    unless @face_file.nil?
      src = RPG::Cache.picture(@face_file)
      if @face_index == -1
        w = src.width
        h = src.height
        x = 0
        y = 0
      else
        w = src.width/4
        h = src.height/4
        x = (@face_index-1) % 4 * w
        y = (@face_index-1) / 4 * h
      end
      if FACE_STRETCH_ENABLE
        self.contents.stretch_blt(Rect.new(0,0,FACE_WIDTH,FACE_HEIGHT), src, Rect.new(x, y, w, h))
      else
        self.contents.blt(0, 0, src, Rect.new(x, y, w, h))
      end
    end
    if $game_temp.choice_max > 0
      @item_max = $game_temp.choice_max
      self.active = true
      self.index = 0
    end
    if $game_temp.num_input_variable_id > 0
      digits_max = $game_temp.num_input_digits_max
      number = $game_variables[$game_temp.num_input_variable_id]
      @input_number_window = Window_InputNumber.new(digits_max)
      @input_number_window.number = number
      @input_number_window.x = self.x + 8 + @indent
      @input_number_window.y = self.y + $game_temp.num_input_start * 32
    end
    self.contents.font.size  = DEFAULT_FONT_SIZE
    line_reset
    update unless DEFAULT_TYPING_ENABLE
  end
  def line_reset
    align = @line_aligns[@line_index]
    align = @auto_align if align == AUTO
    case align
    when LEFT
      @x  = @indent
      @x += 8 if $game_temp.choice_start <= @line_index
    when CENTER
      @x = self.width / 2 - 16 - @line_widths[@line_index].to_i / 2
    when RIGHT
      @x = self.width - 40 - @line_widths[@line_index].to_i
    end
  end
  def update
    if @passable and not $game_player.messaging_moving
      self.opacity = 0
      terminate_message
      return
    end
    @pause.update if @pause.visible
    super
    update_main
  end
  def update_main
    if !self.pop_character.nil? and self.pop_character >= 0
      update_reset_window
    end
    if skippable_now? and Input.press?(KEY_MESSAGE_SKIP)
      self.contents_opacity = 255
      @fade_in = false
    elsif @fade_in
      self.contents_opacity += 24
      if @input_number_window != nil
        @input_number_window.contents_opacity += 24
      end
      if self.contents_opacity == 255
        @fade_in = false
      end
      return
    end
    @now_text = nil if @now_text == ""
    if @now_text != nil and @mid_stop == false
      if @write_wait > 0
        @write_wait -= 1
        return
      end
      text_not_skip = DEFAULT_TYPING_ENABLE
      while true
        if (c = @now_text.slice!(/./m)) != nil
          if c == "\000"
            c = "\\"
          end
          if c == "\001"
            @now_text.sub!(/\[([0-9]+)\]/, "")
            color = $1.to_i
            if color >= 0 and color <= 7
              self.contents.font.color = text_color(color)
              if @opacity != nil
                color = self.contents.font.color
                self.contents.font.color = Color.new(color.red, color.green, color.blue, color.alpha * @opacity / 255)
              end
            end
            c = ""
          end
          if c == "\002"
            if @gold_window == nil
              @gold_window = Window_Gold.new
              @gold_window.x = 560 - @gold_window.width
              if $game_temp.in_battle
                @gold_window.y = 192
              else
                @gold_window.y = self.y >= 128 ? 32 : 384
              end
              @gold_window.opacity = self.opacity
              @gold_window.back_opacity = self.back_opacity
            end
            c = ""
          end
          if c == "\003"
            @now_text.sub!(/\[([0-9]+)\]/, "")
            speed = $1.to_i
            if speed >= 0 and speed <= 19
              @write_speed = speed
            end
            c = ""
          end
          if c == "\005"
            @write_wait += 5
            c = ""
          end
          if c == "\006"
            @write_wait += 20
            c = ""
          end
          if c == "\016"
            text_not_skip = false
            c = ""
          end
          if c == "\017"
            text_not_skip = true
            c = ""
          end
          if c == "\020"
            @mid_stop = true
            c = ""
          end
          if c == "\021"
            terminate_message
            return
          end
          if c == "\023"
            @indent = @x
            c = ""
          end
          if c == "\024"
            @now_text.sub!(/\[([0-9]+)\]/, "")
            @opacity = $1.to_i
            color = self.contents.font.color
            self.contents.font.color = Color.new(color.red, color.green, color.blue, color.alpha * @opacity / 255)
            c = ""
          end
          if c == "\025"
            @now_text.sub!(/\[([0-9]+)\]/, "")
            self.contents.font.size = [[$1.to_i, 6].max, 32].min
            c = ""
          end
          if c == "\026"
            @now_text.sub!(/\[([0-9]+)\]/, "")
            @x += $1.to_i
            c = ""
          end
          if c == "\027"
            process_ruby
            $game_system.speak_se_play
            c = ""
          end
          if c == "\030"
            @now_text.sub!(/\[(.*?)\]/, "")
            self.contents.blt(@x , @y * line_height + 8, RPG::Cache.icon($1), Rect.new(0, 0, 24, 24))
            @x += 24
            c = ""
          end
          if c == "\n"
            @y += 1
            @line_index += 1
            line_reset
            if @line_index >= $game_temp.choice_start
              @cursor_width = @max_choice_x
            end
            c = ""
          end
          if c == "\022"
            @now_text.sub!(/\[([0-9]+)\]/, "")
            @x += draw_gaiji(4 + @x, @y * line_height + (line_height - self.contents.font.size), $1.to_i)
            c = ""
          end
          if c == "\031"
            self.contents.font.bold ^= true
            c = ""
          end
          if c == "\032"
            self.contents.font.italic ^= true
            c = ""
          end
          if c != ""
            self.contents.draw_text(4+@x, line_height * @y, 40, line_height, c)
            @x += self.contents.text_size(c).width
            unless NOT_SOUND_CHARACTERS.include?(c)
              $game_system.speak_se_play
            end
          end
          if skippable_now? and 
            (Input.press?(KEY_SHOW_ALL) or Input.press?(KEY_MESSAGE_SKIP)) and 
            (SKIP_BAN_SWITCH_ID == 0 ? true : !$game_switches[SKIP_BAN_SWITCH_ID])
            text_not_skip = false
          end
        else
          text_not_skip = true
          break
        end
        break if text_not_skip
      end
      @write_wait += @write_speed
      return
    end
    if @input_number_window != nil
      @input_number_window.update
      if Input.trigger?(Input::C)
        $game_system.se_play($data_system.decision_se)
        $game_variables[$game_temp.num_input_variable_id] = @input_number_window.number
        $game_map.need_refresh = true
        @input_number_window.dispose
        @input_number_window = nil
        terminate_message
      end
      return
    end
    if @contents_showing
      unless @fade_phase_before_terminate
        if $game_temp.choice_max == 0
          @pause.visible = true
        end
        if Input.trigger?(Input::B)
          if $game_temp.choice_max > 0 and $game_temp.choice_cancel_type > 0
            $game_system.se_play($data_system.cancel_se)
            $game_temp.choice_proc.call($game_temp.choice_cancel_type - 1)
            terminate_message
            @pause.visible = false
            return
          end
        end
        if Input.trigger?(Input::C) or 
           (skippable_now? and Input.press?(KEY_MESSAGE_SKIP))
          if $game_temp.choice_max > 0
            $game_system.se_play($data_system.decision_se)
            $game_temp.choice_proc.call(self.index)
          end
          if @mid_stop
            @mid_stop = false
            @pause.visible = false
            return
          elsif @fade_count_before_terminate.to_i > 0
            @fade_phase_before_terminate = true
          else
            terminate_message
          end
          @pause.visible = false
        end
      end
      if @fade_phase_before_terminate
        @fade_count_before_terminate  = 0 if @fade_count_before_terminate == nil
        @fade_count_before_terminate -= 1
        opacity = @fade_count_before_terminate * (256 / XRXS9::FOBT_DURATION)
        self.contents_opacity = opacity
        if @fade_count_before_terminate <= 0
          @fade_count_before_terminate = 0
          @fade_phase_before_terminate = false
          terminate_message
        end
      end
      return
    end
    if @fade_out == false and $game_temp.message_text != nil
      @contents_showing = true
      $game_temp.message_window_showing = true
      refresh
      Graphics.frame_reset
      self.visible = true
      self.contents_opacity = 0
      if @input_number_window != nil
        @input_number_window.contents_opacity = 0
      end
      @fade_in = true
      return
    end
    if self.visible
      @fade_out = true
      self.opacity -= 48
      if self.opacity == 0
        self.visible = false
        @fade_out = false
        $game_temp.message_window_showing = false
      end
      return
    end
  end
  def reset_window
    if @inforesize
      RectalCopy.copy(self, INFO_RECT)
    elsif self.pop_character != nil and self.pop_character >= 0
      update_reset_window
    else
      RectalCopy.copy(self, @default_rect)
      case ($game_temp.in_battle ? 0 : $game_system.message_position)
      when 0
        self.y = [16, -XRXS9::NAME_WINDOW_OFFSET_Y + 4].max
      when 1
        self.y = 160
      end
      if DEFAULT_STRETCH_ENABLE and @lines_max >= 4
        d = @lines_max * DEFAULT_LINE_SPACE + 32 - self.height
        if d > 0
          self.height += d
          case $game_system.message_position
          when 1
            self.y -= d/2
          when 2
            self.y -= d
          end
        end
      end
      if @face_file != nil
        self.width += FACE_WIDTH
        self.x -= FACE_WIDTH/2
      end
    end
    if $game_system.message_frame == 0
      self.back_opacity = DEFAULT_BACK_OPACITY
      @name_window_frame.back_opacity = DEFAULT_BACK_OPACITY unless @name_window_frame.nil?
    else
      self.opacity = 0
      @name_window_frame.back_opacity = 0 unless @name_window_frame.nil?
    end
    @pause.x = self.x + self.width  - 16
    @pause.y = self.y + self.height - 16
  end
  def update_reset_window
    if self.pop_character == 0 or $game_map.events[self.pop_character] != nil
      character = get_character(self.pop_character)
      x = character.screen_x - self.width / 2
      case $game_system.message_position
      when 0
        if @name_window_frame != nil and @name_window_frame.y <= 4
          y = 4 - XRXS9::NAME_WINDOW_OFFSET_Y
        else
          y = character.screen_y - CHARPOP_HEIGHT - self.height
        end
      else
        y = character.screen_y
      end
      self.x = [[x, 4].max, 636 - self.width ].min
      self.y = [[y, 4].max, 476 - self.height].min
      if  @name_window_frame != nil
        @name_window_frame.x = self.x + XRXS9::NAME_WINDOW_OFFSET_X
        @name_window_frame.y = self.y + XRXS9::NAME_WINDOW_OFFSET_Y
        @name_window_text.x  = self.x + XRXS9::NAME_WINDOW_OFFSET_X + 1 + XRXS9::NAME_WINDOW_SPACE/2 - 16
        @name_window_text.y  = self.y + XRXS9::NAME_WINDOW_OFFSET_Y + 1 + XRXS9::NAME_WINDOW_SPACE/2 - 16
      end
    end
  end
  def update_cursor_rect
    if @index >= 0
      n = $game_temp.choice_start + @index
      self.cursor_rect.set(8 + @indent, n * line_height, @cursor_width, line_height)
    else
      self.cursor_rect.empty
    end
  end
  def get_character(parameter)
    case parameter
    when 0
      return $game_player
    else
      events = $game_map.events
      return events == nil ? nil : events[parameter]
    end
  end
  def skippable_now?
    return ((SKIP_BAN_SWITCH_ID == 0 ? true : !$game_switches[SKIP_BAN_SWITCH_ID]) and 
       (HISKIP_ENABLE_SWITCH_ID == 0 ? true : $game_switches[HISKIP_ENABLE_SWITCH_ID]))
  end
  def visible=(b)
    @name_window_frame.visible = b unless @name_window_frame.nil?
    @name_window_text.visible  = b unless @name_window_text.nil?
    @input_number_window.visible  = b unless @input_number_window.nil?
    super
  end
  def process_ruby
  end
  def draw_gaiji(x, y, num)
  end
  def convart_value(option, index)
  end
end
class Air_Text < Window_Base
  def initialize(x, y, designate_text, size, text_color)
    super(x-16, y-16, 32 + designate_text.size * 12, 56)
    self.opacity      = 0
    self.contents = Bitmap.new(self.width - 32, self.height - 32)
    w = self.contents.width
    h = self.contents.height
    self.contents.font.size = size
    self.contents.font.color = text_color
    self.contents.draw_text(0, 0, w, h, designate_text)
  end
end
class Window_Copy < Window_Base
  def initialize(window)
    super(window.x, window.y, window.width, window.height)
    self.contents = window.contents.dup unless window.contents.nil?
    self.opacity = window.opacity
    self.back_opacity = window.back_opacity
    self.z = window.z
  end
end
class Sprite_Copy < Sprite
  def initialize(sprite)
    super()
    self.bitmap = sprite.bitmap.dup unless sprite.bitmap.nil?
    self.opacity = sprite.opacity
    self.x = sprite.x
    self.y = sprite.y
    self.z = sprite.z
    self.ox = sprite.ox
    self.oy = sprite.oy
  end
end
class Interpreter
  def command_101
     $game_system.timer_working = false
    
    if $game_temp.message_text != nil
      return false
    end
    @message_waiting = true
    $game_temp.message_proc = Proc.new { @message_waiting = false }
    $game_temp.message_text = @list[@index].parameters[0] + "\n"
    line_count = 1
    loop do
      if @list[@index+1].code == 401
        $game_temp.message_text += @list[@index+1].parameters[0] + "\n"
        line_count += 1
      else
        if @list[@index+1].code == 101
          if (/\\next\Z/.match($game_temp.message_text)) != nil
            $game_temp.message_text.gsub!(/\\next/) { "" }
            $game_temp.message_text += @list[@index+1].parameters[0] + "\n"
            @index += 1
            next
          end
        elsif @list[@index+1].code == 102
          if @list[@index+1].parameters[0].size <= 4 - line_count
            @index += 1
            $game_temp.choice_start = line_count
            setup_choices(@list[@index].parameters)
          end
        elsif @list[@index+1].code == 103
          if line_count < 4
            @index += 1
            $game_temp.num_input_start = line_count
            $game_temp.num_input_variable_id = @list[@index].parameters[0]
            $game_temp.num_input_digits_max = @list[@index].parameters[1]
          end
        end
        return true
      end
      @index += 1
    end
  end
end
class Game_Player < Game_Character
  attr_accessor :messaging_moving
end
module RectalCopy
  def self.copy(rect1, rect2)
    rect1.x      = rect2.x
    rect1.y      = rect2.y
    rect1.width  = rect2.width
    rect1.height = rect2.height
  end
end