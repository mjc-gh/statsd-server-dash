require 'helper'

describe StatsdServer::Dash do
  before do
    header 'Accept', 'text/html'
  end

  it 'has counters routes' do
    get '/counters'

    last_response.status.must_equal 200
  end

  it 'has timers routes' do
    get '/timers'

    last_response.status.must_equal 200
  end

  it 'has gauges routes' do
    get '/gauges'

    last_response.status.must_equal 200
  end

  it 'renders html with graph' do
    get '/counters'

    # bitty hack but it works
    last_response.body.wont_be_empty
    last_response.body.must_match %r[<div class=.graph.>]
  end

  describe 'json api' do
    before do
      header 'Accept', 'application/json'

      @start = Time.now.to_i
      @metric = 'dash_test'

      create_redis_data :counters, @metric, @start, 5, 10 # 5 pts over 10 sec step
    end

		describe 'range parameter' do
			it 'responds to no range' do
				get "/counters?metrics[]=#{@metric}"

				last_response.status.must_equal 200

				json_response['range'].wont_be_empty
				json_response['metrics'].first.wont_be_nil
				json_response['metrics'].first['label'].must_equal @metric
				json_response['metrics'].first['data'].wont_be_empty
			end

			it 'responds to specific range' do
				get "/counters?metrics[]=#{@metric}"

				last_response.status.must_equal 200

				json_response['range'].wont_be_empty
				json_response['metrics'].first.wont_be_nil
				json_response['metrics'].first['label'].must_equal @metric
				json_response['metrics'].first['data'].wont_be_empty
			end
		end

		describe 'zero fill' do
			before do
				# add some more pts so we have a gap
				create_redis_data :counters, @metric, @start - 60, 1, 10
				create_redis_data :counters, @metric, @start - 120, 2, 10
			end

			it 'fills in gaps' do
				get "/counters?metrics[]=#{@metric}"
				data_pts = json_response['metrics'].first['data']

				# 120 range / 10 sec inclusive interval
				data_pts.size.must_equal (120 / 10) + 2

				non_zero = data_pts[0,2] + data_pts[7,1] + data_pts[9..-1]
				zero_fill = data_pts[2,4] + data_pts[5,1]

				non_zero.size.must_equal 8
				zero_fill.size.must_equal 6

				non_zero.each { |pt| pt.last.wont_equal 0, pt }
				zero_fill.each { |pt| pt.last.must_equal 0, pt }
			end

			it 'does not fill with no_zero_fill parameter' do
				get "/counters?metrics[]=#{@metric}&no_zero_fill=1"
			
				json_response['metrics'].first['data'].size.must_equal 8
			end
		end
	end
end
