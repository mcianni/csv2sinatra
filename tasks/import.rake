require 'csv'
require 'pry'
require './lib/csv2sinatra_importer'

namespace :c2s do
  task "import" do
    doc_dir = (defined?(settings) && settings.test?) ? 'spec/csvs' : 'csvs'
    Dir["#{doc_dir}/*.csv"].each do |file|
      CSV::Sinatra::Importer.new(file).parse
    end
  end
end