module RecordFilter
  module Restrictions
    class Base
      def initialize(column_name, value, options={})
        @column_name, @value, @negated = column_name, value, !!options.delete(:negated)
      end

      def to_conditions
        @value.nil? ? [to_sql] : [to_sql, @value]
      end

      def to_sql
        @negated ? to_negative_sql : to_positive_sql
      end

      def to_negative_sql
        "!(#{to_positive_sql})"
      end
    end

    class EqualTo < Base
      def to_positive_sql
        "#{@column_name} = ?"
      end

      def to_negative_sql
        "#{@column_name} != ?"
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
        "#{@column_name} < ?"
      end
    end

    class GreaterThan < Base
      def to_positive_sql
        "#{@column_name} > ?"
      end
    end

    class In < Base
      def to_positive_sql
        "#{@column_name} IN (?)"
      end

      def to_negative_sql
        "#{@column_name} NOT IN (?)"
      end
    end

    class Between < Base
      def to_conditions
        ["#{@column_name} #{'NOT ' if @negated}BETWEEN ? AND ?", @value.first, @value.last]
      end
    end
  end
end
