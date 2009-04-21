require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'raising exceptions' do
  
  describe 'on missing associations' do
    it 'should get AssociationNotFoundException' do
      lambda {
        Post.filter do
          having(:something_that_does_not_exist) do
            with(:something_bad)
          end
        end.inspect
      }.should raise_error(RecordFilter::AssociationNotFoundException)
    end
  end

  describe 'on missing columns' do
    it 'should get ColumnNotFoundException for with' do
      lambda {
        Post.filter do
          with(:this_is_not_there, 2)
        end.inspect
      }.should raise_error(RecordFilter::ColumnNotFoundException)
    end

    it 'should get ColumnNotFoundException for without' do
      lambda {
        Post.filter do
          without(:this_is_not_there, 2)
        end.inspect
      }.should raise_error(RecordFilter::ColumnNotFoundException)
    end

    it 'should get ColumnNotFoundException for order' do
      lambda {
        Post.filter do
          order(:this_is_not_there, :asc)
        end.inspect
      }.should raise_error(RecordFilter::ColumnNotFoundException)
    end

    it 'should get AssociationNotFoundException for orders on bad associations' do
      lambda {
        Post.filter do
          order({ :this_is_not_there => :eh }, :asc)
        end.inspect
      }.should raise_error(RecordFilter::AssociationNotFoundException)
    end

    it 'should raise ColumnNotFoundException for explicit joins on bad column names for the right table' do
      lambda {
        Review.filter do
          left_join(:feature, :reviews_features, :reviewable_id => :ftrable_id, :reviewable_type => :ftrable_type) do
            with(:priority, 5)
          end
        end.inspect
      }.should raise_error(RecordFilter::ColumnNotFoundException)
    end

    it 'should raise ColumnNotFoundException for explicit joins on bad column names for the left table' do
      lambda {
        Review.filter do
          left_join(:feature, :reviews_features, :rvwable_id => :featurable_id, :rvwable_type => :featurable_type) do
            with(:priority, 5)
          end
        end.inspect
      }.should raise_error(RecordFilter::ColumnNotFoundException)
    end
  end
end
