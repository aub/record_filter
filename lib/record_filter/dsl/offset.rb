module RecordFilter
  module DSL
    class Offset # :nodoc: all

      attr_reader :offset

      def initialize(offset)
        @offset = offset
      end
    end
  end
end
