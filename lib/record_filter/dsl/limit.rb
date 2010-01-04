module RecordFilter
  module DSL
    class Limit # :nodoc: all

      attr_reader :limit

      def initialize(limit)
        @limit = limit
      end
    end
  end
end
