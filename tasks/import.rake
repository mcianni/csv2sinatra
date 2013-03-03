require './lib/csv2sinatra_importer'

namespace :c2s do
  # If a filename is passed to the task
  # only import that file, otherwise
  # import all files in csvs/*.csv
  task "import", [:file] do |t, args|
    doc_dir = (defined?(settings) && settings.test?) ? 'spec/csvs' : 'csvs'
    target_files = args['file'] ? 
                   "#{doc_dir}/#{args['file']}" : 
                   "#{doc_dir}/*.csv"

    Dir[target_files].each do |file|
      CSV::Sinatra::Importer.new(file).parse
    end
  end
end