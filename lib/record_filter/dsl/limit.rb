module RecordFilter
  module DSL
    class Limit

      attr_reader :limit, :offset

      def initialize(limit, offset)
        @limit, @offset = limit, offset
      end
    end
  end
end
