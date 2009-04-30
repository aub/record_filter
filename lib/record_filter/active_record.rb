module RecordFilter
  # The ActiveRecordExtension module is mixed in to ActiveRecord::Base to form the
  # top-level API for interacting with record_filter. It adds public methods for
  # executing ad-hoc filters as well as for creating and querying named filters.
  module ActiveRecordExtension
    module ClassMethods

      # Execute an ad-hoc filter  
      #
      # ==== Parameters
      # block::
      #   A block that specifies the contents of the filter.
      #
      # ==== Returns
      # Filter:: The Filter object resulting from the query, which can be
      #   treated as an array of the results.
      #
      # ==== Example
      # Blog.filter do
      #   having(:posts).with(:name, nil)
      # end
      #—
      # @public
      def filter(&block)
        Filter.new(self, nil, &block)
      end

      def named_filter(name, &block)
        return if named_filters.include?(name.to_sym)
        local_named_filters << name.to_sym 
        DSL::DSL::subclass(self).module_eval do
          define_method(name, &block)
        end

        (class << self; self; end).instance_eval do
          define_method(name.to_s) do |*args|
            Filter.new(self, name, *args)
          end
        end
      end

      def named_filters
        result = local_named_filters.dup
        result.concat(superclass.named_filters) if (superclass && superclass.respond_to?(:named_filters))
        result
      end

      protected

      def local_named_filters
        @local_named_filters ||= []
      end
    end
  end
end

ActiveRecord::Base.send(:extend, RecordFilter::ActiveRecordExtension::ClassMethods)

