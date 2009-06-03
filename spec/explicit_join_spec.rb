require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'explicit joins' do
  before do
    TestModel.extended_models.each { |model| model.last_find = {} }
  end

  describe 'specifying a simple join' do
    before do
      Post.filter do
        join(Blog, :left, :posts_blogs) do
          on(:blog_id => :id)
          with(:name, 'Test Name')
        end
      end.inspect
    end

    it 'should add correct join' do
      Post.last_find[:joins].should == [%q(LEFT OUTER JOIN "blogs" AS posts_blogs ON "posts".blog_id = posts_blogs.id)]
    end

    it 'should query against condition on join table' do
      Post.last_find[:conditions].should == ['posts_blogs.name = ?', 'Test Name']
    end
  end

  describe 'specifying a complex join through polymorphic associations' do
    before do
      Review.filter do
        join(Feature, :left, :reviews_features) do
          on(:reviewable_id => :featurable_id)
          on(:reviewable_type => :featurable_type)
          with(:priority, 5)
        end
      end.inspect
    end

    it 'should add correct join' do
      Review.last_find[:joins].should == [%q(LEFT OUTER JOIN "features" AS reviews_features ON "reviews".reviewable_id = reviews_features.featurable_id AND "reviews".reviewable_type = reviews_features.featurable_type)]
    end

    it 'should query against condition on join table' do
      Review.last_find[:conditions].should == ['reviews_features.priority = ?', 5]
    end
  end

  describe 'should use values as join parameters instead of columns if given' do
    before do
      Review.filter do
        join(Feature, :left) do
          on(:reviewable_id => :featurable_id)
          on(:reviewable_type => :featurable_type)
          on(:featurable_type, 'SomeType')
          with(:priority, 5)
        end
      end.inspect
    end

    it 'should add correct join' do
      Review.last_find[:joins].should == [%q(LEFT OUTER JOIN "features" AS reviews__feature ON "reviews".reviewable_id = reviews__feature.featurable_id AND "reviews".reviewable_type = reviews__feature.featurable_type AND (reviews__feature.featurable_type = 'SomeType'))]
    end
  end

  describe 'using restrictions on join conditions' do
    before do
      Review.filter do
        join(Feature, :left) do
          on(:featurable_type, nil)
          on(:featurable_id).gte(12)
          on(:priority).not(6)
        end
      end.inspect
    end

    it 'should add the correct join' do
      Review.last_find[:joins].should == [%q(LEFT OUTER JOIN "features" AS reviews__feature ON (reviews__feature.featurable_type IS NULL) AND (reviews__feature.featurable_id >= 12) AND (reviews__feature.priority <> 6))]
    end
  end

  describe 'using implicit and explicit joins together with conditions' do
    before do
      @blog = Class.new(Blog)
      @blog.named_filter :somethings do
        having(:ads) do
          with(:content, nil)
        end
        join(Post, :left) do
          on(:id => :blog_id)
          join(Comment, :inner) do
            on(:id => :post_id)
            on(:offensive, true)
          end
        end
        group_by(:id)
      end
      @blog.somethings.inspect
    end

    it 'should produce the correct conditions' do
      @blog.last_find[:conditions].should == [%q((blogs__ads.content IS NULL))]
    end

    it 'should produce the correct join' do
      @blog.last_find[:joins].should == [%q(INNER JOIN "ads" AS blogs__ads ON "blogs".id = blogs__ads.blog_id), %q(LEFT OUTER JOIN "posts" AS blogs__post ON "blogs".id = blogs__post.blog_id), %q(INNER JOIN "comments" AS blogs__post__comment ON blogs__post.id = blogs__post__comment.post_id AND (blogs__post__comment.offensive = 't'))]
    end
  end

  describe 'using the same join multiple times' do
    before do
      @blog = Class.new(Blog)
      @blog.named_filter(:things) do
        join(Post, :inner, 'blogs_posts_1') do
          on(:id => :blog_id)
          with(:title, 'ack')
        end
        join(Post, :inner, 'blogs_posts_2') do
          on(:id => :blog_id)
          with(:title, 'hmm')
        end
      end
      @blog.things.inspect
    end

    it 'should create the correct join' do
      @blog.last_find[:joins].should == [%q(INNER JOIN "posts" AS blogs_posts_1 ON "blogs".id = blogs_posts_1.blog_id), %q(INNER JOIN "posts" AS blogs_posts_2 ON "blogs".id = blogs_posts_2.blog_id)] 
    end

    it 'should create the correct conditions' do
      @blog.last_find[:conditions].should == [%q((blogs_posts_1.title = ?) AND (blogs_posts_2.title = ?)), 'ack', 'hmm'] 
    end
  end
end
