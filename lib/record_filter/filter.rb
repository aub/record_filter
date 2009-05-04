module RecordFilter
  # This class is the value that is returned from the execution of a filter.
  class Filter

    NON_DELEGATE_METHODS = %w(nil? send object_id class extend find size count sum average maximum minimum paginate first last empty? any? respond_to?)

    [].methods.each do |m|
      unless m =~ /^__/ || NON_DELEGATE_METHODS.include?(m.to_s)
        delegate m, :to => :loaded_data
      end
    end

    def initialize(clazz, named_filter, *args, &block) # :nodoc:
      @current_scoped_methods = clazz.send(:current_scoped_methods)
      @clazz = clazz

      @query = Query.new(@clazz, named_filter, *args, &block)
    end

    def first(*args) # :nodoc:
      do_with_scope do
        @clazz.find(:first, *args)
      end
    end

    def last(*args) # :nodoc:
      do_with_scope do
        @clazz.find(:last, *args)
      end
    end

    def size # :nodoc:
      @loaded_data ? @loaded_data.length : count
    end

    def empty? # :nodoc:
      @loaded_data ? @loaded_data.empty? : count.zero?
    end

    def any? # :nodoc:
      if block_given?
        loaded_data.any? { |*block_args| yield(*block_args) }
      else
        !empty?
      end
    end

    def filter(&block)
      do_with_scope do
        Filter.new(@clazz, nil, &block)
      end
    end

    def proxy_options(count_query=false)
      @query.to_find_params(count_query)
    end

    protected

    def method_missing(method, *args, &block) # :nodoc:
      if @clazz.named_filters.include?(method)
        do_with_scope do
          Filter.new(@clazz, method, *args)
        end
      else
        do_with_scope(method == :count) do
          @clazz.send(method, *args, &block)
        end
      end
    end

    def do_with_scope(count_query=false, &block) # :nodoc:
      @clazz.send(:with_scope, { :find => proxy_options(count_query), :create => proxy_options(count_query) }, :reverse_merge) do
        if @current_scoped_methods
          @clazz.send(:with_scope, @current_scoped_methods) do
            block.call
          end
        else
          block.call
        end
      end
    end

    def loaded_data # :nodoc:
      @loaded_data ||= do_with_scope do
        @clazz.find(:all)
      end
    end
  end
end
