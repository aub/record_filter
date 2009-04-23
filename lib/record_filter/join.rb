module RecordFilter
  class Join
    attr_reader :left_table, :right_table

    def initialize(left_table, right_table, join_conditions, join_type=nil)
      @left_table, @right_table, @join_conditions, @join_type =
        left_table, right_table, join_conditions, join_type
      @join_type ||= :inner
    end

    def to_sql
      if @join_conditions.blank?
        raise InvalidJoinException.new("Conditions must be provided for explicit joins using the 'on' method");
      end
      if join_type_string.nil?
        raise ArgumentError.new("The provided join type '#{@join_type}' is invalid.")
      end
      predicate_sql = @join_conditions.map do |condition|
        condition_to_predicate_part(condition)
      end * ' AND '
      "#{join_type_string} JOIN #{@right_table.table_name} AS #{@right_table.table_alias} ON #{predicate_sql}"
    end

    def requires_distinct_select?
      [:left, :outer, :left_outer].include?(@join_type)
    end

    protected

    def condition_to_predicate_part(condition)
      if condition.is_a?(Hash)
        "#{column_join_alias(@left_table, condition.keys[0])} = #{column_join_alias(@right_table, condition.values[0])}"
      elsif condition.is_a?(RecordFilter::DSL::Restriction)
        restriction_join_alias(condition)
      end
    end

    def column_join_alias(table, column)
      unless table.has_column(column)
        raise ColumnNotFoundException.new("The column #{column} was not found in the table #{table.table_name}")
      end
      "#{table.table_alias}.#{column}"
    end

    def restriction_join_alias(dsl_restriction)
      unless @right_table.has_column(dsl_restriction.column)
        raise ColumnNotFoundException.new("The column #{dsl_restriction.column} was not found in the table #{@right_table.table_name}")
      end
      restriction_class = RecordFilter::Restrictions::Base.class_from_operator(dsl_restriction.operator)
      restriction = restriction_class.new(
        "#{@right_table.table_alias}.#{dsl_restriction.column}", dsl_restriction.value, :negated => dsl_restriction.negated)
      @right_table.model_class.merge_conditions(restriction.to_conditions)
    end

    def join_type_string
      @join_type_string ||= case(@join_type)
        when :inner then 'INNER'
        when :left then 'LEFT'
        when :left_outer then 'LEFT OUTER'
        when :outer then 'OUTER'
        else nil
      end
    end
  end
end
