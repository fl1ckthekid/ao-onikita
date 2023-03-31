class Arrow_Base < Sprite
  attr_reader:index                    
  attr_reader:help_window

  def initialize(viewport)
    super(viewport)
    self.bitmap = RPG::Cache.windowskin($game_system.windowskin_name)
    self.ox = 16
    self.oy = 64
    self.z = 2500
    @blink_count = 0
    @index = 0
    @help_window = nil
    update
  end

  def index=(index)
    @index = index
    update
  end

  def help_window=(help_window)
    @help_window = help_window
    if @help_window != nil
      update_help
    end
  end

  def update
    @blink_count = (@blink_count + 1) % 8
    if @blink_count < 4
      self.src_rect.set(128, 96, 32, 32)
    else
      self.src_rect.set(160, 96, 32, 32)
    end
    if @help_window != nil
      update_help
    end
  end
end