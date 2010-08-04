require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'explicit subqueries' do
  before :each do
    TestModel.extended_models.each { |model| model.last_find = {} }
  end

  after :each do
    Blog.last_find.should be_empty
  end

  describe 'IN subquery' do
    it 'should generate an explicit subquery on ID field' do
      Post.filter do
        with(:blog_id).in(Blog.filter { with(:name, 'Test Name') })
      end.inspect
      Post.last_find[:conditions].should == 
        [%q("posts".blog_id IN (SELECT "blogs".id FROM "blogs" WHERE ("blogs".name = 'Test Name') ))]
    end

    it 'should generate an explicit subquery on selected field' do
      Post.filter do
        with(:blog_id).in(Blog.filter { select(:name) ; with(:name, 'Test Name') })
      end.inspect
      Post.last_find[:conditions].should == 
        [%q("posts".blog_id IN (SELECT "blogs".name FROM "blogs" WHERE ("blogs".name = 'Test Name') ))]
    end

    it 'should perform a negated subquery' do
      Post.filter do
        with(:blog_id).not.in(Blog.filter { with(:name, 'Test Name') })
      end.inspect
      Post.last_find[:conditions].should ==
        [%q("posts".blog_id NOT IN (SELECT "blogs".id FROM "blogs" WHERE ("blogs".name = 'Test Name') ))]
    end

    it 'should fail fast if subselect performed with multiple select fields' do
      lambda do
        Post.filter do
          with(:blog_id).in(Blog.filter { select(:id, :name) ; with(:name, 'Test Name') })
        end.inspect
      end.should raise_error(RecordFilter::InvalidFilterException)
    end
  end

  describe 'equality subquery' do
    it 'should perform subquery and implicitly add limit' do
      Post.filter do
        with(:blog_id, Blog.filter { with(:name, 'Test Name') })
      end.inspect
      Post.last_find[:conditions].should == 
        [%q("posts".blog_id = (SELECT "blogs".id FROM "blogs" WHERE ("blogs".name = 'Test Name')  LIMIT 1))]
    end
  end
end
