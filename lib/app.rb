require 'sinatra'
require 'json'


# word => [page_id, page_id]
WORD_MAP = {}

=begin
# Endpoint to handle searching
GET /search?query=Elementary,%20dear%20Watson
- Request
Accept: application/json

- Response
HTTP/1.1 200 OK
Content-Type: application/json

{
“matches”: [
    {
“pageId”: 300,
    “score”: 3
},
    {
“pageId”: 12,
    “score”: 1
}
]
}
=end
get '/search' do
  query = params['query']
  page_ids = []
  query.split(' ').each { |q_word|
    WORD_MAP[q_word].each { |page_id|
      page_ids << page_id
    }
  }
  matches = {}
  page_ids.each { |page_id|
    matches[:pageId] = page_id
    matches[:score] =1
  }
  my_bod = {matches: matches}.to_json
  [200, {'Content-Type' => 'application/json'}, my_bod]
end


=begin
Content-Type: application/json
Accept: application/json

{
“pageId”: 300,
    “content”: “Elementary, dear Watson”
}
=end
post '/index' do

  payload = params
  page_id = payload['pageId']
  content = payload['content']
  content.split(' ').each { |word|
    WORD_MAP[word] ||= []
    WORD_MAP[word] << page_id
  }

end