module RecordFilter
  module DSL
    # This class is used as the active DSL when executing the block provided to explicit
    # joins created with ConjunctionDSL.join. It is a subclass of ConjunctionDSL that
    # adds a method for specifying how the join is to be performed by giving either a pair
    # of columns or a restriction that is applied to a column of the right table.
    class JoinDSL < ConjunctionDSL

      attr_reader :conditions # :nodoc:

      # Specify parameters for explicit joins. This method should be called at least once
      # within the block of a call to ConjunctionDSL.join and accepts various combinations
      # of arguments to determine how to join the two tables. The possible options are:
      #
      # * Pass a hash where the key is a symbol that represents a column in the left table and the value is a symbol that represents a column in the right table.
      # * Pass a symbol and a value, in which case an equality condition will be created on the column in the right table with the given column name.
      # * Pass only the name of a column in the right table, in which case the method can be chained with any of the calls in the Restriction API to create generic restrictions on the column.
      #   Post.filter do
      #     join(Comment, :inner) do
      #       on(:id => :post_id)
      #       on(:offensive, false)
      #       on(:id).greater_than(12)
      #     end
      #
      #     # Results in:
      #     # :joins => "INNER JOIN "comments" AS posts__Comment ON "posts".id = posts__Comment.post_id AND posts__Comment.offensive = false AND posts__Comment.id > 12"
      #   end
      #
      # ==== Parameters
      # column<Hash, Symbol>::
      #   Either a hash representing the column pair to join or a symbol representing the column in the
      #   right table to add a condition to.
      # value<value, optional>::
      #   If provided along with a symbol for the column argument, creates an equality condition on that
      #   column.
      #
      # ==== Returns
      # Restriction::
      #   A restriction that can be used to limit the column when a symbol is passed as the column name.
      #
      # @public
      def on(column, value=Restriction::DEFAULT_VALUE)
        @conditions ||= []
        @conditions << (condition = JoinCondition.new(column, value))
        return condition.restriction
      end
    end
  end
end
