class Game_Battler
  def skill_can_use?(skill_id)
    if $data_skills[skill_id].sp_cost > self.sp
      return false
    end
    if dead?
      return false
    end
    if $data_skills[skill_id].atk_f == 0 and self.restriction == 1
      return false
    end
    occasion = $data_skills[skill_id].occasion
    if $game_temp.in_battle
      return (occasion == 0 or occasion == 1)
    else
      return (occasion == 0 or occasion == 2)
    end
  end

  def attack_effect(attacker)
    self.critical = false
    hit_result = (rand(100) < attacker.hit)
    if hit_result == true
      atk = [attacker.atk - self.pdef / 2, 0].max
      self.damage = atk * (20 + attacker.str) / 20
      self.damage *= elements_correct(attacker.element_set)
      self.damage /= 100
      if self.damage > 0
        if rand(100) < 4 * attacker.dex / self.agi
          self.damage *= 2
          self.critical = true
        end
        if self.guarding?
          self.damage /= 2
        end
      end
      if self.damage.abs > 0
        amp = [self.damage.abs * 15 / 100, 1].max
        self.damage += rand(amp+1) + rand(amp+1) - amp
      end
      eva = 8 * self.agi / attacker.dex + self.eva
      hit = self.damage < 0 ? 100 : 100 - eva
      hit = self.cant_evade? ? 100 : hit
      hit_result = (rand(100) < hit)
    end
    if hit_result == true
      remove_states_shock
      self.hp -= self.damage
      @state_changed = false
      states_plus(attacker.plus_state_set)
      states_minus(attacker.minus_state_set)
    else
      self.damage = "Miss"
      self.critical = false
    end
    return true
  end

  def skill_effect(user, skill)
    self.critical = false
    if ((skill.scope == 3 or skill.scope == 4) and self.hp == 0) or
        ((skill.scope == 5 or skill.scope == 6) and self.hp >= 1)
      return false
    end
    
    effective = false
    effective |= skill.common_event_id > 0
    
    hit = skill.hit
    if skill.atk_f > 0
      hit *= user.hit / 100
    end
    hit_result = (rand(100) < hit)
    
    effective |= hit < 100
    if hit_result == true
      power = skill.power + user.atk * skill.atk_f / 100
      if power > 0
        power -= self.pdef * skill.pdef_f / 200
        power -= self.mdef * skill.mdef_f / 200
        power = [power, 0].max
      end
      
      rate = 20
      rate += (user.str * skill.str_f / 100)
      rate += (user.dex * skill.dex_f / 100)
      rate += (user.agi * skill.agi_f / 100)
      rate += (user.int * skill.int_f / 100)
      
      self.damage = power * rate / 20
      self.damage *= elements_correct(skill.element_set)
      self.damage /= 100
      if self.damage > 0
        if self.guarding?
          self.damage /= 2
        end
      end
      
      if skill.variance > 0 and self.damage.abs > 0
        amp = [self.damage.abs * skill.variance / 100, 1].max
        self.damage += rand(amp+1) + rand(amp+1) - amp
      end
      
      eva = 8 * self.agi / user.dex + self.eva
      hit = self.damage < 0 ? 100 : 100 - eva * skill.eva_f / 100
      hit = self.cant_evade? ? 100 : hit
      hit_result = (rand(100) < hit)
      
      effective |= hit < 100
    end
    
    if hit_result == true
      if skill.power != 0 and skill.atk_f > 0
        remove_states_shock
        effective = true
      end
      
      last_hp = self.hp
      self.hp -= self.damage
      effective |= self.hp != last_hp
      
      @state_changed = false
      effective |= states_plus(skill.plus_state_set)
      effective |= states_minus(skill.minus_state_set)
      
      if skill.power == 0
        self.damage = ""
        unless @state_changed
          self.damage = "Miss"
        end
      end
    else
      self.damage = "Miss"
    end
    
    unless $game_temp.in_battle
      self.damage = nil
    end
    return effective
  end

  def item_effect(item)
    self.critical = false

    if ((item.scope == 3 or item.scope == 4) and self.hp == 0) or
        ((item.scope == 5 or item.scope == 6) and self.hp >= 1)
      return false
    end
    
    effective = false
    effective |= item.common_event_id > 0
    hit_result = (rand(100) < item.hit)
    effective |= item.hit < 100
    
    if hit_result == true
      recover_hp = maxhp * item.recover_hp_rate / 100 + item.recover_hp
      recover_sp = maxsp * item.recover_sp_rate / 100 + item.recover_sp
      if recover_hp < 0
        recover_hp += self.pdef * item.pdef_f / 20
        recover_hp += self.mdef * item.mdef_f / 20
        recover_hp = [recover_hp, 0].min
      end
      
      recover_hp *= elements_correct(item.element_set)
      recover_hp /= 100
      recover_sp *= elements_correct(item.element_set)
      recover_sp /= 100
      
      if item.variance > 0 and recover_hp.abs > 0
        amp = [recover_hp.abs * item.variance / 100, 1].max
        recover_hp += rand(amp+1) + rand(amp+1) - amp
      end
      if item.variance > 0 and recover_sp.abs > 0
        amp = [recover_sp.abs * item.variance / 100, 1].max
        recover_sp += rand(amp+1) + rand(amp+1) - amp
      end
      
      if recover_hp < 0
        if self.guarding?
          recover_hp /= 2
        end
      end
      
      self.damage = -recover_hp
      
      last_hp = self.hp
      last_sp = self.sp
      self.hp += recover_hp
      self.sp += recover_sp
      effective |= self.hp != last_hp
      effective |= self.sp != last_sp
      
      @state_changed = false
      effective |= states_plus(item.plus_state_set)
      effective |= states_minus(item.minus_state_set)
      
      if item.parameter_type > 0 and item.parameter_points != 0
        case item.parameter_type
        when 1  
          @maxhp_plus += item.parameter_points
        when 2  
          @maxsp_plus += item.parameter_points
        when 3  
          @str_plus += item.parameter_points
        when 4  
          @dex_plus += item.parameter_points
        when 5  
          @agi_plus += item.parameter_points
        when 6  
          @int_plus += item.parameter_points
        end
        effective = true
      end
      
      if item.recover_hp_rate == 0 and item.recover_hp == 0
        self.damage = ""
        if item.recover_sp_rate == 0 and item.recover_sp == 0 and
            (item.parameter_type == 0 or item.parameter_points == 0)
          unless @state_changed
            self.damage = "Miss"
          end
        end
      end
    else
      self.damage = "Miss"
    end
    
    unless $game_temp.in_battle
      self.damage = nil
    end
    return effective
  end

  def slip_damage_effect
    self.damage = self.maxhp / 10
    if self.damage.abs > 0
      amp = [self.damage.abs * 15 / 100, 1].max
      self.damage += rand(amp+1) + rand(amp+1) - amp
    end
    self.hp -= self.damage
    return true
  end

  def elements_correct(element_set)
    if element_set == []
      return 100
    end
    weakest = -100
    for i in element_set
      weakest = [weakest, self.element_rate(i)].max
    end
    return weakest
  end
end