module StatsdServer
  module Readers
    class FileSystem
      attr_reader :path

      def initialize(path)
        @path = path
      end

      def fetch(metric, datatype, opts)
        raise NotImplementedError
      end
    end
  end
end
