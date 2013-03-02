require 'data_mapper'

module DynamicClasses

  class Base
    #include DataMapper::Resource
  end

  # Check if there's a table matching the requested const
  # If yes, create and return the class
  # If no, pass request along
  def self.const_missing(c)
    tables = repository(:default).adapter.select("SELECT name FROM sqlite_master\
                                         WHERE type in ('table', 'view')\
                                         AND name not like '%sqlite_%'")
    
    if tables.include?(c.to_s.downcase)
      klass = Class.new(DynamicClasses::Base)
      Object.const_set(c, klass)
      klass.class_eval("include DataMapper::Resource")

      cols = repository(:default).adapter.select("pragma table_info(#{c.to_s.downcase})")
      cols.map(&:name).each do |col|
        klass.property(col, col == "id" ? klass::Serial : klass::Text)
      end
      return klass

    else
      super
    end
  end
end