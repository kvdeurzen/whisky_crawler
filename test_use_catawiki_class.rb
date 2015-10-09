require 'rubygems'
require 'open-uri'
require 'nokogiri'

require './lot_class.rb'
load './auction_catawiki_class.rb'

lot = Lot.new('1234')

lot.closed = true
lot.closed = false
lot.closed = '1'
lot.closed = '0'
lot.closed = 0
lot.closed = 1
lot.closed = 'aaa'
