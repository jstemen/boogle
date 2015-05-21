require 'json'

require 'sinatra/base'

class SimpleApp < Sinatra::Base

  set :root, File.dirname(__FILE__)

  enable :sessions


  def initialize(app=nil)
    super
    # format: {word => [page_id, page_id]}
    @word_map = {}
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
    page_ids = find_page_ids_matching_query(query)

    id_to_sum_map = group_page_ids(page_ids)

    my_bod = render_search_results(id_to_sum_map)
    [200, {'Content-Type' => 'application/json'}, my_bod]
  end

  # dumps the whole index
  delete '/index' do
    @word_map.clear
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
    clean_content = sanitize_word(content)
    clean_content.split(' ').each { |word|
      @word_map[word] ||= Set.new
      @word_map[word] << page_id
    }

  end

  private
  # @param [String] word - The string to be cleaned
  # @return [String] - A sanitized copy of the input
  def sanitize_word(word)
    word.gsub(/[^0-9A-Za-z ]/, '').downcase
  end

  def find_page_ids_matching_query(query)
    page_ids = []
    query.split(' ').each { |q_word|
      match = @word_map[sanitize_word(q_word)]
      if match
        match.each { |page_id|
          page_ids << page_id
        }
      end
    }
    page_ids
  end

  # @param [Array] page_ids - page ids
  # @return [Map] - Map of page ids and their associated frequency counts
  def group_page_ids(page_ids)
    page_ids.sort!.reverse!
    id_to_sum_map = {}
    unless page_ids.empty?
      past_id = page_ids[0]
      dup_count = 1
      (1..page_ids.size-1).to_a.each { |i|
        cur_id = page_ids[i]
        if past_id == cur_id
          dup_count +=1
        else
          id_to_sum_map[past_id] = dup_count
          dup_count = 1
          past_id = cur_id
        end
      }
      id_to_sum_map[past_id] = dup_count
    end
    id_to_sum_map
  end

  # @param [Map] id_to_sum_map - Map of page ids and their associated frequency counts
  # @return [String] - JSON formated output of search results
  def render_search_results(id_to_sum_map)
    matches = id_to_sum_map.collect { |page_id, sum_count|

      sub_map = {}
      sub_map[:pageId] = page_id
      sub_map[:score] = sum_count
      sub_map
    }
    my_bod = {matches: matches}.to_json
  end

end
