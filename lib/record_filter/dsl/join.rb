module RecordFilter
  module DSL
    class Join # :nodoc: all

      attr_reader :association, :join_type, :conjunction

      def initialize(association, join_type, conjunction)
        @association, @join_type, @conjunction = association, join_type, conjunction
      end
    end
  end
end
