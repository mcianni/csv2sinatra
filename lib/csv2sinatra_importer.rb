require './config/database'
require './models/base'

module CSV::Sinatra
  class NameClashError < StandardError; end
  class IDClashError   < StandardError; end

  class Importer

    def initialize(filepath='')
      @file = filepath
    end

    def parse
      # Read ONE line at a time b/c this could be a huge file
      CSV.foreach(@file, { headers: true, return_headers: true, encoding: "iso-8859-1:UTF-8" }) do |row|
        row.header_row? ? create_table(row.fields) : add_to_table(row.fields)
        print '*' if $. % 100 == 0
      end
    end

    private
    def create_table(data)
      # Dynamically define a class with an id:Serial column
      # and properties matching the csv file
      class_name = File.basename(@file, '.*').split.map(&:capitalize).join

      # Raise an error if the Class name (generated from the file name)
      # will clash with an existing class
      if (Object.const_get(class_name) rescue false)
        raise NameClashError if Object.const_get(class_name).superclass != DynamicClasses::Base
      end

      # Generate the class with the properties from the csv file
      # and migrate the db
      klass = Class.new(DynamicClasses::Base)
      Object.const_set(class_name, klass)
      klass.class_eval("include DataMapper::Resource")
      klass.property(:id, klass::Serial)

      data.each_with_index do |col, i|
        col = prepare_column_name(col, i)
        klass.property(col.intern, klass::Text)
      end

      klass.auto_migrate!
      @k = klass
    end

    def prepare_column_name(col, i)
      # Ensure columns don't start with numbers and
      # remove non-alphanumeric characters
      # Set blank column names to column_[number]
      raise IDClashError if col == 'id'
      col = col.nil? ? "column #{i}" : col.dup
      col.prepend("_") if col =~ /\A[0-9]/
      col.gsub(/[^0-9a-z]/i, '_')
    end

    def add_to_table(data)
      # Add a column for the autoincrement id and
      # create a new instance of the class and save it
      # to the db
      data.unshift(nil)
      data = Hash[@k.properties.map(&:name).zip(data)]
      @k.new(data).save!
    end

  end
end
