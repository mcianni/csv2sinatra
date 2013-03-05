require 'rubygems'
require 'sinatra'
require 'sinatra/base'
require 'data_mapper'
require 'will_paginate'
require 'will_paginate/data_mapper'
require 'will_paginate/view_helpers/sinatra'
require './config/database' # init the db connection, anything needing access
                            # should be required below
require './models/base'
require 'haml'
require 'pry'

class CSV2Sinatra < Sinatra::Base
  helpers WillPaginate::Sinatra::Helpers

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
    @model_name = params[:table].capitalize
    haml :show
  end

end