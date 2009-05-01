module RecordFilter
  module DSL
    class Conjunction

      attr_reader :type, :steps

      def initialize(model_class, type=:all_of)
        @model_class, @type, @steps = model_class, type, []
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

      def add_join(association, join_type, &block)
        dsl = ConjunctionDSL.new(@model_class, Conjunction.new(@model_class, :all_of))
        dsl.instance_eval(&block) if block
        @steps << Join.new(association, join_type, dsl.conjunction)
        dsl
      end

      def add_class_join(clazz, join_type, table_alias, &block)
        dsl = JoinDSL.new(@model_class, Conjunction.new(@model_class, :all_of))
        dsl.instance_eval(&block) if block
        @steps << ClassJoin.new(clazz, join_type, table_alias, dsl.conjunction, dsl.conditions)
        dsl
      end

      def add_limit(limit, offset)
        @steps << Limit.new(limit, offset)
      end

      def add_order(column, direction)
        @steps << Order.new(column, direction)
      end

      def add_group_by(column)
        @steps << GroupBy.new(column)
      end

      def add_named_filter(method, *args)
        @steps << NamedFilter.new(method, *args)
      end
    end
  end
end
