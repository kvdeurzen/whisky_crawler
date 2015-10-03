require 'rubygems'
require 'nokogiri'
require 'open-uri'

# Open empty write document
write_file = open('catawiki.csv', 'w')
write_file.write("Distiller, Bottle Year, Percentage, Age, Price, Link\n")
write_file.close

open('catawiki.csv', 'a') { |write_file|

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

		# Analyze page
		#
		# Collect description
		page_title = page.css("h1 span.lot_title").text
		page_description = page.css("section#cw-lot-description h1.lot_subtitle").text + page.css("section#cw-lot-description p.lot_description").text
		page_total_description = page_title + page_description

		# Determine Distillery
		distillery_count = Hash.new
		distilleries.each { |distillery|
			distillery_names = distillery.split(/,/)
			distillery_names.each { |distillery_name|
				distillery_count[distillery.split(/,/)[0]] ||= 0
				distillery_count[distillery.split(/,/)[0]] += page_total_description.scan(/\b#{distillery_name}\b/i).count
			}
		}
		kavel_distiller = distillery_count.max_by{|k,v| v}[1] == 0 ? 'Unknown' : distillery_count.max_by{|k,v| v}[0]
		print "Distiller:  ", kavel_distiller, "\n"
		write_file << kavel_distiller << ", "

		# Determine bottled year
		kavel_bottled_year = page_total_description[/\b([12]\d{3})/]
		print "Bottled in: ", kavel_bottled_year, "\n"
		write_file << kavel_bottled_year << ", "

		# Determine percentage
		kavel_percentage_unprocessed = page_total_description[/\d{2}[,\.]?\d?\s*%/]
		kavel_percentage = kavel_percentage_unprocessed ? page_total_description[/\d{2}[,\.]?\d?\s*%/].split(',').join('.') : ''
		print "Percentage: ", kavel_percentage, "\n"
		write_file << kavel_percentage << ", "
		
		# Determine age
		kavel_age = page_total_description[/\d+\s*y/i]
		print "Age:        ", kavel_age, "\n"
		write_file << kavel_age << ", "

		# Price
		kavel_price_unprocessed = page.css('strong.bid_amount').text
		kavel_price = kavel_price_unprocessed[/\d*,?\d+\.?\d?/].split(',').join
		print "Price:      ", kavel_price, "\n"
		write_file << kavel_price << ", "
		
		# Print Line
		print "Webpage:    ", webpage, "\n"
		puts '-------------------------'
		write_file << webpage << "\n"
	}
}
