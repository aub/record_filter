module RecordFilter
  class Table
    attr_reader :table_alias, :orders, :group_bys

    def initialize(model_class, table_alias = nil)
      @model_class = model_class
      @aliased = !table_alias.nil?
      @table_alias = table_alias || model_class.quoted_table_name
      @joins_cache = {}
      @joins = []
      @orders = []
      @group_bys = []
    end

    def table_name
      @model_class.quoted_table_name
    end

    def join_association(association_name)
      @joins_cache[association_name] ||=
        begin
          association = @model_class.reflect_on_association(association_name)
          if association.nil?
            raise AssociationNotFoundException.new("The association #{association_name} was not found on #{@model_class.name}.")
          end
          case association.macro
          when :belongs_to, :has_many, :has_one
            simple_join(association)
          when :has_and_belongs_to_many
            compound_join(association)
          end
        end
    end

    def join_table(table_name, table_alias, columns)
      join_table = Table.new(table_name.to_s.classify.constantize, table_alias)
      @joins << join = Join.new(self, join_table, columns)
      join
    end

    def all_joins
      @joins + @joins.inject([]) do |child_joins, join|
        child_joins.concat(join.right_table.all_joins)
        child_joins
      end
    end

    def order_column(column, direction)
      @orders << Order.new(column, direction, self)
    end

    def group_by_column(column)
      @group_bys << GroupBy.new(column, self)
    end

    def has_column(column_name)
      @model_class.column_names.include?(column_name.to_s)
    end

    private

    def simple_join(association)
      join_predicate =
        case association.macro
        when :belongs_to
          { association.primary_key_name.to_sym => :id }
        when :has_many, :has_one
          { :id => association.primary_key_name.to_sym }
        end
      join_table = Table.new(association.klass, alias_for_association(association))
      @joins << join = Join.new(self, join_table, join_predicate)
      join
    end

    def compound_join(association)
      pivot_join_predicate = { :id => association.primary_key_name.to_sym }
      table_name = @model_class.connection.quote_table_name(association.options[:join_table])
      pivot_table = PivotTable.new(table_name, "__#{alias_for_association(association)}")
      pivot_join = Join.new(self, pivot_table, pivot_join_predicate)
      join_predicate = { association.association_foreign_key => :id }
      join_table = Table.new(association.klass, alias_for_association(association))
      pivot_table.joins << join = Join.new(pivot_table, join_table, join_predicate)
      @joins << pivot_join
      join
    end

    protected

    def alias_for_association(association)
      "#{@aliased ? @table_alias.to_s : @model_class.table_name}__#{association.name}"
    end
  end

  class PivotTable < Table
    attr_reader :table_name, :joins

    def initialize(table_name, table_alias = table_name)
      @table_name, @table_alias = table_name, table_alias
      @joins_cache = {}
      @joins = []
      @orders = []
      @group_bys = []
    end
  end
end
