require 'helper'

describe StatsdServer::Dash do
  describe 'input parsing' do
    before do
      header 'Accept', 'application/json'
    end

    describe 'metrics' do
      it 'returns error on nil metrics' do
        get '/counters'

        last_response.status.must_equal 400
        last_response.body.must_include 'error'
      end

      it 'returns error on empty metrics' do
        get '/counters?metrics[]='

        last_response.status.must_equal 400
        last_response.body.must_include 'error'
      end

      it 'valid with string metrics param' do
        get '/counters?metrics=a.b'

        last_response.status.must_equal 200
        last_response.body.wont_be_empty
      end

      it 'valid with string metrics param' do
        get '/counters?metrics[]=a.b&metrics[]=c.d'

        last_response.status.must_equal 200
        last_response.body.wont_be_empty
      end
    end

    describe 'range parsing' do
      before do
        @start = Time.now.to_i - 86000
        @stop = Time.now.to_i
      end

      it 'returns error without stop param' do
        get "/counters?metrics[]=a.b&start=#{@start}"

        last_response.status.must_equal 400
        last_response.body.must_include 'error'
      end

      it 'returns error without start param' do
        get "/counters?metrics[]=a.b&stop=#{@stop}"

        last_response.status.must_equal 400
        last_response.body.must_include 'error'
      end

      it 'returns error on invalid range' do
        get "/counters?metrics[]=a.b&start=#{@stop}&stop=#{@start}"

        last_response.status.must_equal 400
        last_response.body.must_include 'error'

        get '/counters?metrics[]=a.b&start=-2&stop=-1'

        last_response.status.must_equal 400
        last_response.body.must_include 'error'
      end
    end
  end
end
