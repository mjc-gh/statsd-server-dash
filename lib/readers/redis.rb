module StatsdServer
  module Readers
    class Redis
      attr_reader :redis

      def initialize(redis)
        @redis = redis
      end

      def fetch(datatype, level, metric)
        redis.zrange("#{datatype}:#{metric}", 0, -1).map do |val|
          split = val.split("\x01R").map!(&:to_i)

          [split.first * 1000, split.last]
        end
      end
    end
  end
end
