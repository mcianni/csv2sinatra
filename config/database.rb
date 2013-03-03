require 'data_mapper'
config = YAML.load_file("#{Dir.pwd}/config/database.yml")

db_path = defined?(settings) ?
            "#{config[settings.environment.to_s]['database']}.db" :
            "csv2sinatra.db"
DataMapper.setup(:default, "sqlite://#{Dir.pwd}/db/#{db_path}")