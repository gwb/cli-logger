require 'csv'
require 'optparse'


CONF_DIR = "/Users/gwb/.gwb_ruby_logger.d/"



#################
##
## Option Parsing
##
#################

options = {}

optparse = OptionParser.new do |opts|
  
  opts.banner = "Log your progress when coding"

  # Option --switch
  options[:switch] = nil
  opts.on('-s', '--switch PROJECT_NAME', 'Switches to project PROJECT_NAME') do |project_name|
    options[:switch] = project_name
  end

  # Option --create
  options[:create] = nil
  opts.on('-c', '--create PROJECT_NAME', 'Creates a new project PROJECT_NAME') do |project_name|
    options[:create] = project_name
  end

  # Options --print
  options[:print] = false
  opts.on('-p', '--print', 'Displays the log corresponding to the current project') do
    options[:print] = true
  end

  # Option --help
  opts.on('-h', '--help', 'Display this screen') do
    puts opts
    exit
  end

end

optparse.parse! # Parses ARGV and removes all the options and their parameters from the array


######################
##
## Actions Definitions
##
######################


# Globals
#########

txt = ARGV[0]
TIME_REGEXP = /(.*) \+.*/


# Helper Functions
##################

# Loads - logFilename - creating it if it does not exist
def loadLog(logFilename)
  if !File.exist?(logFilename)
    CSV.open(logFilename, 'w') {|csv| csv << [TIME_REGEXP.match(Time.now.to_s), "Log creation"]}
  end
  return CSV.parse(File.read(logFilename))
end

def addEntryToBufferLog(bufferLog, entry)
  bufferLog << [TIME_REGEXP.match(Time.now.to_s), entry]
  return bufferLog
end

def flushBufferLog(bufferLog, logFilename)
  CSV.open(logFilename, 'w') do |csv|
    bufferLog.each do |entry|
      csv << entry
    end
  end
end

def printBufferLogToScreen(bufferLog)
  bufferLog.each do |entry|
    puts "#{entry[0]} : #{entry[1]}"
  end
end

def logNameToFilename(logName)
  return File.join(File::SEPARATOR, CONF_DIR, logName)
end


# Actions Wrappers
##################

require 'configManager.rb'
config = ConfigManager.loadConfig

if options[:create]
  bufferLog = loadLog(logNameToFilename(options[:create]))
  flushBufferLog(bufferLog, logNameToFilename(options[:create]))
end

if options[:switch]
  ConfigManager.changeCurrentProject(options[:switch])
end

if options[:print]
  bufferLog = loadLog(logNameToFilename(config[:current_project]))
  puts config[:current_project]
  printBufferLogToScreen(bufferLog)
end

if ARGV[0]
  bufferLog = loadLog(logNameToFilename(config[:current_project]))
  bufferLog = addEntryToBufferLog(bufferLog, ARGV[0])
  flushBufferLog(bufferLog, logNameToFilename(config[:current_project]))
end
