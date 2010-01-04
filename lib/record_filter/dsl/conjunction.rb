module RecordFilter
  module DSL
    class Conjunction # :nodoc: all

      attr_reader :type, :steps, :distinct

      def initialize(model_class, type=:all_of)
        @model_class, @type, @steps, @distinct = model_class, type, [], false
      end

      def add_restriction(column, value)
        @steps << (restriction = Restriction.new(column, value))
        restriction 
      end

      def add_conjunction(type, &block)
        dsl = ConjunctionDSL.new(@model_class, Conjunction.new(@model_class, type))
        dsl.instance_eval(&block) if block
        @steps << dsl.conjunction
      end

      def add_join(association, join_type, aliaz, &block)
        dsl = ConjunctionDSL.new(@model_class, Conjunction.new(@model_class, :all_of))
        dsl.instance_eval(&block) if block
        @steps << Join.new(association, join_type, dsl.conjunction, aliaz)
        dsl
      end

      def add_class_join(clazz, join_type, table_alias, &block)
        dsl = JoinDSL.new(@model_class, Conjunction.new(@model_class, :all_of))
        dsl.instance_eval(&block) if block
        @steps << ClassJoin.new(clazz, join_type, table_alias, dsl.conjunction, dsl.conditions)
        dsl
      end

      def add_limit(limit)
        @steps << Limit.new(limit)
      end

      def add_offset(offset)
        @steps << Offset.new(offset)
      end

      def add_order(column, direction)
        @steps << Order.new(column, direction)
      end

      def add_group_by(column)
        @steps << GroupBy.new(column)
      end

      def set_distinct
        @distinct = true
      end

      def add_named_filter(method, *args)
        @steps << NamedFilter.new(method, *args)
      end
    end
  end
end
