class Game_CommonEvent
  def initialize(common_event_id)
    @common_event_id = common_event_id
    @interpreter = nil
    refresh
  end

  def name
    return $data_common_events[@common_event_id].name
  end

  def trigger
    return $data_common_events[@common_event_id].trigger
  end

  def switch_id
    return $data_common_events[@common_event_id].switch_id
  end

  def list
    return $data_common_events[@common_event_id].list
  end

  def refresh
    if self.trigger == 2 and $game_switches[self.switch_id] == true
      if @interpreter == nil
        @interpreter = Interpreter.new
      end
    else
      @interpreter = nil
    end
  end

  def update
    if @interpreter != nil
      unless @interpreter.running?
        @interpreter.setup(self.list, 0)
      end
      @interpreter.update
    end
  end
end