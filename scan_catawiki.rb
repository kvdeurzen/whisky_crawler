require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'mongo'

print_output = false

db = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'whisky')
db_collection = db[:whisky]
time = Time.new
date = time.year.to_s + "-" + time.month.to_s + "-" + time.day.to_s

# Functions
def catawiki_distiller(content, dist_list)
	distillery_count = Hash.new
	dist_list.each { |distillery|
		distillery_names = distillery.split(/,/)
		distillery_names.each { |distillery_name|
			distillery_count[distillery.split(/,/)[0]] ||= 0
			distillery_count[distillery.split(/,/)[0]] += content.scan(/\b#{distillery_name}\b/i).count
		}
	}
	return distillery_count.max_by{|k,v| v}[1] == 0 ? '' : distillery_count.max_by{|k,v| v}[0]
end

def catawiki_bottled(content)
	return content[/\b([12]\d{3})/]
end

def catawiki_percentage(content)
	unprocessed =content[/\d{2}[,\.]?\d?\s*%/]
	return unprocessed ? content[/\d{2}[,\.]?\d?\s*%/].split(',').join('.') : ''
end

def catawiki_age(content)
	return content[/\d+\s*y/i]
end

def catawiki_price(whole_page)
	unprocessed = whole_page.css('strong.bid_amount').text
	return unprocessed[/\d*,?\d+\.?\d?/].split(',').join
end

def catawiki_lotid(page)
	return page.css('form.bid_form')[0]['data-lot-id']
end

# Open empty write document
write_file = open('catawiki.csv', 'w')
write_file.write("Distiller, Bottle Year, Percentage, Age, Price, Link\n")
write_file.close


# Load and parse auction list page
auction_list_base_url = "http://auction.catawiki.com/whisky-veiling"
list_page = open(auction_list_base_url).read

# Distinguish items
auction_items = list_page.scan(/<a class='btn btn-orange' href='\/kavels\/([\S]+)' title/)

auction_items.each { |item_page|
	# Load and parse target webpage
	webpage = 'http://auction.catawiki.com/kavels/' + item_page[0]
	page = Nokogiri::HTML(open(webpage))

	# Load distillery list
	distilleries = open('distilleries').read.split(/\n/)

	# Collect description
	page_title = page.css("h1 span.lot_title").text
	page_description = page.css("section#cw-lot-description h1.lot_subtitle").text + 
					   page.css("section#cw-lot-description p.lot_description").text
	page_total_description = page_title + page_description

	kavel_distiller = catawiki_distiller(page_total_description, distilleries)
	kavel_bottled_year = catawiki_bottled(page_total_description)
	kavel_percentage = catawiki_percentage(page_total_description)
	kavel_age = catawiki_age(page_total_description)
	kavel_price = catawiki_price(page)
	kavel_lotid = catawiki_lotid(page)

	if print_output
		print "Distiller:  ", kavel_distiller, "\n"
		print "Bottled in: ", kavel_bottled_year, "\n"
		print "Percentage: ", kavel_percentage, "\n"
		print "Age:        ", kavel_age, "\n"
		print "Price:      ", kavel_price, "\n"
		print "Lot ID:     ", kavel_lotid, "\n"
		print "Webpage:    ", webpage, "\n"
		puts '-------------------------'
	end

	# Add or update item in mongo
	db_collection.update_one({"lotid" => kavel_lotid},
							 {"$set" => {
		"lotid" => kavel_lotid,
		"distiller" =>kavel_distiller,
		"bottled" => kavel_bottled_year,
		"percentage" => kavel_percentage,
		"age" => kavel_age,
		"site" => webpage,
		"price_history.#{date}" => kavel_price} },
		{ :upsert => true }
	)
}
