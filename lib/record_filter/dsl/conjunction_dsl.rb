module RecordFilter
  module DSL
    # The ConjunctionDSL is used for specifying restrictions, conjunctions and joins, with methods that
    # can be accessed from any point in a filter declaration. The where method is used for creating
    # restrictions, conjunctions are specified through any_of, all_of, none_of and not_all_of, and joins
    # are described by having and join.
    class ConjunctionDSL

      attr_reader :conjunction # :nodoc:

      def initialize(model_class, conjunction) # :nodoc:
        @model_class = model_class
        @conjunction = conjunction
      end

      # Specify a condition on the given column, which will be added to the WHERE clause
      # of the resulting query. This method returns a Restriction object, which can be called
      # with any of the specific restriction methods described there in order to create many
      # types of conditions. If both a column name and a value are passed, this will automatically
      # create an equality condition, so the following two examples are equal:
      #   with(:permalink, 'junk')
      #   with(:permalink).equal_to('junk')
      # If nil is passed as the second argument, an is_null restriction will automatically be
      # created, so these two examples are equal as well:
      #   with(:permalink, nil)
      #   with(:permalink).is_null
      # This method can be called at any point in the filter specification, and the appropriate
      # clauses will be created if it is called within or other conjunctions.
      #
      # ==== Parameters
      # column<Symbol>::
      #   The name of the column to restrict. The column is assumed to exist in the table that is
      #   currently in scope. In the outer block of a filter, that would be the table being filtered,
      #   and within joins it would be the table being joined.
      # value<value, optional>::
      #   If specified, the value will be used to automatically create either an equality restriction
      #   or an IS NULL test, as described above.
      #
      # ==== Returns
      # Restriction::
      #   A restriction object that can be used to create a specific condition. See the API in
      #   Restriction for options.
      #
      # ==== Alternatives
      # The value parameter is optional, as described above.
      #
      # @public
      def with(column, value=Restriction::DEFAULT_VALUE)
        return @conjunction.add_restriction(column, value)
      end

      # Add a where clause that will pass if any of the conditions specified within it
      # are true.  Any restrictions created inside the given block are OR'ed together
      # in the final query, and the block can contain any number of joins, restrictions, or
      # other conjunctions.
      #   Blog.filter do
      #     any_of do
      #       with(:created_at, nil)
      #       with(:created_at).greater_than(3.days.ago)
      #     end
      #   end
      #
      #   # :conditions => { ['blogs.created_at IS NULL OR blogs.created_at > ?', 3.days.ago] }
      #
      # ==== Parameters
      # block<Proc>::
      #   The block can contain any sequence of calls, and the conditions that it contains will be
      #   OR'ed together to create a where clause.
      #
      # ==== Returns
      # nil
      #
      # @public
      def any_of(&block)
        @conjunction.add_conjunction(:any_of, &block)
        nil
      end

      # Add a where clause that will pass only if all of the conditions specified within it
      # are true.  Any restrictions created inside the given block are AND'ed together
      # in the final query, and the block can contain any number of joins, restrictions, or
      # other conjunctions.
      #   Blog.filter do
      #     all_of do
      #       with(:created_at, nil)
      #       with(:created_at).greater_than(3.days.ago)
      #     end
      #   end
      #
      #   # :conditions => { ['blogs.created_at IS NULL AND blogs.created_at > ?', 3.days.ago] }
      #
      # ==== Parameters
      # block<Proc>::
      #   The block can contain any sequence of calls, and the conditions that it contains will be
      #   AND'ed together to create a where clause.
      #
      # ==== Returns
      # nil
      #
      # @public
      def all_of(&block)
        @conjunction.add_conjunction(:all_of, &block)
        nil
      end

      # Add a where clause that will pass only if none of the conditions specified within it
      # are true.  Any restrictions created inside the given block are OR'ed together
      # in the final query and the result is negated. The block can contain any number of joins, 
      # restrictions, or other conjunctions.
      #   Blog.filter do
      #     none_of do
      #       with(:created_at, nil)
      #       with(:created_at).greater_than(3.days.ago)
      #     end
      #   end
      #
      #   # :conditions => { ['NOT (blogs.created_at IS NULL OR blogs.created_at > ?)', 3.days.ago] }
      #
      # ==== Parameters
      # block<Proc>::
      #   The block can contain any sequence of calls, and the conditions that it contains will be
      #   OR'ed together and then negated to create a where clause.
      #
      # ==== Returns
      # nil
      #
      # @public
      def none_of(&block)
        @conjunction.add_conjunction(:none_of, &block)
        nil
      end

      # Add a where clause that will pass unless all of the conditions specified within it
      # are true.  Any restrictions created inside the given block are AND'ed together
      # in the final query and the result is negated. The block can contain any number of joins, 
      # restrictions, or other conjunctions.
      #   Blog.filter do
      #     none_of do
      #       with(:created_at, nil)
      #       with(:created_at).greater_than(3.days.ago)
      #     end
      #   end
      #
      #   # :conditions => { ['NOT (blogs.created_at IS NULL AND blogs.created_at > ?)', 3.days.ago] }
      #
      # ==== Parameters
      # block<Proc>::
      #   The block can contain any sequence of calls, and the conditions that it contains will be
      #   AND'ed together and then negated to create a where clause.
      #
      # ==== Returns
      # nil
      #
      # @public
      def not_all_of(&block)
        @conjunction.add_conjunction(:not_all_of, &block)
        nil
      end

      # Create an implicit join using an association as the target. This method allows you to
      # easily specify a join without specifying the columns to use by taking any needed data
      # from the given ActiveRecord association. If provided, the block will be evaluated in
      # the context of the table that has been joined, so any restrictions or other joins will
      # be performed using its columns and associations. For example, if a Post has_many comments
      # then the following code will join to the comments table and restrict the comments based
      # on their created_at field:
      #   Post.filter do
      #     having(:comments) do
      #       with(:created_at).greater_than(3.days.ago)
      #     end
      #   end
      # Options can be passed to provide a custom join type or table alias through the options
      # hash. The :join_type option can be either :inner, :left or :right and will default to
      # :inner if not provided. The :alias option allows you to provide an alias for use in joining
      # the table. If the same association is joined twice with different aliases, it will be treated
      # as two separate joins. By default an alias will automatically be created
      # for the joined table named "#{left_table}__#{association_name}", so in the above example, the
      # alias would be posts__comments. It is also possible to provide a hash as the association
      # name, in which case a trail of associations can be joined in one statment.
      #
      # ==== Parameters
      # association<Symbol>::
      #   The name of the association to use as a base for the join.
      # options<Hash>::
      #   An options hash (see below)
      #
      # ==== Options (options)
      # :join_type<Symbol>::
      #   The type of join to use. Available options are :inner, :left and :right. Defaults to :inner.
      # :alias<String>::
      #   An alias to use for the table name in the join. If provided, will create a unique name for
      #   the join and allow the same association to be joined multiple times. By default, the alias
      #   will be "#{left_table}__#{association_name}".
      #
      # ==== Returns
      # ConjunctionDSL::
      #   A DSL object is returned in order to allow constructs like: having(:comments).with(:offensive, true)
      #
      # ==== Alternatives
      # If only one argument is given, the join type will default to :inner and the first argument will
      # be used as the association name.
      #
      # @public
      def having(association, options={}, &block)
        @conjunction.add_join(association, options[:join_type], options[:alias], &block)
      end

      # Create an explicit join on the table of the given class. This method allows more complex
      # joins to be speficied than can be created using having, including jump joins and ones that
      # include conditions on column values. The method accepts a block that can contain any sequence
      # of conjunctions, restrictions, or other joins, but it must also contain at least one call to
      # JoinDSL.on to specify the conditions for the join.
      #
      # ==== Parameters
      # clazz<Class>::
      #   The class that is being joined to.
      # join_type<Symbol>::
      #   Indicates the type of join to use and must be one of :inner, :left or :right, where :left
      #   or :right will create a LEFT or RIGHT OUTER join respectively.
      # table_alias<String, optional>::
      #   If provided, will specify an alias to use in the SQL when referring to the joined table.
      #   If the argument is not given, the alias will be "#{left_table}__#{clazz.name}"
      # block<Proc>
      #   The contents of the join block can contain any sequence of conjunctions, restrictions, or joins.
      #
      # ==== Returns
      # JoinDSL::
      #   A DSL object that can be used to specify the contents of the join. Returning this value allows
      #   for constructions like: join(Comment, :inner).on(:id => :post_id)
      #
      # @public
      def join(clazz, join_type, table_alias=nil, &block)
        @conjunction.add_class_join(clazz, join_type, table_alias, &block)
      end

      # Access the class that the current filter is being applied to. This is necessary
      # because the filter is evaluated in the context of the DSL object, so self will
      # not give access to any methods that need to be called on the filtered class.
      # It is especially useful in named filters that may be defined in a way that allows
      # them to apply to multiple classes.
      #
      # ==== Returns
      # Class::
      #   The class that is currently being filtered.
      #
      # @public
      def filter_class
        @model_class
      end
      
      # Enable calling of named filters from within other filters by catching unknown calls
      # and assuming that they are to named filters. This enables the following examples:
      #   class Post < ActiveRecord::Base
      #     has_many :comments
      #     named_filter(:empty) { with(:contents).nil }
      #   end
      #
      #   class Comment < ActiveRecord::Base
      #     belongs_to :post
      #     named_filter(:offensive) { |value| with(:offensive, value) }
      #   end
      #
      #   Post.filter do
      #     with(:created_at).less_than(1.hour.ago)
      #     empty
      #   end
      #
      #   # Results in:
      #   # :conditions => { ['posts.created_at < ? AND posts.contents IS NULL', 1.hour.ago] }
      #   # And even cooler:
      #
      #   Post.filter do
      #     having(:comments).offensive(true)
      #   end
      #
      #   # Results in:
      #   # :conditions => { ['posts__comments.offensive = ?', true] }
      #   # :joins => { 'INNER JOIN "comments" AS posts__comments ON "posts".id = posts__comments.post_id' }
      #
      # ==== Parameters
      # args<Array>::
      #   The arguments to pass to the named filter when called.
      #
      # @public
      def method_missing(method, *args)
        @conjunction.add_named_filter(method, *args)
      end

      #
      # Define these_methods here just so that we can throw exceptions when they are called. They should not
      # be callable in the scope of a conjunction_dsl.
      #
      def limit(offset_or_limit, limit=nil) # :nodoc:
        raise InvalidFilterException.new('Calls to limit can only be made in the outer block of a filter.')
      end

      def order(column, direction=:asc) # :nodoc:
        raise InvalidFilterException.new('Calls to order can only be made in the outer block of a filter.')
      end

      def group_by(column) # :nodoc:
        raise InvalidFilterException.new('Calls to group_by can only be made in the outer block of a filter.')
      end

      def on(column, value=Restriction::DEFAULT_VALUE) # :nodoc:
        raise InvalidFilterException.new('Calls to on can only be made in the block of a call to join.')
      end
    end
  end
end
