module RecordFilter
  module Joins
    class ImplicitJoin
      def initialize(model_class, association_name)
        @association_name = association_name
        association = model_class.reflect_on_association(association_name)
        @model_class = model_class
        @join_model_class = association
        @join_predicate = { association.primary_key_name.to_sym => :id }
      end

      def to_sql
        predicate_sql = @join_predicate.map do |column, join_column|
          "#{@model_class.table_name}.#{column} = #{@join_model_class.table_name}.#{join_column}"
        end * ' AND '
        "INNER JOIN #{@join_model_class.table_name} ON #{predicate_sql}"
      end
    end
  end
end
