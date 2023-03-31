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
if XPA_CONFIG::DLL_FOLDER_NAME != ''
class Win32API
  class << Win32API
    alias check_system_folder new
    def new(*args)
      args[0] += '.dll' unless args[0][/.dll/]
      if !FileTest.exist?(args[0])
        try = "System/" + args[0]
        args[0] = try if FileTest.exist?(try)
      end
      check_system_folder(*args)
    end
  end
end
end
getCommandLine_f = Win32API.new("Kernel32", "GetCommandLine", "", "P")
startupString = getCommandLine_f.call.split(' ')
if startupString[1] == 'debug'
  $DEBUG = $TEST = XPA_CONFIG::TOGGLE_DEBUG
end

class Sprite
  class << Sprite
    alias new_xpa_sprite_fix new
    def new(*args)
      object = new_xpa_sprite_fix(*args)
      if !object.disposed? && object.viewport != nil
        object.viewport.register_sprite(object)
      end
      return object
    end
  end 
  
  alias dispose_xpa_sprite_fix dispose
  def dispose
    if !self.disposed? && self.viewport != nil
      self.viewport.unregister_sprite(self)
    end
    dispose_xpa_sprite_fix
  end
  
end

class Viewport
  
  alias dispose_xpa_sprite_fix dispose
  def dispose
    if @_sprites != nil
      @_sprites.clone.each {|sprite| sprite.dispose if !sprite.disposed? }
      @_sprites = []
    end
    dispose_xpa_sprite_fix
  end
  
  def register_sprite(sprite)
    @_sprites ||= []
    @_sprites.push(sprite)
  end
  
  def unregister_sprite(sprite)
    @_sprites ||= []
    @_sprites.delete(sprite)
  end
  
end

if XPA_CONFIG::CONSOLE_OUTPUT && ($DEBUG || $TEST)
  # Create a console object and redirect standard output to it.
  Win32API.new('kernel32', 'AllocConsole', 'V', 'L').call
  $stdout.reopen('CONOUT$')
  # Find the game title.
  ini = Win32API.new('kernel32', 'GetPrivateProfileString','PPPPLP', 'L')
  title = "\0" * 256
  ini.call('Game', 'Title', '', title, 256, RPG.ini_file('.\\'))
  title.delete!("\0")
  # Set the game window as the top-most window.
  hwnd = Win32API.new('user32', 'FindWindowA', 'PP', 'L').call('RGSS Player', title)  
  Win32API.new('user32', 'SetForegroundWindow', 'L', 'L').call(hwnd)
  # Set the title of the console debug window'
  Win32API.new('kernel32','SetConsoleTitleA','P','S').call("#{title} :  Debug Console")

  alias zer0_console_inspect puts
  def puts(*args)
    inspected = args.collect {|arg| arg.inspect }
    zer0_console_inspect(*inspected)
  end
end

if XPA_CONFIG::SUPERCLASS_MISMATCH_HELPER
  
$found_superclass_mismatch = false
mismatch_counter = 0

alias orig_main rgss_main
def rgss_main(&block)
  if $found_superclass_mismatch
    smh_save_script_changes
    print "Found superclass mismatch(es)! Fix applied!\nPlease close and reopen your project.\n" +
      "Closing game executable now."
    exit
  end
  orig_main(&block)
end

def smh_save_script_changes
  ini = Win32API.new('kernel32', 'GetPrivateProfileString','PPPPLP', 'L')
  scripts_filename = "\0" * 256
  ini.call('Game', 'Scripts', '', scripts_filename, 256, RPG.ini_file('.\\'))
  scripts_filename.delete!("\0")
  for i in 0...$RGSS_SCRIPTS.size
    code = $RGSS_SCRIPTS[i][3]
    z = Zlib::Deflate.new(6)
    data = z.deflate(code, Zlib::FINISH)
    $RGSS_SCRIPTS[i][2] = data
  end
  file = File.open(scripts_filename, "wb")
  Marshal.dump($RGSS_SCRIPTS, file)
  file.close
end

loop do
  start = __FILE__.scan(/\d+/)[0].to_i + 1
  
  for i in start...$RGSS_SCRIPTS.size
    code = $RGSS_SCRIPTS[i][3]
    mismatch_counter = 0
    
    begin
      eval("#encoding: UTF-8\r\n" + code, binding, sprintf("{%04d}", i))
    rescue TypeError => err
      if err.message[/superclass mismatch/].nil?
        bt = err.backtrace
        line_num = err.backtrace[0].scan(/{\d+}:(\d+)/).flatten[0].to_i
        line_num -= mismatch_counter
        bt[0].gsub!(/:\d+/){":#{line_num}"}
        err.set_backtrace(bt)
        raise err
      end
      $found_superclass_mismatch = true
      mismatch_counter += 1
      subclass = err.message.scan(/ class (.+)/).flatten[0]
      line_num = err.backtrace[0].scan(/{\d+}:(\d+)/).flatten[0].to_i
      line = code.split("\n")[line_num-2]
      code.sub!(line, "Object.send(:remove_const, :#{subclass})\r\n" + line)
      retry
    rescue SystemStackError
      if $found_superclass_mismatch
        smh_save_script_changes
        restart_game = true
        break
      else
        raise $!
      end
    rescue Exception => err
      bt = err.backtrace
      line_m = err.message.scan(/{\d+}:(\d+)/).flatten[0].to_i
      line_b = err.backtrace[0].scan(/{\d+}:(\d+)/).flatten[0].to_i
      if line_m != 0
        line_m -= mismatch_counter
        msg = err.message[/{\d+}:\d+/]
        msg.sub!(/:\d+/){":#{line_m}"}
        bt.unshift(msg)
      else
        line_b -= mismatch_counter
        bt[0].sub!(/:\d+/){":#{line_b}"}
      end
      err.set_backtrace(bt)
      raise err
    end
  end
end
exit
end