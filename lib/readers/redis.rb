module StatsdServer
  module Readers
    class Redis
      attr_reader :redis

      def initialize(redis)
        @redis = redis
      end

      def fetch(metric, datatype, opts)
        redis.zrangebyscore("#{datatype}:#{metric}", *opts[:range]).map do |val|
          split = val.split("\x01R").map!(&:to_i)
        end
      end
    end
  end
end
