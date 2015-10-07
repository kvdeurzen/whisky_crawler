require 'rubygems'
require 'open-uri'
require 'nokogiri'

class CatawikiItem

	def initialize(lotid)
		@auctioner		   = 'catawiki'
		@base_adress 	   = 'http://auction.catawiki.com/kavels/'
		@lotid			   = lotid
		@adress			   = @base_adress + @lotid
		@page_content 	   = Nokogiri::HTML(open(@adress))
		@page_main_content = @page_content.css("h1 span.lot_title").text + " " +
							 @page_content.css("section#cw-lot-description h1.lot_subtitle").text + " " +
							 @page_content.css("section#cw-lot-description p.lot_description").text
	end

	def auctioner
		return @auctioner
	end

	def state
		return @page_content.at_css('section.bid_block') ? "closed" : "open"
	end

	def final_price
		return self.state == "closed" ? @page_content.text[/document\.highest_bid = (\d+\.?\d*)/].split(' ')[2] : ""
	end

	def distiller(dist_list)
		distillery_count = Hash.new
		dist_list.each { |distillery|
			distillery_names = distillery.split(/,/)
			distillery_names.each { |distillery_name|
				distillery_count[distillery.split(/,/)[0]] ||= 0
				distillery_count[distillery.split(/,/)[0]] += @page_main_content.scan(/\b#{distillery_name}\b/i).count
			}
		}
		return distillery_count.max_by{|k,v| v}[1] == 0 ? '' : distillery_count.max_by{|k,v| v}[0]
	end

	def bottled
		return @page_main_content[/\b([12]\d{3})/]
	end

	def percentage
		temp =  @page_main_content[/\d{2}[,\.]?\d?\s*%/]
		return temp ? @page_main_content[/\d{2}[,\.]?\d?\s*%/].split(',').join('.') : ''
	end

	def age
		return @page_main_content[/\d+\s*y/i]
	end

	def price
		return @page_content.css('strong.bid_amount').text[/\d*,?\d+\.?\d?/].split(',').join
	end

	def lotid
		return @page_content.css('form.bid_form')[0]['data-lot-id']
	end

	def link
		return @adress
	end
end
