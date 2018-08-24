
require 'pry'
require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    table_info = DB[:conn].execute("PRAGMA table_info('#{self.table_name}')")
    column_names = []
    table_info.each do |col|
      column_names << col["name"] unless col["name"].nil?
    end
    column_names.compact
  end

  def initialize(options = {})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if{|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col|
      values << "'#{send(col)}'" unless send(col).nil?
    end
    values.join(", ")
  end

  def save
    sql = <<-SQL
    INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
    VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
      DB[:conn].execute("SELECT * FROM #{table_name} WHERE name = ?", name)
  end

  def self.find_by(attribute)
    values = []
    attribute.each do |part|
      values << part
    end
    # binding.pry
    return DB[:conn].execute("SELECT * FROM #{table_name} WHERE #{values[0][0].to_s} = '#{values[0][1]}'")
  end




end
