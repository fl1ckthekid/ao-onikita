class Window_Message < Window_Selectable
  GAIJI_FILE = "gaiji.png"
  GAIJI_SIZE = 24
end

class Interpreter
  def pretend_stopping=(b)
    @pretend_stopping = b
  end
  alias xrxs9_running? running?
  def running?
    return (not @pretend_stopping and xrxs9_running?)
  end
end

class Game_Player < Game_Character
  alias xrxs9_update update
  def update
    return xrxs9_update unless @messaging_moving
    last_showing = $game_temp.message_window_showing
    $game_system.map_interpreter.pretend_stopping = true
    $game_temp.message_window_showing = false
    xrxs9_update
    $game_temp.message_window_showing = last_showing
    $game_system.map_interpreter.pretend_stopping = nil
  end
end

class Game_Event < Game_Character
  alias xrxs9_start start
  def start
    xrxs9_start
    if @starting and $game_player.messaging_moving
      $game_player.messaging_moving = false
    end
  end
end

class Window_Message < Window_Selectable
  def draw_gaiji(x, y, num)
    if @gaiji_cache == nil
      if RPG_FileTest.picture_exist?(GAIJI_FILE)
        @gaiji_cache = RPG::Cache.picture(GAIJI_FILE)
      else
        return 0
      end
    end
    if @gaiji_cache.width < num * GAIJI_SIZE
      return 0
    end
    size = GAIJI_SIZE
    self.contents.stretch_blt(Rect.new(x, y, size, size), @gaiji_cache, Rect.new(num * GAIJI_SIZE, 0, GAIJI_SIZE, GAIJI_SIZE))
    if SOUNDNAME_ON_SPEAK != "" then
      Audio.se_play(SOUNDNAME_ON_SPEAK)
    end
    return size
  end

  def convart_value(option, index)
    option == nil ? option = "" : nil
    option.downcase!
    case option
    when "i"
      unless $data_items[index].name == nil
        r = sprintf("\030[%s]%s", $data_items[index].icon_name, $data_items[index].name)
      end
    when "w"
      unless $data_weapons[index].name == nil
        r = sprintf("\030[%s]%s", $data_weapons[index].icon_name, $data_weapons[index].name)
      end
    when "a"
      unless $data_armors[index].name == nil
        r = sprintf("\030[%s]%s", $data_armors[index].icon_name, $data_armors[index].name)
      end
    when "s"
      unless $data_skills[index].name == nil
        r = sprintf("\030[%s]%s", $data_skills[index].icon_name, $data_skills[index].name)
      end
    else
      r = $game_variables[index]
    end
    r == nil ? r = "" : nil
    return r
  end
end

class Window_Message < Window_Selectable
  def process_ruby
    @now_text.sub!(/\[(.*?)\]/, "")
    x = @x
    y = @y * line_height
    w = 40
    h = line_height
    @x += self.contents.draw_ruby_text(x, y, w, h, $1)
  end
end

class Bitmap
  def draw_ruby_text(x, y, w, h, str)
    sizeback = self.font.size
    self.font.size * 3 / 2 > 32 ? rubysize = 32 - self.font.size : rubysize = self.font.size / 2
    rubysize = [rubysize, 6].max
    split_s = str.split(/,/)
    split_s[0] = "" if split_s[0] == nil
    split_s[1] = "" if split_s[1] == nil
    height = sizeback + rubysize
    width = self.text_size(split_s[0]).width
    self.font.size = rubysize
    ruby_width = self.text_size(split_s[1]).width
    self.font.size = sizeback
    buf_width = [self.text_size(split_s[0]).width, ruby_width].max
    width - ruby_width != 0 ? sub_x = (width - ruby_width) / 2 : sub_x = 0
    self.font.size = rubysize
    self.draw_text(x + sub_x, 4 + y - self.font.size, self.text_size(split_s[1]).width, self.font.size, split_s[1])
    self.font.size = sizeback
    self.draw_text(x, y, width, h, split_s[0])
    return width
  end
end