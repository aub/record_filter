module RecordFilter
  module Conjunctions
    class Base
      attr_reader :table_name, :limit, :offset

      def self.create_from(dsl_conjunction, table)
        result = case dsl_conjunction.type
          when :any_of: AnyOf.new(table)
          when :all_of: AllOf.new(table)
        end

        dsl_conjunction.steps.each do |step|
          case step
          when DSL::Restriction 
            result.add_restriction(step.column, step.operator, step.value, :negated => step.negated)
          when DSL::Conjunction 
            result.add_conjunction(create_from(step, table)) 
          when DSL::Join
            join = result.add_join_on_association(step.association)
            result.add_conjunction(create_from(step.conjunction, join.right_table))
          when DSL::Limit
            result.add_limit_and_offset(step.limit, step.offset)
          when DSL::Order
            result.add_order(step.column, step.direction)
          end
        end
        result
      end

      def initialize(table, restrictions = nil, joins = nil)
        @table = table
        @table_name = table.table_alias
        @restrictions = restrictions || []
        @joins = joins || []
      end

      def add_restriction(column_name, operator, value, options={})
        restriction_class = "RecordFilter::Restrictions::#{operator.to_s.camelize}".constantize
        restriction = restriction_class.new("#{@table_name}.#{column_name}", value, options)
        self << restriction
        restriction
      end

      def add_conjunction(conjunction)
        self << conjunction
        conjunction
      end

      def add_join_on_association(association_name)
        @table.join_association(association_name)
      end
      
      def add_order(column, direction)
        @table.order_column(column, direction)
      end

      def add_limit_and_offset(limit, offset)
        @limit, @offset = limit, offset
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
