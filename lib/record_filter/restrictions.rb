module RecordFilter
  module Restrictions
    class Base
      def initialize(column_name, value)
        @column_name, @value = column_name, value
      end

      def to_conditions
        [to_sql, @value]
      end
    end

    class EqualTo < Base
      def to_sql
        "#{@column_name} = ?"
      end
    end

    class LessThan < Base
      def to_sql
        "#{@column_name} < ?"
      end
    end

    class GreaterThan < Base
      def to_sql
        "#{@column_name} > ?"
      end
    end

    class In < Base
      def to_sql
        "#{@column_name} IN (?)"
      end
    end

    class Between < Base
      def to_conditions
        ["#{@column_name} BETWEEN ? AND ?", @value.first, @value.last]
      end
    end
  end
end
