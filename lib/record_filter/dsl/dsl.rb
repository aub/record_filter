module RecordFilter
  module DSL
    class DSL

      attr_reader :conjunction

      SUBCLASSES = Hash.new do |h, k|
        h[k] = Class.new(DSL)
      end

      class << self
        def create(clazz)
          subclass(clazz).new
        end

        def subclass(clazz)
          SUBCLASSES[clazz.name.to_sym]
        end
      end

      def initialize(conjunction=Conjunction.new(:all_of))
        @conjunction = conjunction
      end

      # restriction
      def with(column, value=Conjunction::DEFAULT_VALUE)
        return @conjunction.add_restriction(column, value, false) # using return just to make it explicit
      end

      # restriction
      def without(column, value=Conjunction::DEFAULT_VALUE)
        return @conjunction.add_restriction(column, value, true) # using return just to make it explicit
      end

      # conjunction
      def any_of(&block)
        @conjunction.add_conjunction(:any_of, &block)
        nil
      end

      # conjunction
      def all_of(&block)
        @conjunction.add_conjunction(:all_of, &block)
        nil
      end

      # join
      def having(column, &block)
        junk = @conjunction.add_join(column, &block)
        DSL.new(junk.conjunction)
      end
    end
  end
end
