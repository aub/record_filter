require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'explicit joins' do
  before do
    TestModel.extended_models.each { |model| model.last_find = {} }
  end

  describe 'specifying a simple join' do
    before do
      Post.filter do
        left_join(:blogs, :posts_blogs, :blog_id => :id) do
          with(:name, 'Test Name')
        end
      end.inspect
    end

    it 'should add correct join' do
      Post.last_find[:joins].should == %q(INNER JOIN "blogs" AS posts_blogs ON "posts".blog_id = posts_blogs.id)
    end

    it 'should query against condition on join table' do
      Post.last_find[:conditions].should == ['posts_blogs.name = ?', 'Test Name']
    end
  end

  describe 'specifying a complex join through polymorphic associations' do
    before do
      Review.filter do
        left_join(:features, :reviews_features, :reviewable_id => :featurable_id, :reviewable_type => :featurable_type) do
          with(:priority, 5)
        end
      end.inspect
    end

    it 'should add correct join' do
      matched_one = Review.last_find[:joins] == %q(INNER JOIN "features" AS reviews_features ON "reviews".reviewable_id = reviews_features.featurable_id AND "reviews".reviewable_type = reviews_features.featurable_type)
      matched_one ||= Review.last_find[:joins] == %q(INNER JOIN "features" AS reviews_features ON "reviews".reviewable_type = reviews_features.featurable_type AND "reviews".reviewable_id = reviews_features.featurable_id)

      matched_one.should == true
    end

    it 'should query against condition on join table' do
      Review.last_find[:conditions].should == ['reviews_features.priority = ?', 5]
    end
  end
end
