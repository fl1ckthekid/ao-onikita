class Game_Party
  attr_reader:actors                   
  attr_reader:gold                     
  attr_reader:steps                    

  def initialize
    @actors = []
    @gold = 0
    @steps = 0
    @items = {}
    @weapons = {}
    @armors = {}
  end

  def setup_starting_members
    @actors = []
    for i in $data_system.party_members
      @actors.push($game_actors[i])
    end
  end

  def setup_battle_test_members
    @actors = []
    for battler in $data_system.test_battlers
      actor = $game_actors[battler.actor_id]
      actor.level = battler.level
      gain_weapon(battler.weapon_id, 1)
      gain_armor(battler.armor1_id, 1)
      gain_armor(battler.armor2_id, 1)
      gain_armor(battler.armor3_id, 1)
      gain_armor(battler.armor4_id, 1)
      actor.equip(0, battler.weapon_id)
      actor.equip(1, battler.armor1_id)
      actor.equip(2, battler.armor2_id)
      actor.equip(3, battler.armor3_id)
      actor.equip(4, battler.armor4_id)
      actor.recover_all
      @actors.push(actor)
    end

    @items = {}
    for i in 1...$data_items.size
      if $data_items[i].name != ""
        occasion = $data_items[i].occasion
        if occasion == 0 or occasion == 1
          @items[i] = 99
        end
      end
    end
  end

  def refresh
    new_actors = []
    for i in 0...@actors.size
      if $data_actors[@actors[i].id] != nil
        new_actors.push($game_actors[@actors[i].id])
      end
    end
    @actors = new_actors
  end

  def max_level
    if @actors.size == 0
      return 0
    end
    level = 0
    for actor in @actors
      if level < actor.level
        level = actor.level
      end
    end
    return level
  end

  def add_actor(actor_id)
    actor = $game_actors[actor_id]
    if @actors.size < 4 and not @actors.include?(actor)
      @actors.push(actor)
      $game_player.refresh
    end
  end

  def remove_actor(actor_id)
    @actors.delete($game_actors[actor_id])
    $game_player.refresh
  end

  def gain_gold(n)
    @gold = [[@gold + n, 0].max, 9999999].min
  end

  def lose_gold(n)
    gain_gold(-n)
  end

  def increase_steps
    @steps = [@steps + 1, 9999999].min
  end

  def item_number(item_id)
    return @items.include?(item_id) ? @items[item_id] : 0
  end

  def weapon_number(weapon_id)
    return @weapons.include?(weapon_id) ? @weapons[weapon_id] : 0
  end

  def armor_number(armor_id)
    return @armors.include?(armor_id) ? @armors[armor_id] : 0
  end

  def gain_item(item_id, n)
    if item_id > 0
      @items[item_id] = [[item_number(item_id) + n, 0].max, 99].min
    end
  end

  def gain_weapon(weapon_id, n)
    if weapon_id > 0
      @weapons[weapon_id] = [[weapon_number(weapon_id) + n, 0].max, 99].min
    end
  end

  def gain_armor(armor_id, n)
    if armor_id > 0
      @armors[armor_id] = [[armor_number(armor_id) + n, 0].max, 99].min
    end
  end

  def lose_item(item_id, n)
    gain_item(item_id, -n)
  end

  def lose_weapon(weapon_id, n)
    gain_weapon(weapon_id, -n)
  end

  def lose_armor(armor_id, n)
    gain_armor(armor_id, -n)
  end

  def item_can_use?(item_id)
    if item_number(item_id) == 0
      return false
    end
    
    occasion = $data_items[item_id].occasion
    if $game_temp.in_battle
      return (occasion == 0 or occasion == 1)
    end
    
    return (occasion == 0 or occasion == 2)
  end

  def clear_actions
    for actor in @actors
      actor.current_action.clear
    end
  end

  def inputable?
    for actor in @actors
      if actor.inputable?
        return true
      end
    end
    return false
  end

  def all_dead?
    if $game_party.actors.size == 0
      return false
    end
    for actor in @actors
      if actor.hp > 0
        return false
      end
    end
    return true
  end

  def check_map_slip_damage
    for actor in @actors
      if actor.hp > 0 and actor.slip_damage?
        actor.hp -= [actor.maxhp / 100, 1].max
        if actor.hp == 0
          $game_system.se_play($data_system.actor_collapse_se)
        end
        $game_screen.start_flash(Color.new(255,0,0,128), 4)
        $game_temp.gameover = $game_party.all_dead?
      end
    end
  end

  def random_target_actor(hp0 = false)
    roulette = []
    for actor in @actors
      if (not hp0 and actor.exist?) or (hp0 and actor.hp0?)
        position = $data_classes[actor.class_id].position
        n = 4 - position
        n.times do
          roulette.push(actor)
        end
      end
    end
    if roulette.size == 0
      return nil
    end
    return roulette[rand(roulette.size)]
  end

  def random_target_actor_hp0
    return random_target_actor(true)
  end

  def smooth_target_actor(actor_index)
    actor = @actors[actor_index]
    if actor != nil and actor.exist?
      return actor
    end
    for actor in @actors
      if actor.exist?
        return actor
      end
    end
  end
end