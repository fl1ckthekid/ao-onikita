class Window_Message < Window_Selectable
  def pop_character=(character_id)
    @pop_character = character_id
    $mes_id = character_id
  end
end