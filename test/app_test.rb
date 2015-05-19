ENV['RACK_ENV'] = 'test'

require_relative '../lib/app'
require 'test/unit'
require 'rack/test'

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_it_can_consume_and_respond
    body = {
        pageId: 300,
        content: "Elementary, dear Watson"
    }

    post '/index', body
    assert last_response.ok?

    get '/search', {query: 'dear Watson'}
    assert last_response.ok?
    res = { matches: {pageId: '300',score: 1} }.to_json
    assert_equal res, last_response.body

  end

end