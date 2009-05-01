module RecordFilter
  module DSL
    class NamedFilter

      attr_reader :name, :args

      def initialize(name, *args)
        @name, @args = name, args
      end
    end
  end
end
