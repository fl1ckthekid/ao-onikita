class Game_Troop

  def initialize
    @enemies = []
  end

  def enemies
    return @enemies
  end

  def setup(troop_id)
    @enemies = []
    troop = $data_troops[troop_id]
    for i in 0...troop.members.size
      enemy = $data_enemies[troop.members[i].enemy_id]
      if enemy != nil
        @enemies.push(Game_Enemy.new(troop_id, i))
      end
    end
  end

  def random_target_enemy(hp0 = false)
    roulette = []
    for enemy in @enemies
      if (not hp0 and enemy.exist?) or (hp0 and enemy.hp0?)
        roulette.push(enemy)
      end
    end
    if roulette.size == 0
      return nil
    end
    return roulette[rand(roulette.size)]
  end

  def random_target_enemy_hp0
    return random_target_enemy(true)
  end

  def smooth_target_enemy(enemy_index)
    enemy = @enemies[enemy_index]
    if enemy != nil and enemy.exist?
      return enemy
    end
    for enemy in @enemies
      if enemy.exist?
        return enemy
      end
    end
  end
end