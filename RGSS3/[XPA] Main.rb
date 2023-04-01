def traceback_report
    backtrace = $!.backtrace.clone
    backtrace.each{ |bt|
      bt.sub!(/{(\d+)}/) {"[#{$1}]#{$RGSS_SCRIPTS[$1.to_i][1]}"}
    }
    return $!.message + "\n\n" + backtrace.join("\n")
  end
  
  def raise_traceback_error
    if $!.message.size >= 900
      File.open('traceback.log', 'w') { |f| f.write($!) }
      raise 'Traceback is too big. Output in traceback.log'
    else
      raise
    end
  end
  
  begin
  rgss_main {
    Font.default_outline = XPA_CONFIG::FONT_OUTLINE
    Graphics.resize_screen(SCREEN_RESOLUTION[0], SCREEN_RESOLUTION[1]) 
    Graphics.freeze
    $scene = Scene_Title.new
    $scene.main while $scene != nil
    Graphics.transition(20)
    exit
  }
  rescue SyntaxError
    $!.message.sub!($!.message, traceback_report)
    raise_traceback_error
  rescue
    $!.message.sub!($!.message, traceback_report)
    raise_traceback_error
  end
  exit