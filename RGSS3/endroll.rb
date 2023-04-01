module Endr
  REVERSE = false

  FONT = "MS PGothic"
  SIZE = 17
  COLOR = Color.new(255, 255, 255, 255)
  ALIGN = 0

  MARGIN1 = 8
  MARGIN2 = 32

  SPEED = 2
  BACK_GROUND = ""
  BGM = ""

  START = 120
  WAIT = 80
  NOINPUT = true
  FINISH = 40

  BACK = 1
  MAP = [0, -1, -1]
end

class Interpreter
  def start_er
    $scene = Scene_Endroll.new
    return true
  end
end

class Scene_Endroll
  def main
    @text = [
      " SOURCES",
      
      "", "", "",
      "SCRIPT",
      
      "",
      "Script Shelf  (スクリプトシェルフ)",
      "http://scriptshelf.jpn.org/x/",
      
      "",
      "Simp",
      "http://simp.u-abel.net",
      
      "",
      "Haguruma no Shiro (歯車の城)",
      "http://members.jcom.home.ne.jp/cogwheel/",
      
      "",
      "Zenith Creation",
      "http://zenith.ifdef.jp/",
      
      "", "",
      "PICTURES",
      
      "",
      "UD COBO",
      "http://umidoriya.tyanoyu.net/cb.html",
      
      "",
      "Mutation Genes Simulation T.D.Lab.",
      "http://mgshellc.lix.jp/",
      
      "",
      "First Seed Material",
      "http://www.tekepon.net/fsm/",
      
      "",
      "Looseleaf",
      "http://homepage3.nifty.com/looseleaf/",
      
      "",
      "Etolier (エトリエ)",
      "http://www5f.biglobe.ne.jp/~itazu/etolier/",
      
      "",
      "Suibi Amatara (睡枇 尼多羅)",
      "http://amatara.turigane.com/",
      
      "",
      "Tsukûru de ikô! (ツクールでいこう！)",
      "http://www1.dnet.gr.jp/~mi-ku/newpage2.htm",
      
      "",
      "Mori no oku no kakurezato (森の奥の隠れ里)",
      "http://fayforest.sakura.ne.jp/",
      
      "",
      "Naramura Sakusen (ナラムラ作戦)",
      "http://naramura.sakura.ne.jp/",
      
      "",
      "akiroom",
      "http://akiroom.com/tkool/",
      
      "",
      "Sukima no Sozai (すきまの素材)",
      "http://wato5576.hp.infoseek.co.jp/",
      
      "", "",
      "SOUND",
      
      "",
      "WEB WAVE LIB",
      "http://www.s-t-t.com/wwl/",
      
      "",
      "The Matchmakers 2nd (ザ・マッチメイカァズ2nd)",
      "http://osabisi.sakura.ne.jp/m2/",
      
      "",
      "TRANSLATION",
      "",
      "Benedikt Grosser (Sephy)",
      "http://musik.ardw.de/"
    ]
    @text[0] = @text[0][-(@text[0].size - 1), @text[0].size - 1]
    @text.reverse! if Endr::REVERSE
    @index = 0
    
    test = Bitmap.new(1, 1)
    test.font.name, test.font.size = Endr::FONT, Endr::SIZE
    @height = test.text_size(@text[0]).height + Endr::MARGIN1
    
    @sprites = []
    @sprites[0] = (Endr::SPEED > 0 ? make_sprite(480) : make_sprite(0-@height))
    @bg = Sprite.new
    @bg.bitmap = RPG::Cache.gameover(Endr::BACK_GROUND)
    
    @wait_count = 0
    
    $game_system.bgm_play(nil)
    $game_system.bgs_play(nil)
    
    Graphics.transition(Endr::START)
    loop do
      Graphics.update
      Input.update
      update
      break if $scene != self
    end
    
    Graphics.freeze
    @bg.bitmap.dispose
    @bg.dispose
    Graphics.transition(Endr::FINISH)
    Graphics.freeze
  end
  
  def update
    return (@wait_count -= 1) if @wait_count > 0
    if @finish_indicating
      if Input.trigger?(Input::B) or Input.trigger?(Input::C) or Endr::NOINPUT
        Audio.se_play("Audio/SE/025-Door02",100,100)
        case Endr::BACK
        when 0 ; $scene = nil
        when 1 ; $scene = Scene_Title.new
        when 2
          $game_map.setup(Endr::MAP[0]) unless Endr::MAP[0] == 0
          x = (Endr::MAP[1] == -1 ? $game_player.x : Endr::MAP[1])
          y = (Endr::MAP[2] == -1 ? $game_player.y : Endr::MAP[2])
          $game_player.moveto(x, y)
          $scene = Scene_Map.new
        end
      end
      return
    end
    
    update_sprites
    if @finish_writing and @sprites.empty?
      @wait_count = Endr::WAIT
      @finish_indicating = true
    end
  end

  def update_sprites
    dispose_flag = false
    @sprites.each {|sprite|
      sprite.update
      sprite.y -= Endr::SPEED
      dispose_flag = true if Endr::SPEED > 0 and sprite.y + @height < 0
      dispose_flag = true if Endr::SPEED < 0 and sprite.y > 480
    }

    if dispose_flag
      @sprites[0].bitmap.dispose
      @sprites[0].dispose
      @sprites.shift
    end
    return if @finish_writing
    
    if Endr::SPEED > 0
      if @sprites[-1].y + @height < 480
        @sprites.push(make_sprite(@sprites[-1].y + @height))
      end
    else
      if @sprites[-1].y > 0
        @sprites.push(make_sprite(-@height))
      end
    end
  end

  def make_sprite(y)
    sprite = Sprite.new
    sprite.x, sprite.y = Endr::MARGIN2, y
    s_width = 640 - Endr::MARGIN2 * 2
    sprite.bitmap = Bitmap.new(s_width, @height)
    sprite.bitmap.font.name  = Endr::FONT
    sprite.bitmap.font.size  = Endr::SIZE
    sprite.bitmap.font.color = Endr::COLOR
    string = @text[@index].chomp
    
    unless string[/wait([0-9]*)/].nil?
      @wait_count = $1.to_i
      string[/wait[0-9]*/] = ""
    end
    
    sprite.bitmap.draw_text(0, 0, s_width, @height, string, Endr::ALIGN)
    @index += 1
    @finish_writing = true if @index == @text.size
    return sprite
  end
end