module RecordFilter
  module ActiveRecordExtension
    module ClassMethods

      def filter(&block)
        Filter.new(self, nil, nil, &block)
      end

      def named_filter(name, &block)
        return if named_filters.include?(name.to_sym)
        named_filters << name.to_sym 
        DSL::DSL::subclass(self).module_eval do
          define_method(name, &block)
        end

        (class << self; self; end).instance_eval do
          define_method(name.to_s) do |*args|
            Filter.new(self, name, nil, *args)
          end
        end
      end

      def named_filters
        read_inheritable_attribute(:named_filters) || write_inheritable_attribute(:named_filters, [])
      end
    end
  end
end

ActiveRecord::Base.send(:extend, RecordFilter::ActiveRecordExtension::ClassMethods)
