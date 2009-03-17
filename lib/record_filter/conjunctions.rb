module RecordFilter
  module Conjunctions
    class Base
      attr_reader :table_name

      def initialize(query, model_class)
        @query, @model_class = query, model_class
        @table_name = model_class.table_name
        @restrictions, @joins = [], []
      end

      def add_restriction(column_name, restriction_class, value)
        restriction = restriction_class.new("#{@table_name}.#{column_name}", value)
        self << restriction
        restriction
      end

      def add_conjunction(conjunction_class)
        conjunction = conjunction_class.new(@query, @model_class)
        self << conjunction
        conjunction
      end

      def add_join_on_association(association_name)
        @query.add_join(RecordFilter::Joins::ImplicitJoin.new(@model_class, association_name))
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
