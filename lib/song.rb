require_relative "../config/environment.rb"
require 'active_support/inflector' #This library gives us #pluralize method

class Song

  # takes the name of the class and turns it into the name of the table 
  def self.table_name
    self.to_s.downcase.pluralize
  end

  
  def self.column_names
    DB[:conn].results_as_hash = true
    # gives us our array of hashes where we can get the value of the name keys
    sql = "pragma table_info('#{table_name}')"
    #Iterates over table_info(array of hashes) and grabs the 'name' keys for us
    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end

  # Iterates over our column_names class method and set an attr_accessor for each column name after turning it into a symbol
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

  # Iterates over options hash and use the #send method to interpolate the name of each hash key as a method that we set equal to that keys' value
  # As long as each property has a corresponding attr_accessor, this will work
  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  #Using string interpolation for a SQL query creates a SQL injection vulnerability.
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  # we have to do self.class in order to use a class method inside of an instance method.
  # Grabs the pertinent table name so that we can use it in #save
  def table_name_for_insert
    self.class.table_name
  end

  #Iterate over our column names and push our return into values using #send unless the value is nil like for id
  #  We then join the array into a string in order to get comma separated values.
  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  # returns comma separated list of column names excluding the id column
  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end


  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

end



