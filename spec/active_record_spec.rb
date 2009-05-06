require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'active record options' do
  before do
    TestModel.extended_models.each { |model| model.last_find = {} }
  end

  describe 'for has_many' do
    describe 'using class_name' do
      before do
        Blog.filter do
          having(:stories).with(:permalink, 'ack')
        end.inspect
      end

      it 'should create the correct condition' do
        Blog.last_find[:conditions].should == [%q(blogs__stories.permalink = ?), 'ack']
      end

      it 'should create the correct join' do
        Blog.last_find[:joins].should == [%q(INNER JOIN "news_stories" AS blogs__stories ON "blogs".id = blogs__stories.blog_id)]
      end
    end

    describe 'using foreign_key' do
      before do
        Blog.filter do
          having(:special_posts).with(:permalink, 'eek')
        end.inspect
      end

      it 'should create the correct condition' do
        Blog.last_find[:conditions].should == [%q(blogs__special_posts.permalink = ?), 'eek']
      end

      it 'should create the correct join' do
        Blog.last_find[:joins].should == [%q(INNER JOIN "posts" AS blogs__special_posts ON "blogs".id = blogs__special_posts.special_blog_id)]
      end
    end

    describe 'using primary_key' do
      before do
        Blog.filter do
          having(:special_public_posts).with(:permalink, 'oooh')
        end.inspect
      end

      it 'should create the correct condition' do
        Blog.last_find[:conditions].should == [%q(blogs__special_public_posts.permalink = ?), 'oooh']
      end

      it 'should create the correct join' do
        Blog.last_find[:joins].should == [%q(INNER JOIN "posts" AS blogs__special_public_posts ON "blogs".special_id = blogs__special_public_posts.blog_id)]
      end
    end

    describe 'using source' do
      before do
        Blog.filter do
          having(:nasty_comments).with(:contents, 'blammo')
        end.inspect
      end

      it 'should create the correct condition' do
        Blog.last_find[:conditions].should == [%q(blogs__posts__bad_comments.contents = ?), 'blammo']
      end

      it 'should create the correct join' do
        Blog.last_find[:joins].should == [%q(INNER JOIN "posts" AS blogs__posts ON "blogs".id = blogs__posts.blog_id), %q(INNER JOIN "comments" AS blogs__posts__bad_comments ON blogs__posts.id = blogs__posts__bad_comments.post_id)]
      end
    end

    describe 'using source_type' do
      before do
        Blog.filter do
          having(:featured_posts).with(:permalink, 'slam dunk')
        end.inspect
      end

      it 'should create the correct condition' do
        Blog.last_find[:conditions].should == [%q(blogs__features__featurable.permalink = ?), 'slam dunk']
      end

      it 'should create the correct join' do
        Blog.last_find[:joins].should == [%q(INNER JOIN "features" AS blogs__features ON "blogs".id = blogs__features.blog_id AND (blogs__features.featurable_type = 'Post')), %q(INNER JOIN "posts" AS blogs__features__featurable ON blogs__features.featurable_id = blogs__features__featurable.id)]
      end
    end
  end

  describe 'for belongs_to' do

    describe 'using class_name' do
      before do
        Post.filter do
          having(:publication).with(:name, 'NYT')
        end.inspect
      end

      it 'should create the correct condition' do
        Post.last_find[:conditions].should == [%q(posts__publication.name = ?), 'NYT'] 
      end

      it 'should create the correct join' do
        Post.last_find[:joins].should == [%q(INNER JOIN "blogs" AS posts__publication ON "posts".blog_id = posts__publication.id)]
      end
    end

    describe 'using foreign_key' do
      before do
        Post.filter do
          having(:special_blog).with(:name, 'Larry')
        end.inspect
      end

      it 'should create the correct condition' do
        Post.last_find[:conditions].should == [%q(posts__special_blog.name = ?), 'Larry'] 
      end

      it 'should create the correct join' do
        Post.last_find[:joins].should == [%q(INNER JOIN "blogs" AS posts__special_blog ON "posts".special_blog_id = posts__special_blog.id)]
      end
    end
  end

  describe 'working with named scopes' do
    before do
      @blog = Class.new(Blog)
      @blog.named_scope :with_high_id, { :conditions => ['id > 100'] }
      @blog.named_filter(:published) { with(:published, true) }
    end
    
    it 'should concatenate the filter with the scope correctly' do
      @blog.with_high_id.published.inspect
      @blog.last_find[:conditions].should == %q(("blogs".published = 't') AND (id > 100))
    end

    it 'should concatenate correctly when called in the other order' do
      @blog.published.with_high_id.inspect
      @blog.last_find[:conditions].should == %q((id > 100) AND ("blogs".published = 't'))
    end
  end

  describe 'working with named scopes when there are a number of joins' do
    before do
      @blog = Class.new(Blog)
      @blog.named_scope :ads_with_sale, { :joins => :ads, :conditions => ["'ads'.content LIKE ?", '%sale%'] }
      @blog.named_filter(:with_permalinked_posts) { having(:posts).with(:permalink).is_not_null }
      @blog.named_filter(:with_offensive_comments) { having(:comments).with(:offensive, true) }
      @blog.with_permalinked_posts.ads_with_sale.with_offensive_comments.inspect
    end

    it 'should concatenate the conditions correctly' do
      @blog.last_find[:conditions].should == %q((blogs__posts__comments.offensive = 't') AND (('ads'.content LIKE '%sale%') AND (blogs__posts.permalink IS NOT NULL)))
    end

    it 'should concatenate the joins correctly and not throw away my joins like AR usually does' do
      @blog.last_find[:joins].should == [%q(INNER JOIN "posts" AS blogs__posts ON "blogs".id = blogs__posts.blog_id), %q(INNER JOIN "comments" AS blogs__posts__comments ON blogs__posts.id = blogs__posts__comments.post_id), %q(INNER JOIN "ads" ON ads.blog_id = blogs.id)]
    end
  end

  describe 'working with named scopes that join to the same table' do
    before do
      @blog = Class.new(Blog)
      @blog.named_scope :with_crazy_post_permalinks, { :joins => :posts, :conditions => ["'posts'.permalink = ?", 'crazy'] }
      @blog.named_filter(:with_empty_permalinks) { having(:posts).with(:permalink, nil) } 
    end

    it 'should concatenate the conditions correctly' do
      @blog.with_crazy_post_permalinks.with_empty_permalinks.inspect 
      @blog.last_find[:conditions].should == %q((blogs__posts.permalink IS NULL) AND ('posts'.permalink = 'crazy'))
    end

    it 'should concatenate the joins correctly' do
      @blog.with_crazy_post_permalinks.with_empty_permalinks.inspect
      @blog.last_find[:joins].should == [%q(INNER JOIN "posts" AS blogs__posts ON "blogs".id = blogs__posts.blog_id), %q(INNER JOIN "posts" ON posts.blog_id = blogs.id)]
    end
  end

  describe 'working with default scopes' do
    describe 'with a simple filter' do
      before do
        Article.filter do
          with(:contents, 'something')
        end.inspect
      end

      it 'should use the correct order' do
        Article.last_find[:order].should == %q(created_at DESC)
      end

      it 'should use the correct conditions' do
        pending 'currently the IS NULL condition is added twice.'
        Article.last_find[:conditions].should == %q((("articles"."created_at" IS NULL) AND ("articles".contents = 'something')))
      end
    end
  end
end
