require 'turn'
require 'minitest/autorun'
require 'rack/test'

require 'sinatra/test_helpers'
require 'statsd-server-dash'

# basic conf
StatsdServer::Dash.set :retention, "10:2160,60:10080,600:262974"

ENV['RACK_ENV'] = 'test'
include Rack::Test::Methods

class MiniTest::Spec
  before do
    # clear out redis
    app.redis.del 'counters:dash_test'
  end

  def app
    StatsdServer::Dash
  end

  # TODO make this use actual StatsdServer writers
  def create_redis_data(datatype, metric, start, points, step, value = :random)
    # piggyback on app's own redis client
    points.times do |n|
      score = start - (n * step)
      member = "#{score}\x01R#{val = value == :random ? (rand(100) + 1) : value}"

      app.redis.zadd "#{datatype}:#{metric}", score, member
    end
  end

  def json_response
    oid = last_response.object_id

    if oid != @last_response_id
      @last_response_id = oid
      @last_response_json_body = Yajl::Parser.parse(last_response.body) rescue nil
    end

    @last_response_json_body
  end
end
