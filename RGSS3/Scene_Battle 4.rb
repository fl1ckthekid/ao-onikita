class Scene_Battle
  def start_phase4
    @phase = 4
    $game_temp.battle_turn += 1
    for index in 0...$data_troops[@troop_id].pages.size
      page = $data_troops[@troop_id].pages[index]
      if page.span == 1
        $game_temp.battle_event_flags[index] = false
      end
    end
    @actor_index = -1
    @active_battler = nil
    @party_command_window.active = false
    @party_command_window.visible = false
    @actor_command_window.active = false
    @actor_command_window.visible = false
    $game_temp.battle_main_phase = true
    for enemy in $game_troop.enemies
      enemy.make_action
    end
    make_action_orders
    @phase4_step = 1
  end
  def make_action_orders
    @action_battlers = []
    for enemy in $game_troop.enemies
      @action_battlers.push(enemy)
    end
    for actor in $game_party.actors
      @action_battlers.push(actor)
    end
    for battler in @action_battlers
      battler.make_action_speed
    end
    @action_battlers.sort! {|a,b|
      b.current_action.speed - a.current_action.speed }
  end
  def update_phase4
    case @phase4_step
    when 1
      update_phase4_step1
    when 2
      update_phase4_step2
    when 3
      update_phase4_step3
    when 4
      update_phase4_step4
    when 5
      update_phase4_step5
    when 6
      update_phase4_step6
    end
  end
  def update_phase4_step1
    @help_window.visible = false
    if judge
      return
    end
    if $game_temp.forcing_battler == nil
      setup_battle_event
      if $game_system.battle_interpreter.running?
        return
      end
    end
    if $game_temp.forcing_battler != nil
      @action_battlers.delete($game_temp.forcing_battler)
      @action_battlers.unshift($game_temp.forcing_battler)
    end
    if @action_battlers.size == 0
      start_phase2
      return
    end
    @animation1_id = 0
    @animation2_id = 0
    @common_event_id = 0
    @active_battler = @action_battlers.shift
    if @active_battler.index == nil
      return
    end
    if @active_battler.hp > 0 and @active_battler.slip_damage?
      @active_battler.slip_damage_effect
      @active_battler.damage_pop = true
    end
    @active_battler.remove_states_auto
    @status_window.refresh
    @phase4_step = 2
  end
  def update_phase4_step2
    unless @active_battler.current_action.forcing
      if @active_battler.restriction == 2 or @active_battler.restriction == 3
        @active_battler.current_action.kind = 0
        @active_battler.current_action.basic = 0
      end
      if @active_battler.restriction == 4
        $game_temp.forcing_battler = nil
        @phase4_step = 1
        return
      end
    end
    @target_battlers = []
    case @active_battler.current_action.kind
    when 0
      make_basic_action_result
    when 1
      make_skill_action_result
    when 2
      make_item_action_result
    end
    if @phase4_step == 2
      @phase4_step = 3
    end
  end
  def make_basic_action_result
    if @active_battler.current_action.basic == 0
      @animation1_id = @active_battler.animation1_id
      @animation2_id = @active_battler.animation2_id
      if @active_battler.is_a?(Game_Enemy)
        if @active_battler.restriction == 3
          target = $game_troop.random_target_enemy
        elsif @active_battler.restriction == 2
          target = $game_party.random_target_actor
        else
          index = @active_battler.current_action.target_index
          target = $game_party.smooth_target_actor(index)
        end
      end
      if @active_battler.is_a?(Game_Actor)
        if @active_battler.restriction == 3
          target = $game_party.random_target_actor
        elsif @active_battler.restriction == 2
          target = $game_troop.random_target_enemy
        else
          index = @active_battler.current_action.target_index
          target = $game_troop.smooth_target_enemy(index)
        end
      end
      @target_battlers = [target]
      for target in @target_battlers
        target.attack_effect(@active_battler)
      end
      return
    end
    if @active_battler.current_action.basic == 1
      @help_window.set_text($data_system.words.guard, 1)
      return
    end
    if @active_battler.is_a?(Game_Enemy) and
       @active_battler.current_action.basic == 2
      @help_window.set_text("逃げる", 1)
      @active_battler.escape
      return
    end
    if @active_battler.current_action.basic == 3
      $game_temp.forcing_battler = nil
      @phase4_step = 1
      return
    end
  end
  def set_target_battlers(scope)
    if @active_battler.is_a?(Game_Enemy)
      case scope
      when 1
        index = @active_battler.current_action.target_index
        @target_battlers.push($game_party.smooth_target_actor(index))
      when 2
        for actor in $game_party.actors
          if actor.exist?
            @target_battlers.push(actor)
          end
        end
      when 3
        index = @active_battler.current_action.target_index
        @target_battlers.push($game_troop.smooth_target_enemy(index))
      when 4
        for enemy in $game_troop.enemies
          if enemy.exist?
            @target_battlers.push(enemy)
          end
        end
      when 5
        index = @active_battler.current_action.target_index
        enemy = $game_troop.enemies[index]
        if enemy != nil and enemy.hp0?
          @target_battlers.push(enemy)
        end
      when 6
        for enemy in $game_troop.enemies
          if enemy != nil and enemy.hp0?
            @target_battlers.push(enemy)
          end
        end
      when 7
        @target_battlers.push(@active_battler)
      end
    end
    if @active_battler.is_a?(Game_Actor)
      case scope
      when 1
        index = @active_battler.current_action.target_index
        @target_battlers.push($game_troop.smooth_target_enemy(index))
      when 2
        for enemy in $game_troop.enemies
          if enemy.exist?
            @target_battlers.push(enemy)
          end
        end
      when 3
        index = @active_battler.current_action.target_index
        @target_battlers.push($game_party.smooth_target_actor(index))
      when 4
        for actor in $game_party.actors
          if actor.exist?
            @target_battlers.push(actor)
          end
        end
      when 5
        index = @active_battler.current_action.target_index
        actor = $game_party.actors[index]
        if actor != nil and actor.hp0?
          @target_battlers.push(actor)
        end
      when 6
        for actor in $game_party.actors
          if actor != nil and actor.hp0?
            @target_battlers.push(actor)
          end
        end
      when 7
        @target_battlers.push(@active_battler)
      end
    end
  end
  def make_skill_action_result
    @skill = $data_skills[@active_battler.current_action.skill_id]
    unless @active_battler.current_action.forcing
      unless @active_battler.skill_can_use?(@skill.id)
        $game_temp.forcing_battler = nil
        @phase4_step = 1
        return
      end
    end
    @active_battler.sp -= @skill.sp_cost
    @status_window.refresh
    @help_window.set_text(@skill.name, 1)
    @animation1_id = @skill.animation1_id
    @animation2_id = @skill.animation2_id
    @common_event_id = @skill.common_event_id
    set_target_battlers(@skill.scope)
    for target in @target_battlers
      target.skill_effect(@active_battler, @skill)
    end
  end
  def make_item_action_result
    @item = $data_items[@active_battler.current_action.item_id]
    unless $game_party.item_can_use?(@item.id)
      @phase4_step = 1
      return
    end
    if @item.consumable
      $game_party.lose_item(@item.id, 1)
    end
    @help_window.set_text(@item.name, 1)
    @animation1_id = @item.animation1_id
    @animation2_id = @item.animation2_id
    @common_event_id = @item.common_event_id
    index = @active_battler.current_action.target_index
    target = $game_party.smooth_target_actor(index)
    set_target_battlers(@item.scope)
    for target in @target_battlers
      target.item_effect(@item)
    end
  end
  def update_phase4_step3
    if @animation1_id == 0
      @active_battler.white_flash = true
    else
      @active_battler.animation_id = @animation1_id
      @active_battler.animation_hit = true
    end
    @phase4_step = 4
  end
  def update_phase4_step4
    for target in @target_battlers
      target.animation_id = @animation2_id
      target.animation_hit = (target.damage != "Miss")
    end
    @wait_count = 8
    @phase4_step = 5
  end
  def update_phase4_step5
    @help_window.visible = false
    @status_window.refresh
    for target in @target_battlers
      if target.damage != nil
        target.damage_pop = true
      end
    end
    @phase4_step = 6
  end
  def update_phase4_step6
    $game_temp.forcing_battler = nil
    if @common_event_id > 0
      common_event = $data_common_events[@common_event_id]
      $game_system.battle_interpreter.setup(common_event.list, 0)
    end
    @phase4_step = 1
  end
end