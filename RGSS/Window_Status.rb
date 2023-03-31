class Window_Status < Window_Base
  def initialize(actor)
    super(0, 0, 640, 480)
    self.contents = Bitmap.new(width - 32, height - 32)
    @actor = actor
    refresh
  end
  def refresh
    self.contents.clear
    draw_actor_graphic(@actor, 40, 130)
    draw_actor_name(@actor, 4, -20)
    self.contents.font.color = system_color
    draw_actor_class(@actor, 4, 20)
    self.contents.font.color = normal_color
    self.contents.font.color = system_color
  end
  def dummy
    self.contents.font.color = system_color
  end
end