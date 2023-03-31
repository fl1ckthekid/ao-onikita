class Scene_Battle
  def start_phase1
    @phase = 1
    $game_party.clear_actions
    setup_battle_event
  end
  def update_phase1
    if judge
      return
    end
    start_phase2
  end
  def start_phase2
    @phase = 2
    @actor_index = -1
    @active_battler = nil
    @party_command_window.active = true
    @party_command_window.visible = true
    @actor_command_window.active = false
    @actor_command_window.visible = false
    $game_temp.battle_main_phase = false
    $game_party.clear_actions
    unless $game_party.inputable?
      start_phase4
    end
  end
  def update_phase2
    if Input.trigger?(Input::C)
      case @party_command_window.index
      when 0
        $game_system.se_play($data_system.decision_se)
        start_phase3
      when 1
        if $game_temp.battle_can_escape == false
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        $game_system.se_play($data_system.decision_se)
        update_phase2_escape
      end
      return
    end
  end
  def update_phase2_escape
    enemies_agi = 0
    enemies_number = 0
    for enemy in $game_troop.enemies
      if enemy.exist?
        enemies_agi += enemy.agi
        enemies_number += 1
      end
    end
    if enemies_number > 0
      enemies_agi /= enemies_number
    end
    actors_agi = 0
    actors_number = 0
    for actor in $game_party.actors
      if actor.exist?
        actors_agi += actor.agi
        actors_number += 1
      end
    end
    if actors_number > 0
      actors_agi /= actors_number
    end
    success = rand(100) < 50 * actors_agi / enemies_agi
    if success
      $game_system.se_play($data_system.escape_se)
      $game_system.bgm_play($game_temp.map_bgm)
      battle_end(1)
    else
      $game_party.clear_actions
      start_phase4
    end
  end
  def start_phase5
    @phase = 5
    $game_system.me_play($game_system.battle_end_me)
    $game_system.bgm_play($game_temp.map_bgm)
    exp = 0
    gold = 0
    treasures = []
    for enemy in $game_troop.enemies
      unless enemy.hidden
        exp += enemy.exp
        gold += enemy.gold
        if rand(100) < enemy.treasure_prob
          if enemy.item_id > 0
            treasures.push($data_items[enemy.item_id])
          end
          if enemy.weapon_id > 0
            treasures.push($data_weapons[enemy.weapon_id])
          end
          if enemy.armor_id > 0
            treasures.push($data_armors[enemy.armor_id])
          end
        end
      end
    end
    treasures = treasures[0..5]
    for i in 0...$game_party.actors.size
      actor = $game_party.actors[i]
      if actor.cant_get_exp? == false
        last_level = actor.level
        actor.exp += exp
        if actor.level > last_level
          @status_window.level_up(i)
        end
      end
    end
    $game_party.gain_gold(gold)
    for item in treasures
      case item
      when RPG::Item
        $game_party.gain_item(item.id, 1)
      when RPG::Weapon
        $game_party.gain_weapon(item.id, 1)
      when RPG::Armor
        $game_party.gain_armor(item.id, 1)
      end
    end
    @result_window = Window_BattleResult.new(exp, gold, treasures)
    @phase5_wait_count = 100
  end
  def update_phase5
    if @phase5_wait_count > 0
      @phase5_wait_count -= 1
      if @phase5_wait_count == 0
        @result_window.visible = true
        $game_temp.battle_main_phase = false
        @status_window.refresh
      end
      return
    end
    if Input.trigger?(Input::C)
      battle_end(0)
    end
  end
end