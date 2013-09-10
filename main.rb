require 'rubygems'
require 'bundler/setup'

require 'nokogiri'

USER_AGENT = 'Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.17 Safari/537.36'

def get( url )
	return `curl -s -A "#{USER_AGENT}" -b cookies "https://m.facebook.com/#{url}"`
end

def get_books( fbid )

	raw = get( "timeline/app_section/?section_token=779301143%3A332953846789204&__user=#{fbid}" )
	page, collections, titles = Nokogiri::HTML( raw ), {}, { :current => [], :wishlist => [] }

	page.css('.touchableArea').map { |a| a.attribute('href').to_s  }.each do |link|
		if link.include?('A14')
			collections[ :current ] = link
		else
			collections[ :wishlist ] = link
		end
	end

	collections.each do |collection, url|
		raw = get( url )
		page = Nokogiri::HTML( raw )
		page.css('.item').each do |item|
			title = item.css('.fcb').css('.mfsm').inner_text
			if !title.empty?
				titles[ collection ].push( title )
			end
		end
	end

	titles
end

p get_books( 602978659 )
