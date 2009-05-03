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
        Blog.last_find[:joins].should == %q(INNER JOIN "news_stories" AS blogs__stories ON "blogs".id = blogs__stories.blog_id)
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
        Blog.last_find[:joins].should == %q(INNER JOIN "posts" AS blogs__special_posts ON "blogs".id = blogs__special_posts.special_blog_id)
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
        Blog.last_find[:joins].should == %q(INNER JOIN "posts" AS blogs__special_public_posts ON "blogs".special_id = blogs__special_public_posts.blog_id)
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
        Blog.last_find[:joins].should == %q(INNER JOIN "posts" AS blogs__posts ON "blogs".id = blogs__posts.blog_id INNER JOIN "comments" AS blogs__posts__bad_comments ON blogs__posts.id = blogs__posts__bad_comments.post_id)
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
        Blog.last_find[:joins].should == %q(INNER JOIN "features" AS blogs__features ON "blogs".id = blogs__features.blog_id AND (blogs__features.featurable_type = 'Post') INNER JOIN "posts" AS blogs__features__featurable ON blogs__features.featurable_id = blogs__features__featurable.id)
      end
    end

    # :include
    # :finder_sql
    # :counter_sql
    # :group
    # :having
    # :limit
    # :offset
    # :select
    # :uniq
    # :readonly
    # :order
    # :conditions
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
        Post.last_find[:joins].should == %q(INNER JOIN "blogs" AS posts__publication ON "posts".blog_id = posts__publication.id)
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
        Post.last_find[:joins].should == %q(INNER JOIN "blogs" AS posts__special_blog ON "posts".special_blog_id = posts__special_blog.id)
      end
    end

    # :include
    # :conditions
    # :select
    # :foreign_key
    # :polymorphic
    # :readonly
  end
end
