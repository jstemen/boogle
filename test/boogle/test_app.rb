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
  end

  def load_index_with_book(page_content, page_id=300)
    body = {
        pageId: page_id,
        content: page_content
    }
    post '/index', body
    assert last_response.ok?
  end

  def test_it_can_consume_and_respond
    load_index_with_book("Elementary, dear Watson")

    query_index('dear Watson')
    res = {matches: {pageId: '300', score: 2}}.to_json
    assert_equal res, last_response.body

  end

  def test_querries_are_case_insenitive
    skip "Implement me"
  end

  def test_that_puncutation_is_ignored
    skip "Implement me"
  end

  def test_that_querries_disreguard_order
    skip "Implement me"
  end

  def test_that_querries_disreguard_word_frequency
    skip "Implement me"
  end

  def test_that_partial_matches_work
    skip "Implement me"
  end

end