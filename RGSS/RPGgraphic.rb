module RPG_FileTest
  def RPG_FileTest.character_exist?(filename)
    return RPG::Cache.character(filename, 0) rescue return false
  end
  def RPG_FileTest.picture_exist?(filename)
    return RPG::Cache.picture(filename) rescue return false
  end
  def RPG_FileTest.battler_exist?(filename)
    return RPG::Cache.battler(filename, 0) rescue return false
  end
end