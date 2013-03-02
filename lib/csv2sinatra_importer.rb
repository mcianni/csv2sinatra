require './models/base'

module CSV::Sinatra
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
      klass = Class.new(DynamicClasses::Base)
      Object.const_set(class_name, klass)
      klass.class_eval("include DataMapper::Resource")
      klass.property(:id, klass::Serial)

      data.each do |col|
        col.gsub!(/ /, '_')
        klass.property(col.intern, klass::Text)
      end
      
      klass.auto_migrate!
      @k = klass
    end

    def add_to_table(data)
      data.unshift(nil)
      data = Hash[@k.properties.map(&:name).zip(data)]
      @k.new(data).save!

      print '.'
    end

  end
end