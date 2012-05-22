module StatsdServer
  module Readers
    class FileSystem
      attr_reader :path

      def initialize(path)
        @path = path
      end

      def fetch(datatype, level, metric)
        raise NotImplementedError
      end
    end
  end
end
