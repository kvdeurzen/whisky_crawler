require 'open-uri'

auction_list_base_url = "http://auction.catawiki.com/whisky-veiling"

list_page = open(auction_list_base_url).read

auction_items = list_page.scan(/<a class='btn btn-orange' href='\/kavels\/([\S]+)' title/)

puts auction_items
puts auction_items.length
