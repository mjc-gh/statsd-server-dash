require 'digest'

module StatsdServer
  module Readers
    class FileSystem
      attr_reader :path

      def initialize(path)
        @path = path
      end

      def fetch(metric, datatype, opts)
        path = determine_filename(datatype, metric, opts[:level])
        start_ts, stop_ts = opts[:range]

        [].tap do |result|
          File.open(path, 'r') do |file|
            while line = file.gets
              split = line.split
              ts = split[0].to_i

              if ts >= start_ts && ts <= stop_ts
                result << [ts * 1000, split[1].to_f]
              end
            end
          end
        end

      rescue Errno::ENOENT => e
        return [] # return empty data

      end

      protected

      def determine_filename(*args)
        hash = Digest::MD5.hexdigest(args * ':')

        File.join(@path, hash[0,2], hash[2,2], hash)
      end
    end
  end
end
