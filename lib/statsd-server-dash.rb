require 'yajl'
require 'sinatra/base'
require 'sinatra/respond_with'
require 'sinatra/redis'

require 'readers/filesystem'
require 'readers/redis'

module StatsdServer
  class Dash < Sinatra::Base
    configure do
      register Sinatra::RespondWith
      register Sinatra::Redis

      set :haml, :format => :html5

      # TODO warn\require (set defaults?) for retention, redis_uri and data_path
    end

    helpers do
      def retention_levels
        @retention_levels ||= settings.retention.split(",").map! { |s| s.split(":").map!(&:to_i) }
      end

      def determine_retention_level_and_index
        diff = params[:stop].to_i - params[:start].to_i
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
      get "/#{datatype}", :provides => :json do
        metrics = params[:metrics]
        metrics = [metrics] unless Array === metrics

        level, index = determine_retention_level_and_index
        cmd = if index.zero?
          StatsdServer::Readers::Redis.new(redis)
        else
          StatsdServer::Readers::FileSystem.new(settings.data_path)
        end

        results = metrics.map do |metric|
          # TODO more validation?
          next if metric.nil? || metric.empty?

          { label: metric, data: cmd.fetch(datatype, level, metric) }
        end

        respond_with results.tap(&:compact!)
      end

      get "/#{datatype}", :provides => :html do
        haml :view
      end
    end
  end
end
