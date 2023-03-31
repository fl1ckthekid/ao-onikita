class Game_BattleAction
  attr_accessor:speed                    
  attr_accessor:kind                     
  attr_accessor:basic                    
  attr_accessor:skill_id                 
  attr_accessor:item_id                  
  attr_accessor:target_index             
  attr_accessor:forcing                  

  def initialize
    clear
  end

  def clear
    @speed = 0
    @kind = 0
    @basic = 3
    @skill_id = 0
    @item_id = 0
    @target_index = -1
    @forcing = false
  end
  
  def valid?
    return (not (@kind == 0 and @basic == 3))
  end

  def for_one_friend?
    if @kind == 1 and [3, 5].include?($data_skills[@skill_id].scope)
      return true
    end
    if @kind == 2 and [3, 5].include?($data_items[@item_id].scope)
      return true
    end
    return false
  end

  def for_one_friend_hp0?
    if @kind == 1 and [5].include?($data_skills[@skill_id].scope)
      return true
    end
    if @kind == 2 and [5].include?($data_items[@item_id].scope)
      return true
    end
    return false
  end

  def decide_random_target_for_actor
    if for_one_friend_hp0?
      battler = $game_party.random_target_actor_hp0
    elsif for_one_friend?
      battler = $game_party.random_target_actor
    else
      battler = $game_troop.random_target_enemy
    end
    if battler != nil
      @target_index = battler.index
    else
      clear
    end
  end

  def decide_random_target_for_enemy
    if for_one_friend_hp0?
      battler = $game_troop.random_target_enemy_hp0
    elsif for_one_friend?
      battler = $game_troop.random_target_enemy
    else
      battler = $game_party.random_target_actor
    end
    if battler != nil
      @target_index = battler.index
    else
      clear
    end
  end

  def decide_last_target_for_actor
    if @target_index == -1
      battler = nil
    elsif for_one_friend?
      battler = $game_party.actors[@target_index]
    else
      battler = $game_troop.enemies[@target_index]
    end
    if battler == nil or not battler.exist?
      clear
    end
  end

  def decide_last_target_for_enemy
    if @target_index == -1
      battler = nil
    elsif for_one_friend?
      battler = $game_troop.enemies[@target_index]
    else
      battler = $game_party.actors[@target_index]
    end
    if battler == nil or not battler.exist?
      clear
    end
  end
end