module RecordFilter
  module Restrictions
    class Base
      def initialize(column_name, value, options={})
        @column_name, @value = column_name, value
        @negated = options[:negated]
      end

      def to_conditions
        @value.nil? ? [to_sql] : [to_sql, @value]
      end
    end

    class EqualTo < Base
      def to_sql
        "#{@column_name} #{'!' if @negated}= ?"
      end
    end

    class IsNull < Base
      def to_sql
        "#{@column_name} IS #{'NOT ' if @negated}NULL"
      end
    end

    class LessThan < Base
      def to_sql
        @negated ? "!(#{@column_name} < ?)" : "#{@column_name} < ?"
      end
    end

    class GreaterThan < Base
      def to_sql
        @negated ? "!(#{@column_name} > ?)" : "#{@column_name} > ?"
      end
    end

    class In < Base
      def to_sql
        "#{@column_name} #{'NOT ' if @negated}IN (?)"
      end
    end

    class Between < Base
      def to_conditions
        ["#{@column_name} #{'NOT ' if @negated}BETWEEN ? AND ?", @value.first, @value.last]
      end
    end
  end
end
