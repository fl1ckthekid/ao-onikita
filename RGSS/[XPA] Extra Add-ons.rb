if XPA_CONFIG::EXIT_MESSAGE_INTERCEPT
  MessageIntercept = Win32API.new('MessageIntercept', 'Initialize', 'P', '')
  a = MessageIntercept.call(RPG.ini_file('.\\'))
  
  module Graphics
    ClosedGame = Win32API.new('MessageIntercept', 'ClosedGame', '', 'i')
    
    class << self
      alias check_if_game_closed update
    end
    
    def self.update
      if ClosedGame.call() == 1
        exit
      end
      check_if_game_closed
    end
  end
end
if XPA_CONFIG::KEEP_GAME_RUNNING
  module NoDeactivateDLL
    Start = Win32API.new("NoDeactivate", "Start", 'P', '')
    InFocus = Win32API.new("NoDeactivate", "InFocus", '', 'i')
  end
  
  module Input
    class << self
      alias update_again update
    end
    
    def self.update
      update_again if NoDeactivateDLL::InFocus.call() == 1
    end
  end
  NoDeactivateDLL::Start.call(RPG.ini_file('.\\'))
end