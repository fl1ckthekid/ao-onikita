class Scene_Skill
  def initialize(actor_index = 0, equip_index = 0)
    @actor_index = actor_index
  end
  def main
    @actor = $game_party.actors[@actor_index]
    @help_window = Window_Help.new
    @status_window = Window_SkillStatus.new(@actor)
    @skill_window = Window_Skill.new(@actor)
    @skill_window.help_window = @help_window
    @target_window = Window_Target.new
    @target_window.visible = false
    @target_window.active = false
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      if $scene != self
        break
      end
    end
    Graphics.freeze
    @help_window.dispose
    @status_window.dispose
    @skill_window.dispose
    @target_window.dispose
  end
  def update
    @help_window.update
    @status_window.update
    @skill_window.update
    @target_window.update
    if @skill_window.active
      update_skill
      return
    end
    if @target_window.active
      update_target
      return
    end
  end
  def update_skill
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      $scene = Scene_Menu.new(1)
      return
    end
    if Input.trigger?(Input::C)
      @skill = @skill_window.skill
      if @skill == nil or not @actor.skill_can_use?(@skill.id)
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      $game_system.se_play($data_system.decision_se)
      if @skill.scope >= 3
        @skill_window.active = false
        @target_window.x = (@skill_window.index + 1) % 2 * 304
        @target_window.visible = true
        @target_window.active = true
        if @skill.scope == 4 || @skill.scope == 6
          @target_window.index = -1
        elsif @skill.scope == 7
          @target_window.index = @actor_index - 10
        else
          @target_window.index = 0
        end
      else
        if @skill.common_event_id > 0
          $game_temp.common_event_id = @skill.common_event_id
          $game_system.se_play(@skill.menu_se)
          @actor.sp -= @skill.sp_cost
          @status_window.refresh
          @skill_window.refresh
          @target_window.refresh
          $scene = Scene_Map.new
          return
        end
      end
      return
    end
    if Input.trigger?(Input::R)
      $game_system.se_play($data_system.cursor_se)
      @actor_index += 1
      @actor_index %= $game_party.actors.size
      $scene = Scene_Skill.new(@actor_index)
      return
    end
    if Input.trigger?(Input::L)
      $game_system.se_play($data_system.cursor_se)
      @actor_index += $game_party.actors.size - 1
      @actor_index %= $game_party.actors.size
      $scene = Scene_Skill.new(@actor_index)
      return
    end
  end
  def update_target
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      @skill_window.active = true
      @target_window.visible = false
      @target_window.active = false
      return
    end
    if Input.trigger?(Input::C)
      unless @actor.skill_can_use?(@skill.id)
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      if @target_window.index == -1
        used = false
        for i in $game_party.actors
          used |= i.skill_effect(@actor, @skill)
        end
      end
      if @target_window.index <= -2
        target = $game_party.actors[@target_window.index + 10]
        used = target.skill_effect(@actor, @skill)
      end
      if @target_window.index >= 0
        target = $game_party.actors[@target_window.index]
        used = target.skill_effect(@actor, @skill)
      end
      if used
        $game_system.se_play(@skill.menu_se)
        @actor.sp -= @skill.sp_cost
        @status_window.refresh
        @skill_window.refresh
        @target_window.refresh
        if $game_party.all_dead?
          $scene = Scene_Gameover.new
          return
        end
        if @skill.common_event_id > 0
          $game_temp.common_event_id = @skill.common_event_id
          $scene = Scene_Map.new
          return
        end
      end
      unless used
        $game_system.se_play($data_system.buzzer_se)
      end
      return
    end
  end
end