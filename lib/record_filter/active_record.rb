module RecordFilter
  module ActiveRecordExtension
    module ClassMethods

      def filter(&block)
        query = RecordFilter::Query.new(RecordFilter::Table.new(self))
        DSL::Conjunction.create(self, query.base_restriction).instance_eval(&block)
        scoped(query.to_find_params)
      end

      def named_filter(name, &block)
        DSL::Conjunction::subclass(self).module_eval do
          define_method(name, &block)
        end

        (class << self; self; end).instance_eval do
          define_method(name.to_s) do |*args|
            Scope.new(self, name, nil, *args)
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send(:extend, RecordFilter::ActiveRecordExtension::ClassMethods)
