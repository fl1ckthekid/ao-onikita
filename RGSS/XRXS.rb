class Game_Map
  attr_accessor:need_refresh_token
  def need_add_tokens
    @need_add_tokens = [] if @need_add_tokens == nil
    return @need_add_tokens
  end
  def need_remove_tokens
    @need_remove_tokens = [] if @need_remove_tokens == nil
    return @need_remove_tokens
  end
  def add_token(token_event)
    @events[token_event.id] = token_event
    self.need_add_tokens.push(token_event)
    self.need_refresh_token = true
  end
  def remove_token(token_event)
    @events.delete(token_event.id)
    self.need_remove_tokens.push(token_event)
    self.need_refresh_token = true
  end
  def clear_tokens
    for event in @events.values.dup
      remove_token(event) if event.is_a?(Token_Event)
    end
    channels = ["A", "B", "C", "D"]
    for id in 1001..(token_id_shift - 1)
      for a in channels
        key = [self.map_id, id, a]
        $game_self_switches.delete(key)
      end
    end
    clear_token_id
  end
end
class Game_SelfSwitches
  def delete(key)
    @data.delete(key)
  end
end
class Game_Map
  def token_id_shift
    @token_id  = 1000 if @token_id == nil
    @token_id += 1
    return @token_id
  end
  def clear_token_id
    @token_id = nil
  end
end
module XRXS_CTS_RefreshToken
  def refresh_token
    for event in $game_map.need_add_tokens
      @character_sprites.push(Sprite_Character.new(@viewport1, event))
    end
    $game_map.need_add_tokens.clear
    for sprite in @character_sprites.dup
      if $game_map.need_remove_tokens.empty?
        break
      end
      if $game_map.need_remove_tokens.delete(sprite.character)
        @character_sprites.delete(sprite)
        sprite.dispose
      end
    end
    $game_map.need_refresh_token = false
  end
end
class Spriteset_Map
  include XRXS_CTS_RefreshToken
  alias xrxs_lib15_update update
  def update
    xrxs_lib15_update
    refresh_token if $game_map.need_refresh_token
  end
end
class Scene_Map
  alias xrxs_lib15_transfer_player transfer_player
  def transfer_player
    $game_map.clear_tokens
    xrxs_lib15_transfer_player
  end
end
class Token_Event < Game_Event
  def initialize(map_id, event)
    event.id = $game_map.token_id_shift
    super
  end
  def erase
    super
    $game_map.remove_token(self)
  end
end