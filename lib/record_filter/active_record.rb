module RecordFilter
  module ActiveRecordExtension
    module ClassMethods
      def filter(&block)
        query = RecordFilter::Query.new(RecordFilter::Table.new(self))
        DSL::Conjunction.new(query.base_restriction).instance_eval(&block)
        all(query.to_find_params)
      end
    end
  end
end

ActiveRecord::Base.send(:extend, RecordFilter::ActiveRecordExtension::ClassMethods)
