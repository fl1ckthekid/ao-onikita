class Scene_Item
  def main
    @help_window = Window_Help.new
    @item_window = Window_Item.new
    @item_window.help_window = @help_window
    @target_window = Window_Target.new
    @target_window.visible = false
    @target_window.active = false
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      if $scene != self
        break
      end
    end
    Graphics.freeze
    @help_window.dispose
    @item_window.dispose
    @target_window.dispose
  end
  def update
    @help_window.update
    @item_window.update
    @target_window.update
    if @item_window.active
      update_item
      return
    end
    if @target_window.active
      update_target
      return
    end
  end
  def update_item
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      $scene = Scene_Menu.new(0)
      return
    end
    if Input.trigger?(Input::C)
      @item = @item_window.item
      unless @item.is_a?(RPG::Item)
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      unless $game_party.item_can_use?(@item.id)
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      $game_system.se_play($data_system.decision_se)
      if @item.scope >= 3
        @item_window.active = false
        @target_window.x = (@item_window.index + 1) % 2 * 304
        @target_window.visible = true
        @target_window.active = true
        if @item.scope == 4 || @item.scope == 6
          @target_window.index = -1
        else
          @target_window.index = 0
        end
      else
        if @item.common_event_id > 0
          $game_temp.common_event_id = @item.common_event_id
          $game_system.se_play(@item.menu_se)
          if @item.consumable
            $game_party.lose_item(@item.id, 1)
            @item_window.draw_item(@item_window.index)
          end
          $scene = Scene_Map.new
          return
        end
      end
      return
    end
  end
  def update_target
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      unless $game_party.item_can_use?(@item.id)
        @item_window.refresh
      end
      @item_window.active = true
      @target_window.visible = false
      @target_window.active = false
      return
    end
    if Input.trigger?(Input::C)
      if $game_party.item_number(@item.id) == 0
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      if @target_window.index == -1
        used = false
        for i in $game_party.actors
          used |= i.item_effect(@item)
        end
      end
      if @target_window.index >= 0
        target = $game_party.actors[@target_window.index]
        used = target.item_effect(@item)
      end
      if used
        $game_system.se_play(@item.menu_se)
        if @item.consumable
          $game_party.lose_item(@item.id, 1)
          @item_window.draw_item(@item_window.index)
        end
        @target_window.refresh
        if $game_party.all_dead?
          $scene = Scene_Gameover.new
          return
        end
        if @item.common_event_id > 0
          $game_temp.common_event_id = @item.common_event_id
          $scene = Scene_Map.new
          return
        end
      end
      unless used
        $game_system.se_play($data_system.buzzer_se)
      end
      return
    end
  end
end