require "optparse"
require "beeminder"
require "sqlite3"
require "etc"
require_relative "omnifocus"

# Get command line options and parse them
COUNT_OPTIONS = %w[inbox due_soon overdue]
cmd_line_options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: omnifocustobeeminder.rb [options]"

  opts.on("-c", "--count TASKS", COUNT_OPTIONS, "#Which type of tasks to count", " (#{COUNT_OPTIONS})") do |which|
    cmd_line_options[:which_tasks] = which
  end

  opts.on("-k key", "--apikey KEY", "#Your Beeminder API key") do |key|
    cmd_line_options[:key] = key
  end

  opts.on("-g goal", "--beeminder_goal GOAL", "#The slug of the goal you wish to log on Beeminder") do |goal|
    cmd_line_options[:goal] = goal
  end
  
  opts.on("-p path", "--database_path PATH", "#Path to your omnifocus database") do |path|
    cmd_line_options[:path] = path
  end

  opts.on("-v", "--verbose", "#Output verbose messages") do
    cmd_line_options[:verbose] = true
  end

  opts.on_tail("-h", "--help", "#Show this message") do
    puts opts
    exit
  end

end.parse!

# Terminate the script if which type of tasks to count was not provided by the user
if cmd_line_options[:which_tasks].nil?
  puts "ERROR: You must choose to --count one of #{COUNT_OPTIONS}."
  exit
end

# Terminate the script if the key was not provided by the user
if cmd_line_options[:key].nil?
  puts "ERROR: Your beeminder key is required. Use the -k option."
  exit
end

# Terminate the script if the goal was not provided by the user
if cmd_line_options[:goal].nil?
  puts "ERROR: Your beeminder goal slug is required. Use the -g option."
  exit
end

# Determine the database path
database_path = nil;
if cmd_line_options[:path].nil?
  # If the path to the Omnifocus database was not provided by the user, use the default one
  database_path = "/Users/#{Etc.getlogin}/Library/Caches/com.omnigroup.OmniFocus/OmniFocusDatabase2"
else
  # If the path to the Omnifocus database was provided, use it
  database_path = "#{cmd_line_options[:path]}"
end

# Open the OmniFocus database
count = nil
begin
  db_connection = SQLite3::Database.new database_path
  omnifocus = Omnifocus.new db_connection, cmd_line_options[:verbose]
  # Call inbox_count, due_soon_count, or overdue_count as appropriate
  count = omnifocus.send "#{cmd_line_options[:which_tasks]}_count"
rescue
  puts "ERROR: Your Omnifocus database could not be opened."
  puts "DATABASE: #{database_path}"
  exit
end

if count.nil?
  puts "ERROR: Count of #{cmd_line_options[:which_tasks]} tasks could not be determined."
  exit
end

# Connect to Beeminder and post the datapoint
beeminder_connection = Beeminder::User.new cmd_line_options[:key]
omnifocus_inbox_tracking_goal = beeminder_connection.goal cmd_line_options[:goal]
new_omnifocus_inbox_count_data_point = Beeminder::Datapoint.new(
  :value => count,
  :comment => "Automated Omnifocus count of #{cmd_line_options[:which_tasks]} as of #{Time.now.strftime("%m/%d/%Y at %I:%M %p")}"
)
omnifocus_inbox_tracking_goal.add new_omnifocus_inbox_count_data_point
