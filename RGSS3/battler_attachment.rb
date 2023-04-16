module XAS_BA
  SENSOR_DEFAULT_RANGE = 3
  SENSOR_SELF_SWITCH = "D"
  ENEMY_ID_VARIABLE_ID = 25
  KNOCK_BACK_DURATION = 0
  KNOCK_BACK_SPEED = 0
  DAMAGE_FLASH_DURATION = 0
  GAMEOVER_SWITCH_ID = 50
end

class Game_Player < Game_Character
  attr_accessor:need_refresh
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
end