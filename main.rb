require 'rubygems'
require 'bundler/setup'

require 'nokogiri'

require 'pp'

USER_AGENT = 'Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.17 Safari/537.36'

def get( url )
	return `curl -s -A "#{USER_AGENT}" -b cookies "https://m.facebook.com/#{url}"`
end

def get_fbid( name )
	raw = get("/#{name}")
	profile_url = Nokogiri::HTML( raw ).css('a').css('.flyoutItem').first.attribute('href').to_s
	profile_url.split('/')[3].to_i
end

def get_books( fbid )

	if fbid.to_i == 0
		fbid = get_fbid( fbid )
	end

	raw = get( "timeline/app_section/?section_token=#{fbid}%3A332953846789204" )
	page, collections, titles = Nokogiri::HTML( raw ), {}, { :read => [], :wish => [], :like => [] }

	page.css('.touchableArea').map.each do |a|

		link = a.attribute('href').to_s
		label = a.inner_text

		if label.include?('Me gusta')
			collections[ :like ] = link
		end

		if label.include?('Leer')
			collections[ :read ] = link
		end

		if label.include?('Quiero leer')
			collections[ :wish ] = link
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

pp get_books( 'somename' )
