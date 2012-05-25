require 'yajl'
require 'sinatra/base'
require 'sinatra/respond_with'
require 'sinatra/redis'

require 'readers/filesystem'
require 'readers/redis'
require 'helpers/input_parser'
require 'helpers/graph'

module StatsdServer
  class Dash < Sinatra::Base
    configure do
      set :haml, :format => :html5

      helpers StatsdServer::InputParser
      helpers StatsdServer::GraphHelpers

      register Sinatra::RespondWith
      register Sinatra::Redis
    end

    helpers do
      def render_error(msg)
        status 400
        respond_with error: msg
      end

      def create_stats_reader(index)
        if index.zero?
          StatsdServer::Readers::Redis.new(redis)
        else
          StatsdServer::Readers::FileSystem.new(settings.data_path)
        end
      end

      def retention_levels
        @retention_levels ||= settings.retention.split(",").map! { |s| s.split(":").map!(&:to_i) }
      end

      def determine_retention_level_and_index(range)
        diff = (range[1] - range[0]) / 60
        levels = retention_levels

        levels.each_with_index do |pair, index|
          return [pair.first, index] if diff <= pair.last || index == levels.size - 1
        end
      end
    end

    get "/" do
      haml :root
    end

    %w[ counters timers gauges ].each do |datatype|
      # this route renders the template (with codes for the graph)
      get "/#{datatype}", :provides => :html do
        haml :view
      end

      # actual data API route
      get "/#{datatype}", :provides => :json do
        metrics = parse_metrics
        range = parse_time_range

        return render_error('invalid metrics') if metrics.empty?
        return render_error('invalid time range') if range.nil?

        level, index = determine_retention_level_and_index(range)
        reader = create_stats_reader(index)

        read_opts = { level: level, range: range }
        results = { range: range, metrics: [] }

        metrics.each do |metric|
          data = reader.fetch(metric, datatype, read_opts)
          data = zero_fill!(data, range, level) unless data.empty? || params[:no_zero_fill]

          results[:metrics] << { label: metric, data: data }
        end

        respond_with results
      end
    end
  end
end
