require 'helper'

describe StatsdServer::Dash do
  before do
    header 'Accept', 'text/html'
  end

  it 'has counters route' do
    get '/counters'

    last_response.status.must_equal 200
    last_response.body.wont_be_empty
  end

  it 'has timers route' do
    get '/timers'

    last_response.status.must_equal 200
    last_response.body.wont_be_empty
  end

  it 'has gauges route' do
    get '/gauges'

    last_response.status.must_equal 200
    last_response.body.wont_be_empty
  end

  describe 'json api' do
    before do
      header 'Accept', 'application/json'

      @time = Time.now.to_i
      @metric = 'dash_test'
    end

		describe 'range parameter' do
      before do
        create_redis_data :counters, @metric, @time, 5, 10 # 5 pts over 10 sec step
      end

			it 'responds to no range' do
				get "/counters?metrics[]=#{@metric}"

				last_response.status.must_equal 200

				json_response['range'].wont_be_empty
				json_response['metrics'].first.wont_be_nil

				json_response['metrics'].first['label'].must_equal @metric
				json_response['metrics'].first['data'].size.must_equal 5
			end

			it 'responds to specific range' do
				get "/counters?metrics[]=#{@metric}&start=#{@time - 25}&stop=#{@time}"

				last_response.status.must_equal 200

				json_response['range'].wont_be_empty
				json_response['metrics'].first.wont_be_nil
				json_response['metrics'].first['label'].must_equal @metric
				json_response['metrics'].first['data'].size.must_equal 3
			end
		end

		describe 'zero fill' do
			before do
				# add some more pts so we have a gap
				create_redis_data :counters, @metric, @time - 120, 1, 10
				create_redis_data :counters, @metric, @time, 1, 10
			end

			it 'fills in gaps' do
				get "/counters?metrics[]=#{@metric}"
				data_pts = json_response['metrics'].first['data']

				data_pts.size.must_equal (120 / 10) + 1

        # first and last should be non-zero
        data_pts.first.last.wont_equal 0
        data_pts.last.last.wont_equal 0

        # rest are zero-fills
        data_pts[1..-2].each { |pt| pt.last.must_equal 0 }
			end

			it 'does not fill with no_zero_fill parameter' do
				get "/counters?metrics[]=#{@metric}&no_zero_fill=1"
			
				json_response['metrics'].first['data'].size.must_equal 2
			end

      it 'handles uneven interval' do
        # write additional data pt at uneven interval
        uneven_score = @time + 5
        uneven_member = "#{uneven_score}R\x01R#{1000}"

        app.redis.zadd "counters:#{@metric}", uneven_score, uneven_member

        get "/counters?metrics[]=#{@metric}&start=#{@time - 240}&stop=#{uneven_score}"

        data_pts = json_response['metrics'].first['data']

        data_pts.size.must_equal (120 / 10) + 2
        data_pts.last.first.must_equal uneven_score * 1000
        data_pts.last.last.must_equal 1000
      end
		end
	end
end
