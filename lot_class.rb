class Lot
attr_accessor :auctioner,
			  :site,
			  :closed,
			  :final_price,
			  :valuta,
			  :distiller,
			  :distil_year,
			  :percentage,
			  :age,
			  :price_history

	def initialize(lotid)
		@lotid = lotid
	end
	
	def closed=(bool)
		if !!bool == bool then # Check of parameter is boolean
			@closed = bool
			puts bool
		else
			puts "Method \'closed\' received invalid parameter: #{bool}"
		end
	end

	def final_price=(price, valuta="Euro")
		price.is_f
	end

	def distil_year=(year)
		/(?<valid_year>(1|2)\d{3})/ =~ year
		if valid_year && 
			(valid_year.to_i <= Time.now.year - 3) &&
			(valid_year.to_i > Time.now.year - 70) then
			@distil_year = valid_year
		else
			puts "Method \'distil_year\' received invalid parameter: #{year}"
		end
	end
end
