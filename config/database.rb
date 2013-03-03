config = YAML.load_file("#{Dir.pwd}/config/database.yml")
db_path = "#{config[settings.environment.to_s]['database']}.db"
DataMapper.setup(:default, "sqlite://#{Dir.pwd}/db/#{db_path}")