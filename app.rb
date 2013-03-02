require 'rubygems'
require 'sinatra/base'
require 'data_mapper'
require 'will_paginate'
require 'will_paginate/data_mapper'
require 'will_paginate/view_helpers/sinatra'
require './models/base'
require 'haml'
require 'pry'

class CSV2Sinatra < Sinatra::Base
  helpers WillPaginate::Sinatra::Helpers
  db_path = settings.test? ? 'test.db' : 'csv2sinatra.db'
  DataMapper.setup(:default, "sqlite://#{Dir.pwd}/db/#{db_path}")
  DataMapper.finalize

  get '/' do
    @records = repository(:default).adapter.select("SELECT name FROM sqlite_master\
                                         WHERE type in ('table', 'view')\
                                         AND name not like '%sqlite_%'")
    haml :index
  end

  get '/tables/:table' do
    klass    = eval("DynamicClasses::#{params[:table].capitalize}")
    @columns = klass.properties.map{ |p| p.name.to_s }
    @rows    = klass.all.paginate(page: params[:page])

    haml :show
  end
end