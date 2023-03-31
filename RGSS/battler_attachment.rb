module XAS_BA
  ENEMY_ID_VARIABLE_ID = 25
  SENSOR_DEFAULT_RANGE =  3
  SENSOR_SELF_SWITCH  = "D"
  ATTACK_ACTIONS = {
    1=>1, 2=>7, 3=>8, 4=>9, 5=>25, 6=>9, 7=>25,
    8=>26, 9=>8, 10=>27, 11=>28, 12=>9, 13=>8, 14=>8, 15=>9, 16=>10, 17=>8, 18=>9, 19=>28,
    31=>21, 32=>22, 33=>23, 34=>24, 35=>25,
    42=>10
  }

  OBJECTAL_ATTACKER_ID = 2
  DAMAGE_FLASH_DURATION = 60
  GAMEOVER_SWITCH_ID = 50
  KNOCK_BACK_SPEED = 5
  KNOCK_BACK_DURATION = 28
  DEFEAT_NUMBER_ID = 0
  
  ITEMDROP_SE = RPG::AudioFile.new("056-Right02", 70, 140)
  SHIELD_SE = RPG::AudioFile.new("097-Attack09", 80, 150)
end

module XAS_BA_ENEMY
  SHILED_DIRECTIONS = { 99=>[2] }
  SHILED_ACTIONS = { 99=>[1, 2] }
  KNOCK_BACK_DISABLES = [3, 7, 8, 11, 12, 14, 19, 26, 27]
  BODY_SQUARE = {
    9=>1, 10=>1, 13=>1, 15=>1, 16=>1, 17=>1, 18=>1, 20=>1, 21=>1, 22=>1,
    23=>1, 24=>1, 25=>1, 26=>1, 28=>1, 29=>1, 30=>1, 31=>1, 32=>1, 33=>1
  }
  DEFEAT_SWITCH_IDS = {
    4=>23, 7=>63, 9=>65, 10=>39, 13=>41, 14=>42, 15=>45, 16=>75,
    17=>77, 18=>78, 20=>59, 21=>80, 23=>97,24=>98, 27=>52, 28=>120, 29=>121, 30=>122,
    31=>123, 32=>124, 33=>125
  }
end

class Game_Event < Game_Character
  def enemy_defeat_process(enemy)
    last_level = $game_player.battler.level
    $game_party.gain_exp(enemy.exp)
    $game_party.gain_gold(enemy.gold)
    
    if last_level < $game_player.battler.level
      $game_player.battler.damage = "Level up!"
      $game_player.battler.damage_pop = true
      $game_player.need_refresh = true
    end
    
    id = XAS_BA::DEFEAT_NUMBER_ID
    $game_variables[id] += 1 if id != 0
    
    switch_id = XAS_BA_ENEMY::DEFEAT_SWITCH_IDS[self.enemy_id]
    if switch_id != nil
      $game_switches[switch_id] = true
      $game_map.refresh 
    end
  end
end

class Game_Party
  def gain_exp(exp)
    for i in 0...$game_party.actors.size
      actor = $game_party.actors[i]
      if actor.cant_get_exp? == false
        actor.exp += exp
      end
    end
  end
end

class Game_Player < Game_Character
  attr_accessor:need_refresh
end

module XAS_BA_BULLET_SP_COST
  def shoot_bullet(action_id)
    skill_id = XAS_BA::ATTACK_ACTIONS[action_id]
    skill = skill_id == nil ? nil : $data_skills[skill_id]
    if skill != nil
      sp_cost  = skill.sp_cost
      if self.battler.sp < sp_cost
        $game_system.se_play($data_system.buzzer_se)
        return false
      end
      self.battler.sp -= sp_cost
      self.need_refresh = true
    end
    return super
  end
end

class Game_Player < Game_Character
  include XAS_BA_BULLET_SP_COST
end

module XRXS_EnemySensor
  def update_sensor
    distance = ($game_player.x - self.x).abs + ($game_player.y - self.y).abs
    enable = (distance <= XAS_BA::SENSOR_DEFAULT_RANGE)
    key = [$game_map.map_id, self.id, XAS_BA::SENSOR_SELF_SWITCH]
    
    last_enable = $game_self_switches[key]
    last_enable = false if last_enable == nil
    if enable != last_enable
      $game_self_switches[key] = enable
      $game_map.need_refresh = true
    end
  end
end

class Game_Event < Game_Character
  include XRXS_EnemySensor
end

class Game_Character
  attr_writer:opacity
end

module XRXS_BattlerAttachment
  def attack_effect(attacker)
    return super if self.battler.nil? or attacker.nil?
    
    result = (not self.battler.dead? and self.battler.hiblink_duration.to_i <= 0)
    if result
      $game_temp.in_battle = true
      
      self.battler.attack_effect(attacker.battler)
      self.battler.damage_pop = false
      
      $game_temp.in_battle = false
      
      if self.battler.damage.to_i > 0
        self.blow(attacker.direction, 1)
      end
      
      self.battler.hiblink_duration = self.damage_hiblink_duration
      if self.is_a?(Game_Player)
        self.need_refresh = true
      end
    end
    
    
    @xrxs64c_defeat_done = false if @xrxs64c_defeat_done == nil
    if not @xrxs64c_defeat_done and self.battler.dead?
      defeat_process
      @xrxs64c_defeat_done = true
    end
  end

  def action_effect(bullet, action_id)
    return super if self.battler.nil?
    if self.battler.hiblink_duration.to_i > 0 and
        not bullet.action.ignore_invincible
      return false
    end
    
    skill_id = XAS_BA::ATTACK_ACTIONS[action_id]
    return if skill_id == nil
    
    user = bullet.action.user
    attacker = (user == nil ? nil : user.battler)
    attacker = $game_actors[XAS_BA::OBJECTAL_ATTACKER_ID] if attacker == nil
    result = (user != nil and not self.battler.dead?)
    skill_id = XAS_BA::ATTACK_ACTIONS[action_id]
    
    dirset = [2, 6, 8, 4]
    dir_index = (dirset.index(bullet.direction) + 2) % 4
    shield = self.shield_actions.include?(action_id)
    for direction in self.shield_directions
      dir_index2 = (dirset.index(self.direction) + dirset.index(direction)) % 4
      shield |= dirset[dir_index2] == dirset[dir_index]
    end
    if shield
      $game_system.se_play(XAS_BA::SHIELD_SE)
      user.blow(dirset[dir_index])
      super
      return true
    end
    
    if result
      skill = $data_skills[skill_id]
      if skill_id == 2 and $game_switches[120]
        skill = skill.dup
        skill.power = 8
      end
      
      $game_temp.in_battle = true
      self.battler.skill_effect(attacker, skill)
      self.battler.damage_pop = true
      $game_temp.in_battle = false
      
      if self.battler.damage.to_i > 0
        d = bullet.direction
        p = bullet.action.blow_power.to_i
        self.blow(d, p)
        self.battler.hiblink_duration = self.damage_hiblink_duration
      end
      
      if self.is_a?(Game_Player)
        self.need_refresh = true
      end
    end
    
    if not @xrxs64c_defeat_done and self.battler.dead?
      defeat_process
      @xrxs64c_defeat_done = true
    end
    return (super or result) 
  end

  def shield_directions
    return []
  end
  def shield_actions
    return []
  end
  def knock_back_disable
    return false
  end
  def damage_hiblink_duration
    return XAS_BA::DAMAGE_FLASH_DURATION
  end
  def dead?
    return self.battler == nil ? false : self.battler.dead?
  end
  def defeat_process
  end
end

class Game_Player < Game_Character
  include XRXS_BattlerAttachment

  def battler
    return $game_party.actors[0]
  end

  def defeat_process
    super
    $game_switches[XAS_BA::GAMEOVER_SWITCH_ID] = true
    $game_map.refresh
  end

  alias xrxs64c_update update
  def update
    xrxs64c_update
    self.battler.remove_states_auto if self.battler != nil
    
    if self.collapse_done
      self.collapse_done = false
      @xrxs64c_defeat_done = false
    end
  end
end

class Game_Event < Game_Character
  include XRXS_BattlerAttachment
  
  def battler
    return @battler
  end

  alias xrxs64c_refresh refresh
  def refresh
    xrxs64c_refresh
    self.battler_recheck
  end

  def battler_recheck
    return if @battler != nil
    
    if @page == nil
      return
    end
    
    @enemy_id = 0
    for page in @event.pages.reverse
      condition = page.condition
      if condition.variable_valid and
         condition.variable_id == XAS_BA::ENEMY_ID_VARIABLE_ID and
         (!condition.switch1_valid or $game_switches[condition.switch1_id]) and
         (!condition.switch2_valid or $game_switches[condition.switch2_id])
        @enemy_id = condition.variable_value
        break
      end
    end
    if @enemy_id == 0
      return
    end
    
    troop_id = -1
    member_index = -1
    for troop in $data_troops
      next if troop == nil
      for enemy in troop.members
        if enemy.enemy_id == @enemy_id
          troop_id     = $data_troops.index(troop)
          member_index = troop.members.index(enemy)
          break
        end
      end
    end
    
    if troop_id != -1 and member_index != -1
      @battler = Game_Enemy.new(troop_id, member_index)
    end
  end

  def enemy_id
    self.battler
    return @enemy_id
  end

  alias xrxs64c_update update
  def update
    if @collapse_wait_count.to_i > 0
      @collapse_wait_count -= 1
      if @collapse_wait_count == 0
        @collapse_wait_count = nil
        $game_map.remove_token(self)    
      end
      return
    end

    update_sensor
    xrxs64c_update
    
    if self.battler != nil
      self.battler.remove_states_auto
    end
    
    if self.collapse_duration.to_i > 0
      @through = true
    end
    
    if self.collapse_done
      @opacity = 0
      @collapse_wait_count = 32
      return
    end
  end

  def shield_enable!
    @shield_disable = nil
  end
  def shield_disable!
    @shield_disable = true
  end

  def shield_directions
    set = @shield_disable ? [] : XAS_BA_ENEMY::SHILED_DIRECTIONS[self.enemy_id]
    set = [] if set == nil
    return set
  end
  def shield_actions
    set = @shield_disable ? [] : XAS_BA_ENEMY::SHILED_ACTIONS[self.enemy_id]
    set = [] if set == nil
    return set
  end

  def knock_back_disable
    return XAS_BA_ENEMY::KNOCK_BACK_DISABLES.include?(self.enemy_id)
  end

  def body_size
    return XAS_BA_ENEMY::BODY_SQUARE[self.enemy_id].to_i
  end

  def defeat_process
    super
    enemy_defeat_process(self.battler)
  end
end

class Game_Event < Game_Character
  attr_reader:collision_attack
  def attack_on
    @collision_attack = true
  end
  def attack_off
    @collision_attack = false
  end
end

class Game_Player < Game_Character
  alias xrxs64c_check_event_trigger_touch check_event_trigger_touch
  def check_event_trigger_touch(x, y)
    xrxs64c_check_event_trigger_touch(x, y)
    if $game_system.map_interpreter.running?
      return
    end
    
    for event in $game_map.events.values
      next unless event.collision_attack
      unless [1,2].include?(event.trigger)
        if event.battler != nil and event.x == x and event.y == y
          $game_player.attack_effect(event)
        end
      end
    end
  end
end

class Game_Event < Game_Character
  alias xrxs64c_check_event_trigger_touch check_event_trigger_touch
  def check_event_trigger_touch(x, y)
    xrxs64c_check_event_trigger_touch(x, y)
    if $game_system.map_interpreter.running?
      return
    end
    return unless self.collision_attack
    if self.battler != nil and x == $game_player.x and y == $game_player.y
      $game_player.attack_effect(self)
    end
  end
end

module XAS_BA_BATTLEEVENT_NONPREEMPT
  def update
    return if self.battler != nil and $game_system.map_interpreter.running?
    super
  end
end

class Game_Event < Game_Character
  include XAS_BA_BATTLEEVENT_NONPREEMPT
end

class Game_Battler
  attr_accessor :hiblink_duration           
end

class Sprite_Character < RPG::Sprite
  alias xrxs64c_update update
  def update
    if @battler == nil
      @battler = @character.battler
    end
    xrxs64c_update
    if @battler == nil
      return
    end
    if @_collapse_duration > 0
      return
    end
    if @character.collapse_done
      return
    end
    if @battler.hiblink_duration.is_a?(Numeric)
      @character.opacity = (@character.opacity + 70) % 160 + 40
      @battler.hiblink_duration -= 1
      if @battler.hiblink_duration <= 0
        @battler.hiblink_duration = nil
        @character.opacity = 255
      end
    end
  end
end

module XAS_BA_ItemDrop
  def defeat_process
    super
    if self.battler.is_a?(Game_Enemy) and self.battler.dead?
      treasure = nil
      enemy = self.battler
      if rand(100) < enemy.treasure_prob
        if enemy.item_id > 0
          treasure = $data_items[enemy.item_id]
        end
        if enemy.weapon_id > 0
          treasure = $data_weapons[enemy.weapon_id]
        end
        if enemy.armor_id > 0
          treasure = $data_armors[enemy.armor_id]
        end
      end
      if treasure != nil
        item_se = XAS_BA::ITEMDROP_SE
        opecode = 
          treasure.is_a?(RPG::Item) ? 126 :
          treasure.is_a?(RPG::Weapon) ? 127 :
          treasure.is_a?(RPG::Armor) ? 128 :
          nil
        list = []
        if opecode != nil
          list[0] = RPG::EventCommand.new(opecode, 0, [treasure.id,0,0,1])
          list[1] = RPG::EventCommand.new(250, 0, [item_se]) 
          list[2] = RPG::EventCommand.new(116, 0, [])
        end
        list.push(RPG::EventCommand.new) 

        command = RPG::MoveCommand.new
        command.code = 14
        command.parameters = [0,0]
        route = RPG::MoveRoute.new
        route.repeat = false
        route.list = [command, RPG::MoveCommand.new]

        page = RPG::Event::Page.new
        page.move_type = 3
        page.move_route = route
        page.move_frequency = 6
        page.always_on_top = true
        page.trigger = 1
        page.list = list

        event = RPG::Event.new(self.x, self.y)
        event.pages = [page]
        token = Token_Event.new($game_map.id, event)
        token.icon_name = treasure.icon_name

        $game_map.add_token(token)
      end
    end
  end
end

class Game_Event < Game_Character
  include XAS_BA_ItemDrop
end

class Game_Character
  attr_accessor:icon_name
end

class Sprite_Character < RPG::Sprite
  alias xrxs_charactericon_update update
  def update
    xrxs_charactericon_update
    if @character.icon_name != nil 
      @icon_name = @character.icon_name
      self.bitmap = RPG::Cache.icon(@icon_name)
      self.src_rect.set(0, 0, 24, 24)
      self.ox = 12
      self.oy = 24
    end
  end
end

class Game_Character
  def blow(d, power = 1)
    return if self.knock_back_disable
    @knock_back_prespeed = @move_speed if @knock_back_prespeed == nil
    power.times do
      if passable?(self.x, self.y, d)
        @x += ([3, 6, 9].include?(d) ? 1 : [1, 4, 7].include?(d) ? -1 : 0)
        @y += ([1, 2, 3].include?(d) ? 1 : [7, 8, 9].include?(d) ? -1 : 0)
      end
    end
    @knock_back_duration = XAS_BA::KNOCK_BACK_DURATION
    @move_speed = XAS_BA::KNOCK_BACK_SPEED
  end

  alias xrxs64c_nb_update update
  def update
    @stop_count = -1 if self.knockbacking? or self.dead?
    xrxs64c_nb_update
    if self.knockbacking?
      @pattern = 0
      @knock_back_duration -= 1
      if @knock_back_duration <= 0
        @knock_back_duration = nil
        @move_speed = @knock_back_prespeed
        @knock_back_prespeed = nil
      end
      return
    end
  end
  def knockbacking?
    return @knock_back_duration != nil
  end
  def collapsing?
    return self.collapse_duration.to_i > 0
  end
end

module XAS_DamageStop
  def acting?
    return (super or self.knockbacking? or self.collapsing?)
  end
end

class Game_Player < Game_Character
  include XAS_DamageStop
end

class Game_Event < Game_Character
  include XAS_DamageStop
end