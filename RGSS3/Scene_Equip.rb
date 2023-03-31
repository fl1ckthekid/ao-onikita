class Scene_Equip
  def initialize(actor_index = 0, equip_index = 0)
    @actor_index = actor_index
    @equip_index = equip_index
  end
  def main
    @actor = $game_party.actors[@actor_index]
    @help_window = Window_Help.new
    @left_window = Window_EquipLeft.new(@actor)
    @right_window = Window_EquipRight.new(@actor)
    @item_window1 = Window_EquipItem.new(@actor, 0)
    @item_window2 = Window_EquipItem.new(@actor, 1)
    @item_window3 = Window_EquipItem.new(@actor, 2)
    @item_window4 = Window_EquipItem.new(@actor, 3)
    @item_window5 = Window_EquipItem.new(@actor, 4)
    @right_window.help_window = @help_window
    @item_window1.help_window = @help_window
    @item_window2.help_window = @help_window
    @item_window3.help_window = @help_window
    @item_window4.help_window = @help_window
    @item_window5.help_window = @help_window
    @right_window.index = @equip_index
    refresh
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
    @left_window.dispose
    @right_window.dispose
    @item_window1.dispose
    @item_window2.dispose
    @item_window3.dispose
    @item_window4.dispose
    @item_window5.dispose
  end
  def refresh
    @item_window1.visible = (@right_window.index == 0)
    @item_window2.visible = (@right_window.index == 1)
    @item_window3.visible = (@right_window.index == 2)
    @item_window4.visible = (@right_window.index == 3)
    @item_window5.visible = (@right_window.index == 4)
    item1 = @right_window.item
    case @right_window.index
    when 0
      @item_window = @item_window1
    when 1
      @item_window = @item_window2
    when 2
      @item_window = @item_window3
    when 3
      @item_window = @item_window4
    when 4
      @item_window = @item_window5
    end
    if @right_window.active
      @left_window.set_new_parameters(nil, nil, nil)
    end
    if @item_window.active
      item2 = @item_window.item
      last_hp = @actor.hp
      last_sp = @actor.sp
      @actor.equip(@right_window.index, item2 == nil ? 0 : item2.id)
      new_atk = @actor.atk
      new_pdef = @actor.pdef
      new_mdef = @actor.mdef
      @actor.equip(@right_window.index, item1 == nil ? 0 : item1.id)
      @actor.hp = last_hp
      @actor.sp = last_sp
      @left_window.set_new_parameters(new_atk, new_pdef, new_mdef)
    end
  end
  def update
    @left_window.update
    @right_window.update
    @item_window.update
    refresh
    if @right_window.active
      update_right
      return
    end
    if @item_window.active
      update_item
      return
    end
  end
  def update_right
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      $scene = Scene_Menu.new(2)
      return
    end
    if Input.trigger?(Input::C)
      if @actor.equip_fix?(@right_window.index)
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      $game_system.se_play($data_system.decision_se)
      @right_window.active = false
      @item_window.active = true
      @item_window.index = 0
      return
    end
    if Input.trigger?(Input::R)
      $game_system.se_play($data_system.cursor_se)
      @actor_index += 1
      @actor_index %= $game_party.actors.size
      $scene = Scene_Equip.new(@actor_index, @right_window.index)
      return
    end
    if Input.trigger?(Input::L)
      $game_system.se_play($data_system.cursor_se)
      @actor_index += $game_party.actors.size - 1
      @actor_index %= $game_party.actors.size
      $scene = Scene_Equip.new(@actor_index, @right_window.index)
      return
    end
  end
  def update_item
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      @right_window.active = true
      @item_window.active = false
      @item_window.index = -1
      return
    end
    if Input.trigger?(Input::C)
      $game_system.se_play($data_system.equip_se)
      item = @item_window.item
      @actor.equip(@right_window.index, item == nil ? 0 : item.id)
      @right_window.active = true
      @item_window.active = false
      @item_window.index = -1
      @right_window.refresh
      @item_window.refresh
      return
    end
  end
end