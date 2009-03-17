module RecordFilter
  module Conjunctions
    class Base
      attr_reader :table_name

      def initialize(table_name)
        @table_name = table_name
        @restrictions = []
      end

      def add(column_name, restriction_class, value)
        self << restriction_class.new("#{@table_name}.#{column_name}", value)
      end
      
      def <<(restriction)
        @restrictions << restriction
      end

      def to_conditions
        if @restrictions.empty?
          nil
        elsif @restrictions.length == 1
          @restrictions.first.to_conditions
        else
          @restrictions.map do |restriction|
            conditions = restriction.to_conditions
            conditions[0] = "(#{conditions[0]})"
            conditions
          end.inject do |conditions, new_conditions|
            conditions.first << " #{conjunctor} #{new_conditions.shift}"
            conditions.concat(new_conditions)
            conditions
          end
        end
      end
    end

    class AnyOf < Base
      def conjunctor
        'OR'
      end
    end

    class AllOf < Base
      def conjunctor
        'AND'
      end
    end
  end
end
