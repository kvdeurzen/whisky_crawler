require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'mongo'

load './catawiki_item_class.rb'

# Open mongo connection
db = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'whisky')
db_collection = db[:whisky]

# Get date
time = Time.new
date = time.year.to_s + "-" + time.month.to_s + "-" + time.day.to_s + "-" + time.hour.to_s

# Load distilleries
distilleries = open('distilleries').read.split(/\n/)

# Load and parse auction list page
auction_list_base_url = "http://auction.catawiki.com/whisky-veiling"
auction_list_page = Nokogiri::HTML(open(auction_list_base_url))

# Distinguish items
auction_lots = auction_list_page.css("div.cw-item-auctionlot")


auction_lots.each {|i|
	lotid = i.css(".cw_favourite")[0]['data-lot_id']
	lot = CatawikiItem.new(lotid)

	# Add or update item in mongo
	if lot.state == "closed"
		db_collection.update_one({"lotid" => lot.lotid},
							 {"$set" => {
			"lotid" => lot.lotid,
			"distiller" =>lot.distiller(distilleries),
			"bottled" => lot.bottled,
			"percentage" => lot.percentage,
			"age" => lot.age,
			"site" => lot.link,
			"state" => lot.state,
			"final_price" => lot.final_price,
			"auctioner" => lot.auctioner } },
		{ :upsert => true }
	)
	else
		db_collection.update_one({"lotid" => lot.lotid},
								 {"$set" => {
			"lotid" => lot.lotid,
			"distiller" =>lot.distiller(distilleries),
			"bottled" => lot.bottled,
			"percentage" => lot.percentage,
			"age" => lot.age,
			"site" => lot.link,
			"state" => lot.state,
			"auctioner" => lot.auctioner,
			"price_history.#{date}" => lot.price } },
		{ :upsert => true }
	)
	end
}
