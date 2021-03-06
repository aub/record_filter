module RecordFilter
  module Restrictions # :nodoc: all
    class Base
      include ColumnParser

      def initialize(column_name, value, table, options={})
        @column_name, @value, @table, @negated = column_name, value, table, !!options.delete(:negated)
        @value = @value.id if !subquery? && @value.kind_of?(ActiveRecord::Base)
      end

      def to_conditions
        if subquery? || @value.nil? || @value.is_a?(Hash)
          [to_sql]
        else
          [to_sql, @value]
        end
      end

      def to_sql
        @negated ? to_negative_sql : to_positive_sql
      end

      def to_negative_sql
        "NOT (#{to_positive_sql})"
      end

      def value_hash_as_column_or_question_mark
        if subquery?
          "(#{@value.to_subquery})"
        elsif @value.is_a?(Hash)
          column, table = parse_column_in_table(@value, @table)
          if (table.has_column(column))
            "#{table.table_alias}.#{column}"
          end
        else
          '?'
        end
      end

      def subquery?
        @value.respond_to?(:to_subquery)
      end
    end

    class EqualTo < Base
      def to_positive_sql
        "#{@column_name} = #{value_hash_as_column_or_question_mark}"
      end

      def to_negative_sql
        "#{@column_name} <> #{value_hash_as_column_or_question_mark}"
      end
    end

    class IsNull < Base
      def to_positive_sql
        "#{@column_name} IS NULL"
      end

      def to_negative_sql
        "#{@column_name} IS NOT NULL"
      end
    end

    class LessThan < Base
      def to_positive_sql
        "#{@column_name} < #{@value.nil? ? 'NULL' : value_hash_as_column_or_question_mark}"
      end
    end

    class LessThanOrEqualTo < Base
      def to_positive_sql
        "#{@column_name} <= #{@value.nil? ? 'NULL' : value_hash_as_column_or_question_mark}"
      end
    end

    class GreaterThan < Base
      def to_positive_sql
        "#{@column_name} > #{@value.nil? ? 'NULL' : value_hash_as_column_or_question_mark}"
      end
    end

    class GreaterThanOrEqualTo < Base
      def to_positive_sql
        "#{@column_name} >= #{@value.nil? ? 'NULL' : value_hash_as_column_or_question_mark}"
      end
    end

    class In < Base
      def to_positive_sql
        "#{@column_name} IN (#{value_hash_as_column_or_question_mark})"
      end

      def to_negative_sql
        "#{@column_name} NOT IN (#{value_hash_as_column_or_question_mark})"
      end

      def to_conditions
        # For NOT IN conditions, passing an empty array as the value will
        # produce a condition like "WHERE id NOT IN (NULL)", and that will
        # return an empty set, which is presumably not what the user meant
        # to get. Doing some babysitting here.
        if subquery?
          [to_sql]
        elsif @negated && @value.respond_to?(:empty?) && @value.empty?
          []
        else
          [to_sql, @value]
        end
      end

      def value_hash_as_column_or_question_mark
        if subquery?
          @value.to_subquery(false)
        else
          super
        end
      end
    end

    class Between < Base
      def to_conditions
        ["#{@column_name} #{'NOT ' if @negated}BETWEEN ? AND ?", @value.first, @value.last]
      end
    end

    class Like < Base
      def to_positive_sql
        "#{@column_name} LIKE #{value_hash_as_column_or_question_mark}"
      end

      def to_negative_sql
        "#{@column_name} NOT LIKE #{value_hash_as_column_or_question_mark}"
      end
    end
  end
end
