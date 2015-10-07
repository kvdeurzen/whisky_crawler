require 'rubygems'
require 'mongo'

db = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'whisky')

db[:test].insert_one({name: 'test'})
