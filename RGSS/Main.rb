begin
  Graphics.freeze
  Graphics.frame_rate = 48
  $scene = Scene_Title.new
  while $scene != nil
    $scene.main
  end
  Graphics.transition(20)
rescue Errno::ENOENT
  filename = $!.message.sub("No such file or directory - ", "")
  print("File #{filename} not found.")
end