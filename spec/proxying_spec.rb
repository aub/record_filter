require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'proxying to the found data' do
  before do
    TestModel.extended_models.each { |model| model.last_find = {} }
  end

  describe 'calling first and last on a filter result' do
    before do
      Blog.all.each { |b| b.destroy }
      @blog = Class.new(Blog)
      @blog.named_filter(:by_name) do
        order(:name)
      end
      @blog1 = @blog.create(:name => 'a')
      @blog2 = @blog.create(:name => 'b')
      @blog3 = @blog.create(:name => 'c')
    end
    
    it 'should return the first element in the result correctly' do
      @blog.by_name.first.should == @blog1
    end

    it 'should return the last element in the result correctly' do
      @blog.by_name.last.should == @blog3
    end

    it 'should proxy arguments through' do
      @blog.by_name.first(:conditions => ['name = ?', 'b']).should == @blog2
    end
  end

  describe 'calling reject! on a filter result' do
    before do
      Blog.all.each { |b| b.destroy }
      @blog = Class.new(Blog)
      @blog.named_filter(:by_name) do
        order(:name)
      end
      @blog1 = @blog.create
      @blog2 = @blog.create
    end

    it 'should remove the rejected items from the list' do
      items = @blog.by_name
      items.size.should == 2
      items.reject! { |i| true } # should reject them all
      items.size.should == 0
    end
  end
end
