require 'sinatra'
require 'json'


# word => [page_id, page_id]
WORD_MAP = {}

def sanitize_word(word)
  word.gsub(/[^0-9A-Za-z ]/, '').downcase
end

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
    match = WORD_MAP[sanitize_word(q_word)]
    if match
      match.each { |page_id|
        page_ids << page_id
      }
    end
  }

  page_ids.sort!

  cur_id = page_ids.first
  dup_count = 0
  id_to_sum_map = {}
  page_ids.each { |page_id|
    if cur_id == page_id
      dup_count +=1
    else
      id_to_sum_map[page_id] = dup_count
      dup_count = 1
    end
  }
  id_to_sum_map[cur_id] = dup_count if cur_id


  matches = id_to_sum_map.collect { |page_id, sum_count|
    sub_map = {}
    sub_map[:pageId] = page_id
    sub_map[:score] = sum_count
    sub_map
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
  page_id = params['pageId']
  content = params['content']
  content.split(' ').each { |word|
    san_word = sanitize_word(word)
    WORD_MAP[san_word] ||= Set.new
    WORD_MAP[san_word] << page_id
  }

end