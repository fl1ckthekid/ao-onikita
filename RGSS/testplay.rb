class << Graphics
  alias :update_speed :update unless method_defined?("update_speed")
  def update
    if $DEBUG and Input.press?(Input::SHIFT) and Graphics.frame_count % 3 > 0
      Graphics.frame_count += 1
    else
      update_speed
    end
  end
end