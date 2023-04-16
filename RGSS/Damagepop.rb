class Game_Character
  attr_accessor:collapse_duration
  attr_accessor:battler_visible
  attr_writer:opacity
  attr_accessor:collapse_done
end

module XRXS_CharacterDamagePop
  def update
    super
    if @battler == nil
      return
    end
    if @character.collapse_duration != nil
      if @character.collapse_duration > 0
        collapse
      end
      @_collapse_duration = @character.collapse_duration
    end
    @battler_visible = @character.battler_visible
    @battler_visible = true if @battler_visible == nil

    if @battler.damage_pop
      damage(@battler.damage, @battler.critical)
      @battler.damage = nil
      @battler.critical = false
      @battler.damage_pop = false
    end
    
    unless @battler_visible
      if not @battler.hidden and not @battler.dead? and
        (@battler.damage == nil or @battler.damage_pop)
        appear
        @battler_visible = true
      end
    end

    if @battler_visible
      if @battler.damage == nil and @battler.dead?
        collapse
        @battler_visible = false
      end
    else
      if @_collapse_duration > 0
        @_collapse_duration -= 1
        if @_collapse_duration == 0
          @character.collapse_done = true
        end
      end
    end
    @character.collapse_duration = @_collapse_duration
    @character.battler_visible = @battler_visible
  end
end

class Sprite_Character < RPG::Sprite
  include XRXS_CharacterDamagePop
end