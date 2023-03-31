class Game_Switches
  def data_memorize
    @data_memo = @data.dup
  end
  def data_restore
    if @data_memo != nil
      @data = @data_memo
    end
  end
end

class Game_Variables
  def data_memorize
    @data_memo = @data.dup
  end
  def data_restore
    if @data_memo != nil
      @data = @data_memo
    end
  end
end
  
class Game_SelfSwitches
  def data_memorize
    @data_memo = @data.dup
  end
  def data_restore
    if @data_memo != nil
      @data = @data_memo
    end
  end
end

class Game_Screen
  def tone_memorize
    @tone_memo = [@tone.red, @tone.green, @tone.blue, @tone.gray]
  end
  def tone_restore(duration = 20)
    if @tone_memo != nil
      tone = Tone.new(@tone_memo[0], @tone_memo[1], @tone_memo[2], @tone_memo[3])
      start_tone_change(tone, duration * 2)
    end
  end
end

class Game_Battler
  def states_memorize
    if self.is_a?(Game_Actor)
      update_auto_state($data_armors[@armor1_id], nil)
      update_auto_state($data_armors[@armor2_id], nil)
      update_auto_state($data_armors[@armor3_id], nil)
      update_auto_state($data_armors[@armor4_id], nil)
    end
    @states_memo = @states.dup
    if self.is_a?(Game_Actor)
      update_auto_state(nil, $data_armors[@armor1_id])
      update_auto_state(nil, $data_armors[@armor2_id])
      update_auto_state(nil, $data_armors[@armor3_id])
      update_auto_state(nil, $data_armors[@armor4_id])
    end
  end
  def states_restore
    if @states_memo != nil
      @states = @states_memo
      if self.is_a?(Game_Actor)
        update_auto_state(nil, $data_armors[@armor1_id])
        update_auto_state(nil, $data_armors[@armor2_id])
        update_auto_state(nil, $data_armors[@armor3_id])
        update_auto_state(nil, $data_armors[@armor4_id])
      end
    end
  end
end

class Game_Party
  def actors_memorize
    @actors_memo = @actors.dup
  end
  def actors_restore
    if @actors_memo == nil
      return
    end
    new_actors = []
    for i in 0...@actors_memo.size
      if $data_actors[@actors_memo[i].id] != nil
        new_actors.push($game_actors[@actors_memo[i].id])
      end
    end
    @actors = new_actors
  end
  def belongings_memorize
    @items_memo = @items.dup
    @weapons_memo = @weapons.dup
    @armors_memo = @armors.dup
  end
  def belongings_restore
    if @items_memo != nil
      @items = @items_memo
      @weapons = @weapons_memo
      @armors = @armors_memo
    end
  end
end