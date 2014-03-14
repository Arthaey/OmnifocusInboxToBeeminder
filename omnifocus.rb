require "sqlite3"

class Omnifocus
  def initialize(db_connection, verbose = false)
    @db_connection = db_connection
    @verbose = verbose
  end

  def inbox_count
    # Get all inbox actions in the inbox that are not action groups
    inbox_actions = count "(inInbox=1) and (dateCompleted is null)"

    # Get all inbox action groups and count them in too
    inbox_action_groups = count "(inInbox=1) and (childrenCount>0)"

    inbox_actions + inbox_action_groups
  end

  def due_soon_count
    count "(isDueSoon=1) and (dateCompleted is null)"
  end

  def overdue_count
    count "(isOverdue=1) and (dateCompleted is null)"
  end

  private

  def count(conditions)
    begin
      query = "select count(*) from task where #{conditions};"
      puts "Query: #{query}" if @verbose

      result = @db_connection.execute query
      puts "Result: #{result}" if @verbose

      result.first.first.to_i
    rescue
      puts "ERROR: Your Omnifocus database could not be queried."
      exit
    end
  end
end
