require 'data_mapper'

module DynamicClasses

  class Base
  end

  # Check if there's a table matching the requested const
  # If yes, create and return the class
  # If no, pass request along
  def self.const_missing(c)
    tables = repository(:default).adapter.select("SELECT name FROM sqlite_master\
                                         WHERE type in ('table', 'view')\
                                         AND name not like '%sqlite_%'")
    
    if tables.include?(DataMapper::Inflector.tableize(c.to_s))
      # TODO : refactor this
      klass = Class.new(DynamicClasses::Base)
      Object.const_set(DataMapper::Inflector.classify(c), klass)
      klass.class_eval("include DataMapper::Resource")

      cols = repository(:default).adapter.select("pragma table_info(#{DataMapper::Inflector.tableize(c.to_s)})")
      cols.map(&:name).each do |col|
        klass.property(col, col == "id" ? klass::Serial : klass::Text)
      end
      return klass

    else
      super
    end
  end

  def self.list
    tables = repository(:default).adapter.select("SELECT name FROM sqlite_master\
                                                  WHERE type in ('table', 'view')\
                                                  AND name not like '%sqlite_%'")
    tables.map{ |t| DataMapper::Inflector.classify(t) }
  end

  def self.load_classes(table_name=nil)
    tables = table_name ? 
                [table_name] : 
                repository(:default).adapter.select("SELECT name FROM sqlite_master\
                                                     WHERE type in ('table', 'view')\
                                                     AND name not like '%sqlite_%'")
    tables.each do |table|
      klass = Class.new(DynamicClasses::Base)
      Object.const_set(DataMapper::Inflector.classify(table), klass)
      klass.class_eval("include DataMapper::Resource")

      cols = repository(:default).adapter.select("pragma table_info(#{table})")
      cols.map(&:name).each do |col|
        klass.property(col, col == "id" ? klass::Serial : klass::Text)
      end
    end
  end

  self.load_classes
end