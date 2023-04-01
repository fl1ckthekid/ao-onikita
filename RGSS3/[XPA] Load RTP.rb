if XPA_CONFIG::RTP_LOADER

module Load_RTP_File
  RMXP  = true 
  RMVX  = false
  RMVXA = false
end
 
module Ini
  def self.readIni(item = "Title")
    buf = 0.chr * 256
    @gpps ||= Win32API.new("kernel32","GetPrivateProfileString","pppplp","l")
    @gpps.call("Game",item,"",buf,256,RPG.ini_file('.\\'))
    buf.delete!("\0")
    return buf
  end
end

class String
  def to_unicode  
    @mbytetowchar ||= Win32API.new("kernel32","MultiByteToWideChar",'ilpipi','I')
    len = @mbytetowchar.call(65001, 0, self, -1, 0, 0) << 1
    @mbytetowchar.call(65001, 0, self, -1, (buf = " " * len), len)
    return buf
  end
end

module RPG
  module Path
    FindFirstFile = Win32API.new("kernel32", "FindFirstFileW", "PP", "L") 
    FindNextFile  = Win32API.new("kernel32", "FindNextFileW", "LP", "I")
    ReadRegistry = Win32API.new("advapi32","RegGetValue","lppllpp","l")
    def self.getRTPPath(rgss,rtpname)
      return "" if rtpname == "" or rtpname.nil?
      reg = [ 0x80000002,
              "SOFTWARE\\Wow6432Node\\Enterbrain\\#{rgss}\\RTP",
              "#{rtpname}",
              2,
              0,
              0,
              (size = [256].pack("L")) ]
      ReadRegistry.call(*reg)
      buffer = size.unpack("L")[0]
      path = reg[5] = "\0" * buffer
      ReadRegistry.call(*reg)
      path.delete!("\0")
      path = (path + '/').gsub("\\","/").gsub("//","/")
      path 
    end
    @@RTP = []
    if Load_RTP_File::RMXP
      @@RTP << self.getRTPPath('RGSS','Standard')
      (0..3).each do |i| 
        @@RTP << self.getRTPPath('RGSS',Ini.readIni("RTP#{i.to_s}")) 
      end 
    end  
    @@RTP << self.getRTPPath('RGSS2',"RPGVX")    if Load_RTP_File::RMVX
    @@RTP << self.getRTPPath('RGSS3',"RPGVXAce") if Load_RTP_File::RMVXA
    @@RTP.reject! {|rtp| rtp.nil? || rtp.empty?}
    def self.findP(*paths)
      findFileData = " " * 596
      result = ""
      for file in paths        
        unless FindFirstFile.call(file.to_unicode, findFileData) == -1
          name = file.split("/").last.split(".*").first
          result = File.dirname(file) + "/" + name
        end
      end
      return result
    end
    def self.RTP(path)
      @list ||= {}
      return @list[path] if @list.include?(path)
      check = File.extname(path).empty?
      rtp = []
      @@RTP.each do |item|
        unless item.empty?
          rtp.push(item + path)
          rtp.push(item + path + ".*") if check
        end
      end
      rtp.push(path)
      rtp.push(path + ".*") if check
      pa = self.findP(*rtp)
      @list[path] = pa == "" ? path : pa
      return @list[path]
    end
  end
end

class << Audio
  [:bgm_play,:bgs_play,:se_play,:me_play].each do |meth|
    $@ || alias_method(:"#{meth}_path", :"#{meth}")
    define_method(:"#{meth}") do |*args|
      args[0] = RPG::Path::RTP(args[0]) if args[0].is_a?(String)
      send(:"#{meth}_path",*args)
    end
  end
end

class Bitmap
  $@ || alias_method(:rtp_path_init, :initialize)
  def initialize(*args)
    args[0] = RPG::Path::RTP(args.at(0)) if args.at(0).is_a?(String)
    rtp_path_init(*args)
  end
end

class << Graphics
  $@ || alias_method(:rtp_path_transition, :transition)
  def transition(*args)
    args[1] = RPG::Path::RTP(args.at(1)) if args[1].is_a?(String)
    rtp_path_transition(*args)
  end
end

end