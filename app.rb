require 'sinatra'


get '/' do
  "foobar forever"
end


get '/search' do
  query = params['query']
  "query was #{query}"
end



post '/' do
 # .. create something ..
end