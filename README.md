csv2sinatra
===========

CSV2Sinatra takes a CSV file as input, imports the data into a table in a sqlite database, and dynamically generates DataMapper compatible classes based on the data.

Usage
-----
* `bundle`
* Copy CSV file(s) to csvs directory
* Run `rake c2s:import`
* Run the sinatra app with `rackup`
* Visit `localhost:9292` to see the imported tables


Working with data
-----------------
If you want to query, transform, append, etc... Access the database using the regular DataMapper methods. The class names are capitalized file names. You can get a list of the classes by calling `DynamicClasses.list`.

### With irb
* `irb`
* require './app.rb'