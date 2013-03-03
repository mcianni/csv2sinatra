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
      CSV.foreach(@file, { headers: true, return_headers: true }) do |row|
        row.header_row? ? create_table(row.fields) : add_to_table(row.fields)
      end
    end

    private
    def create_table(data)
      # Dynamically define a class with an id:Serial column
      # and properties matching the csv file
      class_name = "#{@file}".split("/").last.split(".")[0].split.join("_").capitalize

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

      data.each do |col|
        col.gsub!(/ /, '_')
        raise IDClashError if col == 'id'
        klass.property(col.intern, klass::Text)
      end
      
      klass.auto_migrate!
      @k = klass
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