require 'spec_helper'
require 'rake'

describe 'Tasks' do
  describe 'Import' do

    it "should exist" do
      rake = Rake::Application.new
      Rake.application = rake
      rake.init
      rake.load_rakefile
      rake['csv:import'].invoke('users.csv')
    end

    it "should set column names from the first csv line" do
      Users.properties.map(&:name).should eq([:id, :first_name, :last_name, :phone_number])
    end

    it "should set all data from csv file" do
      Users.all.count.should eq(2)
      Users.all.map{|u| "#{u.first_name} #{u.last_name} : #{u.phone_number}"}.should
        eq ['joe jackson : 215-123-4567',
            'frank grimes : 215-555-1212']
    end

    it "should set an id column if the csv has none" do
      Users.properties.map(&:name).should include(:id)
    end

    it "should raise an error if the csv has a column named id" do
      rake = Rake::Application.new
      Rake.application = rake
      rake.init
      rake.load_rakefile

      expect { rake['csv:import'].invoke('bad.csv') }.to raise_error
    end

    it "should raise an error if the name of the csv would clash with an exisiting class" do
      rake = Rake::Application.new
      Rake.application = rake
      rake.init
      rake.load_rakefile

      expect { rake['csv:import'].invoke('fixnum.csv') }.to raise_error      
    end

  end
  
end