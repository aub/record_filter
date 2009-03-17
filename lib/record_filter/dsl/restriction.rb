module RecordFilter
  module DSL
    class Restriction
      def initialize(column_name, conjunction)
        @column_name, @conjunction = column_name, conjunction
      end

      RecordFilter::Restrictions.constants.each do |constant|
        method_name = constant.underscore
        module_eval(<<-RUBY, __FILE__, __LINE__ + 1)
          def #{method_name}(value)
            @conjunction.add(@column_name, RecordFilter::Restrictions::#{constant}, value)
          end
        RUBY
      end
    end
  end
end
