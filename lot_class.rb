require 'uri'

class Lot
attr_accessor :auctioner,
			  :lotid,
			  :website,
			  :closed,
			  :final_price,
			  :valuta,
			  :distiller,
			  :distil_year,
			  :bottled_year,
			  :percentage,
			  :age,
			  :price_history

	def initialize(lotid)
		@lotid = lotid
		@price_history = Hash.new
		@valuta = 'euro'
	end

	def website=(address)
		!!URI.parse(address)
		@website = address
	rescue URI::InvalidURIError
		puts "Method \'#{__method__}\' received invalid parameter: #{address}"
	end

	def closed=(bool)
		if !!bool == bool then # Check of parameter is boolean
			@closed = bool
		else
			puts "Method \'#{__method__}\' received invalid parameter: #{bool}"
		end
	end

	def final_price=(price)
		if price.is_a?(Float) or price.is_a?(Fixnum) then
			@final_price = price
		else
			puts "Method \'#{__method__}\' received invalid parameter: #{price}"
		end
	end

	def valuta=(input)
		if input.is_a?(String)
			@valuta = input.downcase
		else
			puts "Method \'#{__method__}\' received invalid parameter: #{input}"
		end
	end

	def distil_year=(year)
		if year.is_a?(Fixnum) and year > Time.now.year - 230 and year <= Time.now.year - 3 then
			@distil_year = year
		else
			puts "Method \'#{__method__}\' received invalid parameter: #{year}"
		end
	end

	def bottled_year=(year)
		if year.is_a?(Fixnum) and year > Time.now.year - 70 and year <= Time.now.year - 3 then
			@bottled_year = year
		else
			puts "Method \'#{__method__}\' received invalid parameter: #{year}"
		end
	end

	def percentage=(perc)
		if (perc.is_a?(Float) or perc.is_a?(Fixnum)) and (perc > 0 and perc <= 100) then
			@percentage = perc
		else
			puts "Method \'#{__method__}\' received invalid parameter: #{perc}"
		end
	end

	def age=(input)
		if input.is_a?(Fixnum) and input > 0 and input <= 150 then
			@age = input
		else
			puts "Method \'#{__method__}\' received invalid parameter: #{input}"
		end
	end

	def price_history
		return @price_history
	end

	def add_price_history(price, date)
		if (price.is_a?(Fixnum) or price.is_a?(Float)) and price > 0 then
			if date.is_a?(Time) and not @price_history[date]
				@price_history.merge!(date => price)
			else
				puts "Method \'#{__method__}\' received invalid date parameter: #{date}"
			end
		else
			puts "Method \'#{__method__}\' received invalid price parameter: #{price}"
		end
	end
end
