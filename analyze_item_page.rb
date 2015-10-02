require 'rubygems'
require 'nokogiri'
require 'open-uri'

# Load and parse target webpage
webpage = 'http://auction.catawiki.com/kavels/2748577-macallan-1971-30-years-old-original-bottling'
webpage = 'http://auction.catawiki.com/kavels/2987515-macallan-1971-signatory-vintage-sherry-cask-27-years'
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
#puts distillery_count[kavel_distiller]
#puts distillery_count.max_by{|k,v| v}[1] == 0 ? 'Unknown' : distillery_count.max_by{|k,v| v}[0]

# Determine bottled year
kavel_bottled_year = page_total_description[/\b([12]\d{3})/]
print "Bottled in: ", kavel_bottled_year, "\n"

# Determine age
kavel_age = page_total_description[/\d+\s*y/i]
print "Age:        ", kavel_age, "\n"

# Determine percentage
kavel_percentage = page_total_description[/\d{2}[,\.]\d?\s*%/].split(',').join('.')
print "Percentage: ", kavel_percentage, "\n"

# Determine price
kavel_price = page.css('strong.bid_amount').text
print "Price:      ", kavel_price[/\d*,?\d+\.?\d?/], "\n"
