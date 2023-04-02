module XPA_CONFIG
  
  # In RGSS3, text can now have outlines. This is normally enabled by default.
  # Some people prefer to keep the outlines disabled to keep the XP look.
  FONT_OUTLINE = true
  
  # Allows your game to run in debug mode from the editor. It is recommended to 
  # disable this when distributing your game, although it is not necessary.
  TOGGLE_DEBUG = false
  
  # Create a console window alongside your game during debug mode. Normally this
  # feature is already built into RGSS3, but accessing it is a bit obscure.
  # Instead, we will be using ForeverZer0's Console Output script.
  # Use the 'puts' method to output to the console.
  CONSOLE_OUTPUT = false
  
  # Checks your scripts for any superclass mismatches and fixes them. This 
  # script will run automatically upon test-playing your game. It will make the
  # necessary changes to your scripts and save them directly to your
  # Scripts.rxdata file.
  SUPERCLASS_MISMATCH_HELPER = true
  
  # Checks your game directory for a folder containing DLLs. Now you can be even
  # more organized with all your DLLs not cluttering your project.
  # DLL_FOLDER_NAME will be the folder your DLLs are located in.
  # If the string is empty, this feature is disabled.
  DLL_FOLDER_NAME = 'System'
  
  # Enables the XPA_Window script. This is a custom rewrite of the Window class
  # that mimics the functionality and style of RMXP. It is recommended that you
  # have this script enabled UNLESS you are using another custom window rewrite.
  # For more configuration options, please refer to the XPA_Window script.
  XPA_WINDOW = true
  
  # Searches for your RMXP Standard RTP assests in your computer's environment 
  # variables and loads them into the game. This will remove the hassle of
  # having to manually import all your RTP assests into every project.
  RTP_LOADER = true
  
  # In RGSS1, you could alias Kernel#exit to run any last-minute code before the
  # game window closes (ideal for online games). In RGSS3, that feature was removed.
  EXIT_MESSAGE_INTERCEPT = false
  
  # When the game window is no longer the active window, it prevents the game 
  # from updating. Setting this to true will allow games to still run in the background.
  KEEP_GAME_RUNNING = false
  
end