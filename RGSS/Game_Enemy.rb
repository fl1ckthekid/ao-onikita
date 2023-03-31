class Game_Enemy < Game_Battler
  
  def initialize(troop_id, member_index)
    super()
    @troop_id = troop_id
    @member_index = member_index
    troop = $data_troops[@troop_id]
    @enemy_id = troop.members[@member_index].enemy_id
    enemy = $data_enemies[@enemy_id]
    @battler_name = enemy.battler_name
    @battler_hue = enemy.battler_hue
    @hp = maxhp
    @sp = maxsp
    @hidden = troop.members[@member_index].hidden
    @immortal = troop.members[@member_index].immortal
  end

  def id
    return @enemy_id
  end

  def index
    return @member_index
  end

  def name
    return $data_enemies[@enemy_id].name
  end

  def base_maxhp
    return $data_enemies[@enemy_id].maxhp
  end

  def base_maxsp
    return $data_enemies[@enemy_id].maxsp
  end

  def base_str
    return $data_enemies[@enemy_id].str
  end

  def base_dex
    return $data_enemies[@enemy_id].dex
  end

  def base_agi
    return $data_enemies[@enemy_id].agi
  end

  def base_int
    return $data_enemies[@enemy_id].int
  end

  def base_atk
    return $data_enemies[@enemy_id].atk
  end

  def base_pdef
    return $data_enemies[@enemy_id].pdef
  end

  def base_mdef
    return $data_enemies[@enemy_id].mdef
  end

  def base_eva
    return $data_enemies[@enemy_id].eva
  end

  def animation1_id
    return $data_enemies[@enemy_id].animation1_id
  end

  def animation2_id
    return $data_enemies[@enemy_id].animation2_id
  end

  def element_rate(element_id)
    table = [0, 200, 150, 100, 50, 0, -100]
    result = table[$data_enemies[@enemy_id].element_ranks[element_id]]
    for i in @states
      if $data_states[i].guard_element_set.include?(element_id)
        result /= 2
      end
    end
    return result
  end

  def state_ranks
    return $data_enemies[@enemy_id].state_ranks
  end

  def state_guard?(state_id)
    return false
  end

  def element_set
    return []
  end

  def plus_state_set
    return []
  end

  def minus_state_set
    return []
  end

  def actions
    return $data_enemies[@enemy_id].actions
  end

  def exp
    return $data_enemies[@enemy_id].exp
  end

  def gold
    return $data_enemies[@enemy_id].gold
  end

  def item_id
    return $data_enemies[@enemy_id].item_id
  end

  def weapon_id
    return $data_enemies[@enemy_id].weapon_id
  end

  def armor_id
    return $data_enemies[@enemy_id].armor_id
  end

  def treasure_prob
    return $data_enemies[@enemy_id].treasure_prob
  end

  def screen_x
    return $data_troops[@troop_id].members[@member_index].x
  end

  def screen_y
    return $data_troops[@troop_id].members[@member_index].y
  end

  def screen_z
    return screen_y
  end

  def escape
    @hidden = true
    self.current_action.clear
  end

  def transform(enemy_id)
    @enemy_id = enemy_id
    @battler_name = $data_enemies[@enemy_id].battler_name
    @battler_hue = $data_enemies[@enemy_id].battler_hue
    make_action
  end

  def make_action
    self.current_action.clear
    unless self.movable?
      return
    end
    
    available_actions = []
    rating_max = 0
    for action in self.actions
      n = $game_temp.battle_turn
      a = action.condition_turn_a
      b = action.condition_turn_b
      if (b == 0 and n != a) or
          (b > 0 and (n < 1 or n < a or n % b != a % b))
        next
      end
      
      if self.hp * 100.0 / self.maxhp > action.condition_hp
        next
      end
      
      if $game_party.max_level < action.condition_level
        next
      end
      
      switch_id = action.condition_switch_id
      if switch_id > 0 and $game_switches[switch_id] == false
        next
      end
      
      available_actions.push(action)
      if action.rating > rating_max
        rating_max = action.rating
      end
    end
    
    ratings_total = 0
    for action in available_actions
      if action.rating > rating_max - 3
        ratings_total += action.rating - (rating_max - 3)
      end
    end
    
    if ratings_total > 0
      value = rand(ratings_total)
      for action in available_actions
        if action.rating > rating_max - 3
          if value < action.rating - (rating_max - 3)
            self.current_action.kind = action.kind
            self.current_action.basic = action.basic
            self.current_action.skill_id = action.skill_id
            self.current_action.decide_random_target_for_enemy
            return
          else
            value -= action.rating - (rating_max - 3)
          end
        end
      end
    end
  end
end