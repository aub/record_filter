module RecordFilter
  module DSL
    class Join

      attr_reader :association, :conjunction

      def initialize(association, conjunction)
        @association, @conjunction = association, conjunction
      end
    end
  end
end
