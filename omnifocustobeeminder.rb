require 'optparse'
require "beeminder"
require "sqlite3"
require "etc"

# Get command line options and parse them
cmd_line_options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: main.rb [options]"

  opts.on("-k key", "--apikey KEY", "#Your Beeminder API key") do |key|
    cmd_line_options[:key] = key
  end

  opts.on("-g goal", "--beeminder_goal GOAL", "#The slug of the goal you wish to log on Beeminder") do |goal|
    cmd_line_options[:goal] = goal
  end
  
  opts.on("-p path", "--database_path PATH", "#Path to your omnifocus database") do |path|
    cmd_line_options[:path] = path
  end

  opts.on_tail("-h", "--help", "#Show this message") do
    puts opts
    exit
  end

end.parse!

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
begin
  db_connection = SQLite3::Database.new database_path
rescue
  puts "ERROR: Your Omnifocus database could not be opened."
  puts "DATABASE: #{database_path}"
  exit
end

# Query the OmniFocus database for inbox tasks
begin
  # Get all inbox actions in the inbox that are not action groups
  inbox_actions = db_connection.execute "select count(*) from task where (inInbox=1) and (dateCompleted is null);"
  # Get all inbox action groups and count them in too
  inbox_action_groups = db_connection.execute "select count(*) from task where (inInbox=1) and (childrenCount>0);"
rescue
  puts "ERROR: Your Omnifocus database could not be queried."
  exit
end

# Add up the inbox actions and the inbox action groups
all_actions = inbox_actions.first.first.to_i + inbox_action_groups.first.first.to_i

# Connect to Beeminder and post the datapoint
beeminder_connection = Beeminder::User.new cmd_line_options[:key]
omnifocus_inbox_tracking_goal = beeminder_connection.goal cmd_line_options[:goal]
new_omnifocus_inbox_count_data_point = Beeminder::Datapoint.new(
  :value => all_actions,
  :comment => "Automated Omnifocus count as of #{Time.now.strftime("%m/%d/%Y at %I:%M %p")}"
)
omnifocus_inbox_tracking_goal.add new_omnifocus_inbox_count_data_point
