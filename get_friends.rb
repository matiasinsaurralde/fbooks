require 'koala'
require 'oj'

@graph = Koala::Facebook::API.new('your_token')

friends = {}

@graph.get_connections("me", "friends").each do |friend|
	friends.store( friend['id'].to_i, friend['name'] )
end
	
open('friends.json', 'w') do |f|
	f.print( Oj.dump( friends ))
end
