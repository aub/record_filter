module RecordFilter
  class Table
    attr_reader :table_alias

    def initialize(model_class, table_alias = nil)
      @model_class = model_class
      @table_alias = table_alias || model_class.table_name
      @joins_cache = {}
      @joins = []
    end

    def table_name
      @model_class.table_name
    end

    def join_association(association_name)
      @joins_cache[association_name] ||=
        begin
          association = @model_class.reflect_on_association(association_name)
          case association.macro
          when :belongs_to, :has_many, :has_one
            simple_join(association)
          when :has_and_belongs_to_many
            compound_join(association)
          end
        end
    end

    def all_joins
      @joins + @joins.inject([]) do |child_joins, join|
        child_joins.concat(join.right_table.all_joins)
        child_joins
      end
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
      join_table = Table.new(association.klass, "#{table_alias.to_s}__#{association.name}")
      @joins << join = Join.new(self, join_table, join_predicate)
      join
    end

    def compound_join(association)
      pivot_join_predicate = { :id => association.primary_key_name.to_sym }
      pivot_table = PivotTable.new(association.options[:join_table], "__#{table_alias.to_s}__#{association.name}")
      pivot_join = Join.new(self, pivot_table, pivot_join_predicate)
      join_predicate = { association.association_foreign_key => :id }
      join_table = Table.new(association.klass, "#{table_alias.to_s}__#{association.name}")
      pivot_table.joins << join = Join.new(pivot_table, join_table, join_predicate)
      @joins << pivot_join
      join
    end
  end

  class PivotTable < Table
    attr_reader :table_name, :joins

    def initialize(table_name, table_alias = table_name)
      @table_name, @table_alias = table_name, table_alias
      @joins_cache = {}
      @joins = []
    end
  end
end
