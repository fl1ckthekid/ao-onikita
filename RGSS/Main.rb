begin
  contents = File.read('Game.ini')
  contents.gsub!('RGSS102E.dll', 'RGSS104E.dll')
  File.open('Game.ini', 'w') { |file| file.write(contents) }
  
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