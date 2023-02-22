require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  
    def self.table_name
        self.to_s.downcase.pluralize
    end

    def initialize(attributes = {})
        attributes.each do |key, value|
            self.class.attr_accessor(key)
            self.send("#{key}=", value)
        end
    end

    def self.column_names
        DB[:conn].results_as_hash = true

        sql = "PRAGMA table_info('#{self.table_name}')"

        table_info = DB[:conn].execute(sql)

        column_names = table_info.map { |col| col["name"] }
    end

    def table_name_for_insert
        Student.table_name
    end

    def col_names_for_insert
        Student.column_names.filter { |col| col!="id" }.join(", ")
    end

    def values_for_insert
        self.col_names_for_insert.split(", ").map { |key| "'#{self.send(key)}'" }.join(", ")
    end

    def save
        sql = <<-SQL
            INSERT INTO #{Student.table_name} (#{self.col_names_for_insert
            }) VALUES ( ?, ? )
        SQL

        DB[:conn].execute(sql, self.name, self.grade)
        self.id = DB[:conn].last_insert_row_id
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM #{Student.table_name} WHERE name = ?
        SQL

        DB[:conn].execute(sql, name)
    end

    def self.find_by(attributes)
        sql = <<-SQL
            SELECT * FROM #{Student.table_name} WHERE #{attributes.keys.map { |key| "#{key} = ?" }.join(', ') }
        SQL
        DB[:conn].execute(sql, [attributes.values])
    end
end