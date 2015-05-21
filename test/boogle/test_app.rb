ENV['RACK_ENV'] = 'test'

require_relative '../../lib/boogle/app'
require 'test/unit'
require 'rack/test'


class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end


  def query_index(query)
    get '/search', {query: query}
    assert last_response.ok?
    last_response.body
  end

  def load_index_with_book(page_content, page_id=300)
    body = {
        pageId: page_id,
        content: page_content
    }
    post '/index', body
    assert last_response.ok?
  end

  def test_querries_are_case_insenitive
    content = "Elementary dear Watson"
    load_index_with_book(content)

    res_one = query_index(content)
    res_two = query_index(content.upcase)

    assert_responses_equal_and_not_empty res_one, res_two
  end

  def test_that_puncutation_is_ignored
    content = "Elementar&y de:ar Wa,tson"
    load_index_with_book(content)

    res_one = query_index(content)
    sanitized_query = content.gsub(/[^0-9A-Za-z ]/, '')
    res_two = query_index(sanitized_query)
    assert_responses_equal_and_not_empty res_one, res_two
  end

  def assert_responses_equal_and_not_empty(response_one, response_two)
    refute_empty JSON.parse(response_one)['matches']
    assert_equal response_one, response_two
  end

  def test_that_querries_disreguard_order
    content = "Elementary dear Watson"
    load_index_with_book(content)
    res_one = query_index("Watson Elementary dear ")
    res_two = query_index(content)
    assert_responses_equal_and_not_empty res_one, res_two
  end

  def test_that_querries_disreguard_word_frequency
    load_index_with_book("Elementary, dear Watson" * 10)
    res = query_index('dear Watson')
    expected = {matches: [{pageId: '300', score: 2}]}.to_json
    assert_equal expected, res
  end

  def test_that_partial_matches_work
    load_index_with_book("Elementary, dear Watson")
    res = query_index('dear Watson')
    expected = {matches: [{pageId: '300', score: 2}]}.to_json
    assert_equal expected, res
  end

end