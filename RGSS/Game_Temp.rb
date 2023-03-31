class Game_Temp
  attr_accessor:map_bgm
  attr_accessor:message_text
  attr_accessor:message_proc
  attr_accessor:choice_start
  attr_accessor:choice_max
  attr_accessor:choice_cancel_type
  attr_accessor:choice_proc
  attr_accessor:num_input_start
  attr_accessor:num_input_variable_id
  attr_accessor:num_input_digits_max
  attr_accessor:message_window_showing
  attr_accessor:common_event_id
  attr_accessor:in_battle
  attr_accessor:battle_calling
  attr_accessor:battle_troop_id
  attr_accessor:battle_can_escape
  attr_accessor:battle_can_lose
  attr_accessor:battle_proc
  attr_accessor:battle_turn
  attr_accessor:battle_event_flags
  attr_accessor:battle_abort
  attr_accessor:battle_main_phase
  attr_accessor:battleback_name
  attr_accessor:forcing_battler
  attr_accessor:shop_calling
  attr_accessor:shop_goods
  attr_accessor:name_calling
  attr_accessor:name_actor_id
  attr_accessor:name_max_char
  attr_accessor:menu_calling
  attr_accessor:menu_beep
  attr_accessor:save_calling
  attr_accessor:debug_calling
  attr_accessor:player_transferring
  attr_accessor:player_new_map_id
  attr_accessor:player_new_x
  attr_accessor:player_new_y
  attr_accessor:player_new_direction
  attr_accessor:transition_processing
  attr_accessor:transition_name
  attr_accessor:gameover
  attr_accessor:to_title
  attr_accessor:last_file_index
  attr_accessor:debug_top_row
  attr_accessor:debug_index

  def initialize
    @map_bgm = nil
    @message_text = nil
    @message_proc = nil
    @choice_start = 99
    @choice_max = 0
    @choice_cancel_type = 0
    @choice_proc = nil
    @num_input_start = 99
    @num_input_variable_id = 0
    @num_input_digits_max = 0
    @message_window_showing = false
    @common_event_id = 0
    @in_battle = false
    @battle_calling = false
    @battle_troop_id = 0
    @battle_can_escape = false
    @battle_can_lose = false
    @battle_proc = nil
    @battle_turn = 0
    @battle_event_flags = {}
    @battle_abort = false
    @battle_main_phase = false
    @battleback_name = ''
    @forcing_battler = nil
    @shop_calling = false
    @shop_id = 0
    @name_calling = false
    @name_actor_id = 0
    @name_max_char = 0
    @menu_calling = false
    @menu_beep = false
    @save_calling = false
    @debug_calling = false
    @player_transferring = false
    @player_new_map_id = 0
    @player_new_x = 0
    @player_new_y = 0
    @player_new_direction = 0
    @transition_processing = false
    @transition_name = ""
    @gameover = false
    @to_title = false
    @last_file_index = 0
    @debug_top_row = 0
    @debug_index = 0
  end
end