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
  end
end
