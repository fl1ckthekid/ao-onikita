class Scene_Battle
  def main
    $game_temp.in_battle = true
    $game_temp.battle_turn = 0
    $game_temp.battle_event_flags.clear
    $game_temp.battle_abort = false
    $game_temp.battle_main_phase = false
    $game_temp.battleback_name = $game_map.battleback_name
    $game_temp.forcing_battler = nil
    $game_system.battle_interpreter.setup(nil, 0)
    @troop_id = $game_temp.battle_troop_id
    $game_troop.setup(@troop_id)
    s1 = $data_system.words.attack
    s2 = $data_system.words.skill
    s3 = $data_system.words.guard
    s4 = $data_system.words.item
    @actor_command_window = Window_Command.new(160, [s1, s2, s3, s4])
    @actor_command_window.y = 160
    @actor_command_window.back_opacity = 160
    @actor_command_window.active = false
    @actor_command_window.visible = false
    @party_command_window = Window_PartyCommand.new
    @help_window = Window_Help.new
    @help_window.back_opacity = 160
    @help_window.visible = false
    @status_window = Window_BattleStatus.new
    @message_window = Window_Message.new
    @spriteset = Spriteset_Battle.new
    @wait_count = 0
    if $data_system.battle_transition == ""
      Graphics.transition(20)
    else
      Graphics.transition(40, "Graphics/Transitions/" + $data_system.battle_transition)
    end
    start_phase1
    loop do
      Graphics.update
      Input.update
      update
      if $scene != self
        break
      end
    end
    $game_map.refresh
    Graphics.freeze
    @actor_command_window.dispose
    @party_command_window.dispose
    @help_window.dispose
    @status_window.dispose
    @message_window.dispose
    if @skill_window != nil
      @skill_window.dispose
    end
    if @item_window != nil
      @item_window.dispose
    end
    if @result_window != nil
      @result_window.dispose
    end
    @spriteset.dispose
    if $scene.is_a?(Scene_Title)
      Graphics.transition
      Graphics.freeze
    end
    if $BTEST and not $scene.is_a?(Scene_Gameover)
      $scene = nil
    end
  end
  def judge
    if $game_party.all_dead? or $game_party.actors.size == 0
      if $game_temp.battle_can_lose
        $game_system.bgm_play($game_temp.map_bgm)
        battle_end(2)
        return true
      end
      $game_temp.gameover = true
      return true
    end
    for enemy in $game_troop.enemies
      if enemy.exist?
        return false
      end
    end
    start_phase5
    return true
  end
  def battle_end(result)
    $game_temp.in_battle = false
    $game_party.clear_actions
    for actor in $game_party.actors
      actor.remove_states_battle
    end
    $game_troop.enemies.clear
    if $game_temp.battle_proc != nil
      $game_temp.battle_proc.call(result)
      $game_temp.battle_proc = nil
    end
    $scene = Scene_Map.new
  end
  def setup_battle_event
    if $game_system.battle_interpreter.running?
      return
    end
    for index in 0...$data_troops[@troop_id].pages.size
      page = $data_troops[@troop_id].pages[index]
      c = page.condition
      unless c.turn_valid or c.enemy_valid or
             c.actor_valid or c.switch_valid
        next
      end
      if $game_temp.battle_event_flags[index]
        next
      end
      if c.turn_valid
        n = $game_temp.battle_turn
        a = c.turn_a
        b = c.turn_b
        if (b == 0 and n != a) or
           (b > 0 and (n < 1 or n < a or n % b != a % b))
          next
        end
      end
      if c.enemy_valid
        enemy = $game_troop.enemies[c.enemy_index]
        if enemy == nil or enemy.hp * 100.0 / enemy.maxhp > c.enemy_hp
          next
        end
      end
      if c.actor_valid
        actor = $game_actors[c.actor_id]
        if actor == nil or actor.hp * 100.0 / actor.maxhp > c.actor_hp
          next
        end
      end
      if c.switch_valid
        if $game_switches[c.switch_id] == false
          next
        end
      end
      $game_system.battle_interpreter.setup(page.list, 0)
      if page.span <= 1
        $game_temp.battle_event_flags[index] = true
      end
      return
    end
  end
  def update
    if $game_system.battle_interpreter.running?
      $game_system.battle_interpreter.update
      if $game_temp.forcing_battler == nil
        unless $game_system.battle_interpreter.running?
          unless judge
            setup_battle_event
          end
        end
        if @phase != 5
          @status_window.refresh
        end
      end
    end
    $game_system.update
    $game_screen.update
    if $game_system.timer_working and $game_system.timer == 0
      $game_temp.battle_abort = true
    end
    @help_window.update
    @party_command_window.update
    @actor_command_window.update
    @status_window.update
    @message_window.update
    @spriteset.update
    if $game_temp.transition_processing
      $game_temp.transition_processing = false
      if $game_temp.transition_name == ""
        Graphics.transition(20)
      else
        Graphics.transition(40, "Graphics/Transitions/" +
          $game_temp.transition_name)
      end
    end
    if $game_temp.message_window_showing
      return
    end
    if @spriteset.effect?
      return
    end
    if $game_temp.gameover
      $scene = Scene_Gameover.new
      return
    end
    if $game_temp.to_title
      $scene = Scene_Title.new
      return
    end
    if $game_temp.battle_abort
      $game_system.bgm_play($game_temp.map_bgm)
      battle_end(1)
      return
    end
    if @wait_count > 0
      @wait_count -= 1
      return
    end
    if $game_temp.forcing_battler == nil and
       $game_system.battle_interpreter.running?
      return
    end
    case @phase
    when 1
      update_phase1
    when 2
      update_phase2
    when 3
      update_phase3
    when 4
      update_phase4
    when 5
      update_phase5
    end
  end
end