require 'spec_helper'

class User
  include DataMapper::Resource
  property :id, Serial
end
DataMapper.finalize.auto_upgrade!

describe 'CSV2Sinatra' do
  after(:all) do
    adapter = DataMapper.repository(:default).adapter
    adapter.execute("DROP TABLE #{User.storage_name}")
  end

  describe "the home page" do
    it 'should exist' do
      get '/'
      last_response.should be_ok
    end

    it 'should list known tables' do
      get '/'
      last_response.body.should include("users")
    end
  end

  describe 'a show page' do
    it 'should exist' do
      get '/tables/users'
      last_response.should be_ok
    end

    it 'should display a table' do
      get '/tables/users'
      last_response.body.should include("table")
    end

  end
end
