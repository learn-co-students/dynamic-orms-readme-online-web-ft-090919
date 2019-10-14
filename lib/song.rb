require_relative "../config/environment.rb"
require 'active_support/inflector'

class Song


  def self.table_name
    self.to_s.downcase.pluralize
    #taking what ever you class name is and make it LC and PZ it
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    # are the results in a hash
    sql = "pragma table_info('#{table_name}')"
    #have to understand what pragma is better
    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
      #take the name of the row and shovle that into the var colum name
    end
    column_names.compact
    #takes the array and removes the nil
  end

  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
    #take the instance of the coloum names for every instance do add a attr_accessor to that colum name and make it symbol
  end

  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
    #take the the hash equal to options pass it through a block send the thee instance of propertyy key and value into the the hash
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    #when saving get the position at 0 and then in the array inside of the array get at position o
  end

  def table_name_for_insert
    self.class.table_name
    #call the instance of the class method and the table_name method
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
    #have an empty array pass the instance of class and column_name for each instance of that do (a var) which shocles a colum name in unless it is nil
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
    #take and instence of class and coloum_name delete if there is a duplicate and join that array at the ","
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
    #just looking for a name selecting everything from where your looking (abstaction it wild)
  end

end
