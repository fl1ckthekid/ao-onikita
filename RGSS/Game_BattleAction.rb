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
  end
  def valid?
    return false
  end
  def for_one_friend?
  end
  def for_one_friend_hp0?
  end
  def decide_random_target_for_actor
  end
  def decide_random_target_for_enemy
  end
  def decide_last_target_for_actor
  end
  def decide_last_target_for_enemy
  end
end