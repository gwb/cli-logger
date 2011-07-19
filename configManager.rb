module ConfigManager
  CONF_FILE = File.join(File::SEPARATOR, CONF_DIR, "logger.rb")

  def ConfigManager.loadConfig
    require CONF_FILE
    return {:current_project => Current_project}
  end

  def ConfigManager.changeCurrentProject(new_project)
    config_content = File.open(CONF_FILE).readlines
    config_content.collect! do |line|
      if line =~ /Current_project/
        "Current_project = '%s'\n" % new_project
      else
        line
      end
    end
    config_content
    File.open(CONF_FILE, 'w') do |f|
      config_content.each {|line| f.puts line}
    end
  end

end
        

