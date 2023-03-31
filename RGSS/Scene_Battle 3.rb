class Scene_Battle
  def start_phase3
    @phase = 3
    @actor_index = -1
    @active_battler = nil
    phase3_next_actor
  end
  def phase3_next_actor
    begin
      if @active_battler != nil
        @active_battler.blink = false
      end
      if @actor_index == $game_party.actors.size-1
        start_phase4
        return
      end
      @actor_index += 1
      @active_battler = $game_party.actors[@actor_index]
      @active_battler.blink = true
    end until @active_battler.inputable?
    phase3_setup_command_window
  end
  def phase3_prior_actor
    begin
      if @active_battler != nil
        @active_battler.blink = false
      end
      if @actor_index == 0
        start_phase2
        return
      end
      @actor_index -= 1
      @active_battler = $game_party.actors[@actor_index]
      @active_battler.blink = true
    end until @active_battler.inputable?
    phase3_setup_command_window
  end
  def phase3_setup_command_window
    @party_command_window.active = false
    @party_command_window.visible = false
    @actor_command_window.active = true
    @actor_command_window.visible = true
    @actor_command_window.x = @actor_index * 160
    @actor_command_window.index = 0
  end
  def update_phase3
    if @enemy_arrow != nil
      update_phase3_enemy_select
    elsif @actor_arrow != nil
      update_phase3_actor_select
    elsif @skill_window != nil
      update_phase3_skill_select
    elsif @item_window != nil
      update_phase3_item_select
    elsif @actor_command_window.active
      update_phase3_basic_command
    end
  end
  def update_phase3_basic_command
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      phase3_prior_actor
      return
    end
    if Input.trigger?(Input::C)
      case @actor_command_window.index
      when 0
        $game_system.se_play($data_system.decision_se)
        @active_battler.current_action.kind = 0
        @active_battler.current_action.basic = 0
        start_enemy_select
      when 1
        $game_system.se_play($data_system.decision_se)
        @active_battler.current_action.kind = 1
        start_skill_select
      when 2
        $game_system.se_play($data_system.decision_se)
        @active_battler.current_action.kind = 0
        @active_battler.current_action.basic = 1
        phase3_next_actor
      when 3
        $game_system.se_play($data_system.decision_se)
        @active_battler.current_action.kind = 2
        start_item_select
      end
      return
    end
  end
  def update_phase3_skill_select
    @skill_window.visible = true
    @skill_window.update
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      end_skill_select
      return
    end
    if Input.trigger?(Input::C)
      @skill = @skill_window.skill
      if @skill == nil or not @active_battler.skill_can_use?(@skill.id)
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      $game_system.se_play($data_system.decision_se)
      @active_battler.current_action.skill_id = @skill.id
      @skill_window.visible = false
      if @skill.scope == 1
        start_enemy_select
      elsif @skill.scope == 3 or @skill.scope == 5
        start_actor_select
      else
        end_skill_select
        phase3_next_actor
      end
      return
    end
  end
  def update_phase3_item_select
    @item_window.visible = true
    @item_window.update
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      end_item_select
      return
    end
    if Input.trigger?(Input::C)
      @item = @item_window.item
      unless $game_party.item_can_use?(@item.id)
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      $game_system.se_play($data_system.decision_se)
      @active_battler.current_action.item_id = @item.id
      @item_window.visible = false
      if @item.scope == 1
        start_enemy_select
      elsif @item.scope == 3 or @item.scope == 5
        start_actor_select
      else
        end_item_select
        phase3_next_actor
      end
      return
    end
  end
  def update_phase3_enemy_select
    @enemy_arrow.update
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      end_enemy_select
      return
    end
    if Input.trigger?(Input::C)
      $game_system.se_play($data_system.decision_se)
      @active_battler.current_action.target_index = @enemy_arrow.index
      end_enemy_select
      if @skill_window != nil
        end_skill_select
      end
      if @item_window != nil
        end_item_select
      end
      phase3_next_actor
    end
  end
  def update_phase3_actor_select
    @actor_arrow.update
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      end_actor_select
      return
    end
    if Input.trigger?(Input::C)
      $game_system.se_play($data_system.decision_se)
      @active_battler.current_action.target_index = @actor_arrow.index
      end_actor_select
      if @skill_window != nil
        end_skill_select
      end
      if @item_window != nil
        end_item_select
      end
      phase3_next_actor
    end
  end
  def start_enemy_select
    @enemy_arrow = Arrow_Enemy.new(@spriteset.viewport1)
    @enemy_arrow.help_window = @help_window
    @actor_command_window.active = false
    @actor_command_window.visible = false
  end
  def end_enemy_select
    @enemy_arrow.dispose
    @enemy_arrow = nil
    if @actor_command_window.index == 0
      @actor_command_window.active = true
      @actor_command_window.visible = true
      @help_window.visible = false
    end
  end
  def start_actor_select
    @actor_arrow = Arrow_Actor.new(@spriteset.viewport2)
    @actor_arrow.index = @actor_index
    @actor_arrow.help_window = @help_window
    @actor_command_window.active = false
    @actor_command_window.visible = false
  end
  def end_actor_select
    @actor_arrow.dispose
    @actor_arrow = nil
  end
  def start_skill_select
    @skill_window = Window_Skill.new(@active_battler)
    @skill_window.help_window = @help_window
    @actor_command_window.active = false
    @actor_command_window.visible = false
  end
  def end_skill_select
    @skill_window.dispose
    @skill_window = nil
    @help_window.visible = false
    @actor_command_window.active = true
    @actor_command_window.visible = true
  end
  def start_item_select
    @item_window = Window_Item.new
    @item_window.help_window = @help_window
    @actor_command_window.active = false
    @actor_command_window.visible = false
  end
  def end_item_select
    @item_window.dispose
    @item_window = nil
    @help_window.visible = false
    @actor_command_window.active = true
    @actor_command_window.visible = true
  end
end