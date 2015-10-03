require 'open-uri'

# ****** Settings ****** #

save_items_to = "./items/"

# ********************** #


auction_item_base_url = "http://auction.catawiki.com/kavels/"
item_url = "3003323-talisker-25-years-usa-bottle-diageo-north-america"
item_full_url = auction_item_base_url + item_url;

item_page = open(item_full_url).read

item_local_filename = save_items_to + item_url

item_local_file = open(item_local_filename, "w")
item_local_file.write(item_page)
item_local_file.close

1
