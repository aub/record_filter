module RecordFilter
  module DSL
    class DSL < ConjunctionDSL

      SUBCLASSES = Hash.new do |h, k|
        h[k] = Class.new(DSL)
      end

      class << self
        def create(clazz)
          subclass(clazz).new(clazz)
        end

        def subclass(clazz)
          SUBCLASSES[clazz.name.to_sym]
        end
      end

      # This method can take two forms:
      # limit(offset, limit), or
      # limit(limit)
      def limit(offset_or_limit, limit=nil)
        if limit
          @conjunction.add_limit(limit, offset_or_limit)
        else
          @conjunction.add_limit(offset_or_limit, nil)
        end
        nil
      end

      # This method can take two forms, as shown below.
      # order :permalink
      # order :permalink, :desc
      # order :photo => :path, :desc
      # order :photo => { :comment => :id }, :asc
      def order(column, direction=:asc)
        @conjunction.add_order(column, direction)
        nil
      end

      def group_by(column)
        @conjunction.add_group_by(column)
        nil
      end
    end
  end
end
