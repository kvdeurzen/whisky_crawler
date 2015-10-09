require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'mongo'

load './catawiki_item_class.rb'

distilleries = open('distilleries').read.split(/\n/)

item = CatawikiItem.new('3037469')

puts item.lotid
puts item.distiller(distilleries)
puts item.bottled
puts item.percentage
puts item.age
puts item.price
puts item.link
puts item.auctioner
