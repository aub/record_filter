module RecordFilter
  module DSL
    class Join # :nodoc: all

      attr_reader :association, :join_type, :conjunction, :aliaz

      def initialize(association, join_type, conjunction, aliaz)
        @association, @join_type, @conjunction, @aliaz = association, join_type, conjunction, aliaz
      end
    end
  end
end
