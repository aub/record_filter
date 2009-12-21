module RecordFilter
  module Conjunctions # :nodoc: all
    class Base
      attr_reader :table_name, :limit, :offset, :distinct

      def self.create_from(dsl_conjunction, table)
        result = case dsl_conjunction.type
          when :any_of then AnyOf.new(table)
          when :all_of then AllOf.new(table)
          when :none_of then NoneOf.new(table)
          when :not_all_of then NotAllOf.new(table)
          else raise InvalidFilterException.new("An invalid conjunction type of #{dsl_conjunction.type} was used.")
        end

        dsl_conjunction.steps.each do |step|
          case step
          when DSL::Restriction 
            handle_restriction_step(step, result, table, true)
          when DSL::Conjunction 
            result.add_conjunction(create_from(step, table)) 
          when DSL::Join
            join = result.add_join_on_association(step.association, step.join_type, step.aliaz)
            result.add_conjunction(create_from(step.conjunction, join.right_table))
          when DSL::ClassJoin
            join = result.add_join_on_class(
              step.join_class, step.join_type, step.table_alias, step.conditions)
            result.add_conjunction(create_from(step.conjunction, join.right_table))
          when DSL::Limit
            result.add_limit_and_offset(step.limit, step.offset)
          when DSL::Order
            result.add_order(step.column, step.direction)
          when DSL::GroupBy
            result.add_group_by(step.column)
          when DSL::NamedFilter
            result.add_named_filter(step.name, step.args)
          else raise InvalidFilterException.new('And invalid filter step was provided.')
          end
        end
        result.set_distinct(dsl_conjunction.distinct)
        result
      end

      def initialize(table, restrictions = nil, joins = nil)
        @table = table
        @table_name = table.table_alias
        @restrictions = restrictions || []
        @joins = joins || []
        @distinct = false
      end

      def add_restriction(column_name, operator, value, options={})
        check_column_exists!(column_name)
        restriction = RestrictionFactory.build(operator, "#{@table_name}.#{column_name}", value, @table, options)
        self << restriction
      end

      def add_conjunction(conjunction)
        self << conjunction
        conjunction
      end

      def add_join_on_association(association_name, join_type, aliaz)
        table = @table
        while association_name.is_a?(Hash)
          table = table.join_association(association_name.keys[0], { :join_type => join_type }).right_table
          association_name = association_name.values[0]
        end
        table.join_association(association_name, :join_type => join_type, :alias => aliaz)
      end
      
      def add_join_on_class(join_class, join_type, table_alias, conditions)
        @table.join_class(join_class, join_type, table_alias, conditions)
      end

      def add_order(column_name, direction)
        @table.order_column(column_name, direction)
      end

      def add_group_by(column_name)
        @table.group_by_column(column_name)
      end

      def add_limit_and_offset(limit, offset)
        @limit, @offset = limit, offset
      end

      def set_distinct(value)
        @distinct = value
      end

      def add_named_filter(name, args)
        unless @table.model_class.named_filters.include?(name.to_sym)
          raise NamedFilterNotFoundException.new("The named filter #{name} was not found in #{@table.model_class}")
        end
        query = Query.new(@table.model_class, name, *args)
        self << self.class.create_from(query.dsl_conjunction, @table)
      end

      def <<(restriction)
        @restrictions << restriction
      end

      def to_conditions
        result = begin
          if @restrictions.empty?
            nil
          elsif @restrictions.length == 1
            @restrictions.first.to_conditions
          else
            @restrictions.map do |restriction|
              conditions = restriction.to_conditions
              if conditions
                conditions[0] = "(#{conditions[0]})"
                conditions
              else
                nil
              end
            end.compact.inject do |conditions, new_conditions|
              conditions.first << " #{conjunctor} #{new_conditions.shift}"
              conditions.concat(new_conditions)
              conditions
            end
          end
        end
        result[0] = "NOT (#{result[0]})" if (negated && !result.nil? && !result[0].nil?)
        result
      end

      protected

      def check_column_exists!(column_name)
        if (!@table.has_column(column_name))
          raise ColumnNotFoundException.new("The column #{column_name} was not found in #{@table.table_name}.")
        end
      end

      def self.handle_restriction_step(step, conjunction, table, follow_conjunctions=true)
        if ((cr = step.conjuncted_restriction) && follow_conjunctions)
          restriction_conjunction = create_from(DSL::Conjunction.new(nil, step.conjuncted_restriction_type), table)
          handle_restriction_step(step, restriction_conjunction, table, false)
          handle_restriction_step(cr, restriction_conjunction, table, true)
          conjunction.add_conjunction(restriction_conjunction)
        else
          conjunction.add_restriction(step.column, step.operator, step.value, :negated => step.negated)
        end
      end
    end

    class AnyOf < Base
      def conjunctor; 'OR'; end
      def negated; false; end
    end

    class AllOf < Base
      def conjunctor; 'AND'; end
      def negated; false; end
    end

    class NoneOf < Base
      def conjunctor; 'OR'; end
      def negated; true; end
    end

    class NotAllOf < Base
      def conjunctor; 'AND'; end
      def negated; true; end
    end
  end
end
