csv2sinatra
===========

CSV2Sinatra takes a CSV file as input, imports the data into a table in a sqlite database, and dynamically generates DataMapper compatible classes based on the data.

Usage
-----
* `bundle install`
* Copy CSV file to csvs directory
* Run `rake c2s:import`
* Run the sinatra app `rackup`
* Visit `localhost:9292` to see the imported tables
