module RecordFilter
  class RestrictionFactory # :nodoc: all

    OPERATOR_HASH = {
      :equal_to => Restrictions::EqualTo,
      :is_null => Restrictions::IsNull,
      :less_than => Restrictions::LessThan,
      :less_than_or_equal_to => Restrictions::LessThanOrEqualTo,
      :greater_than => Restrictions::GreaterThan,
      :greater_than_or_equal_to => Restrictions::GreaterThanOrEqualTo,
      :in => Restrictions::In,
      :between => Restrictions::Between,
      :like => Restrictions::Like
    }

    def self.build(operator, column_name, value, options)
      OPERATOR_HASH[operator].new(column_name, value, options)
    end
  end
end

