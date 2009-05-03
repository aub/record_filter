module RecordFilter
  # The ActiveRecordExtension module is mixed in to ActiveRecord::Base to form the
  # top-level API for interacting with record_filter. It adds public methods for
  # executing ad-hoc filters as well as for creating and querying named filters.
  # See RecordFilter::ActiveRecordExtension::ClassMethods for more detail on the
  # API.
  module ActiveRecordExtension
    module ClassMethods

      # Execute an ad-hoc filter. See the documentation for RecordFilter::DSL
      # for more information on how to specify the filter.
      #
      # ==== Parameters
      # block::
      #   A block that specifies the contents of the filter.
      #
      # ==== Returns
      # Filter:: 
      #   The Filter object resulting from the query, which can be treated as an array of the results.
      #
      # ==== Example
      #   Blog.filter do
      #     having(:posts).with(:name, nil)
      #   end
      #
      # @public
      def filter(&block)
        Filter.new(self, nil, &block)
      end

      # Create a new named filter, which defines a function on the callee class that provides easy
      # access to the query defined by the filter. Any number of named filters can be created on a
      # class, and they can also be chained to create complex queries out of simple building blocks.
      # In addition, named filters can accept any number of arguments in order to allow customization
      # of their behavior when used. For more details on how to specify the contents of named filters,
      # see the documentation for RecordFilter::DSL.
      #
      #   Post.named_filter(:without_permalink) do
      #     with(:permalink, nil)
      #   end
      #
      #   Post.named_filter(:created_after) do |time|
      #     with(:created_at).gt(time)
      #   end
      #
      #   Post.without_permalink                             # :conditions => ['permalink IS NULL']
      #   Post.created_after(3.hours.ago)                    # :conditions => ['created_at > ?', 3.hours.ago]
      #   Post.without_permalink.created_after(3.hours.ago)  # :conditions => ['permalink IS NULL AND created_at > ?', 3.hours.ago]
      #
      # @public
      def named_filter(name, &block)
        return if named_filters.include?(name.to_sym)
        local_named_filters << name.to_sym 
        DSL::DSLFactory::subclass(self).module_eval do
          define_method(name, &block)
        end

        (class << self; self; end).instance_eval do
          define_method(name.to_s) do |*args|
            Filter.new(self, name, *args)
          end
        end
      end

      # Retreive a list of named filters that apply to a specific class, including ones
      # that were defined in its superclasses.
      #
      # ==== Returns
      # Array:: A list of the names of the named filters, as symbols. 
      #
      # @public
      def named_filters
        result = local_named_filters.dup
        result.concat(superclass.named_filters) if (superclass && superclass.respond_to?(:named_filters))
        result
      end

      protected
      
      def local_named_filters # :nodoc:
        @local_named_filters ||= []
      end
    end
  end
end

ActiveRecord::Base.send(:extend, RecordFilter::ActiveRecordExtension::ClassMethods)

