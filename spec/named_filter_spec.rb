require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'named filters' do
  before do
    TestModel.extended_models.each { |model| model.last_find = {} }
  end

  describe 'defining a simple filter' do
    before do
      @blog = Class.new(Blog)
      @blog.named_filter(:with_test_name) do
        with :name, 'Test Name'
      end
    end

    it 'should call the filter through the filter method' do
      @blog.with_test_name.inspect
      @blog.last_find[:conditions].should == [%q("blogs".name = ?), 'Test Name']
    end

    it 'should call the filter within the block' do
      @blog.filter do
        with_test_name
      end.inspect
      @blog.last_find[:conditions].should == [%q("blogs".name = ?), 'Test Name']
    end
  end

  describe 'defining a filter with arguments' do
    before do
      @blog = Class.new(Blog)
      @blog.named_filter(:with_name) do |name|
        with :name, name
      end
    end

    it 'should call the filter with the passed argument' do
      @blog.with_name('nice name').inspect
      @blog.last_find[:conditions].should == [%q("blogs".name = ?), 'nice name']
    end
  end

  describe 'defining a filter that passes arguments down several levels' do
    before do
      @blog = Class.new(Blog)
      @blog.named_filter(:with_name_and_post_with_permalink) do |name, permalink|
        with :name, name
        having :posts do
          with :permalink, permalink
        end
      end
    end

    it 'should call the filter passing all of the arguments' do
      @blog.with_name_and_post_with_permalink('booya', 'ftw').inspect
      @blog.last_find[:conditions].should == 
        [%q(("blogs".name = ?) AND (blogs__posts.permalink = ?)), 'booya', 'ftw'] 
    end
  end

  describe 'taking active_record objects as arguments' do
    it 'should use the id of the object as the actual parameter' do
      post = Class.new(Post)
      post.named_filter(:with_ar_arg) do |blog|
        with(:blog_id, blog)
      end
      blog = Blog.create
      post.with_ar_arg(blog).inspect
      post.last_find[:conditions].should == [%q("posts".blog_id = ?), blog.id]
    end
  end

  describe 'using filters in subclasses' do
    before do
      @comment = Class.new(Comment)
      @comment.named_filter(:with_contents) do |*args|
        with :contents, args[0]
      end
      @nice_comment = Class.new(@comment) do
        extend TestModel

        named_filter(:offensive) do
          with :offensive, true
        end
      end
    end

    it 'should execute the parent class filters correctly' do
      @nice_comment.with_contents('test contents').inspect
      @nice_comment.last_find[:conditions].should == 
        [%q("comments".contents = ?), 'test contents']
    end

    it 'should not have the subclass filters in the parent class' do
      @comment.respond_to?(:offensive).should == false
    end

    it 'should have parent class filters in the subclass' do
      @nice_comment.offensive.with_contents('something').inspect
      @nice_comment.last_find[:conditions].should == 
        %q(("comments".contents = 'something') AND ("comments".offensive = 't'))
    end

    it 'should provide access to the named filters' do
      @comment.named_filters.should == [:with_contents]
      @nice_comment.named_filters.sort_by { |i| i.to_s }.should == [:offensive, :with_contents]
    end
  end

  describe 'using compound filters' do
    before(:all) do
      Comment.named_filter(:offensive_or_not) do |state|
        with(:offensive, state)
      end
    end

    it 'should concatenate the filters correctly' do
      Post.filter do
        having(:comments).offensive_or_not(true)
      end.inspect
      Post.last_find[:conditions].should == [%q(posts__comments.offensive = ?), true] 
      Post.last_find[:joins].should == %q(INNER JOIN "comments" AS posts__comments ON "posts".id = posts__comments.post_id)
    end

    it 'should work correctly with the named filter called within the having block' do
      Post.filter do
        having(:comments) do
          offensive_or_not(false)
        end
      end.inspect
      Post.last_find[:conditions].should == [%q(posts__comments.offensive = ?), false] 
      Post.last_find[:joins].should == %q(INNER JOIN "comments" AS posts__comments ON "posts".id = posts__comments.post_id)
    end
  end

  describe 'chaining filters' do
    before do
      @post = Class.new(Post)
      @post.named_filter(:for_blog) do |*args|
        having(:blog).with :id, args[0]
      end
      @post.named_filter(:with_offensive_comments) do
        having(:comments).with :offensive, true
      end
      @post.named_filter(:with_interesting_comments) do
        having(:comments).with :offensive, false
      end
    end

    it 'should chain the filters into a single query' do
      @post.for_blog(1).with_offensive_comments.inspect
      @post.last_find[:conditions].should == %q((posts__comments.offensive = 't') AND (posts__blog.id = 1))
      @post.last_find[:joins].should == [%q(INNER JOIN "comments" AS posts__comments ON "posts".id = posts__comments.post_id), %q(INNER JOIN "blogs" AS posts__blog ON "posts".blog_id = posts__blog.id)]
    end

    it 'should remove duplicate joins' do
      @post.for_blog(1).with_offensive_comments.with_interesting_comments.inspect
      @post.last_find[:joins].should == [%q(INNER JOIN "comments" AS posts__comments ON "posts".id = posts__comments.post_id), %q(INNER JOIN "blogs" AS posts__blog ON "posts".blog_id = posts__blog.id)]
    end

    it 'should allow for filtering a named_filter' do
      @post.for_blog(1).filter { having(:comments).with :offensive, true }.inspect
      @post.last_find[:conditions].should == %q((posts__comments.offensive = 't') AND (posts__blog.id = 1))
      @post.last_find[:joins].should == [%q(INNER JOIN "comments" AS posts__comments ON "posts".id = posts__comments.post_id), %q(INNER JOIN "blogs" AS posts__blog ON "posts".blog_id = posts__blog.id)] 
    end

    it 'should allow for applying a named filter to a filter' do
      @post.filter { having(:comments).with :offensive, false }.for_blog(1).inspect
      @post.last_find[:conditions].should == %q((posts__blog.id = 1) AND (posts__comments.offensive = 'f'))
      @post.last_find[:joins].should == [%q(INNER JOIN "blogs" AS posts__blog ON "posts".blog_id = posts__blog.id), %q(INNER JOIN "comments" AS posts__comments ON "posts".id = posts__comments.post_id)]
    end

    it 'should not change the inner filter conditions when chaining filters' do
      base = @post.for_blog(1)
      base.with_offensive_comments
      base.inspect
      @post.last_find[:conditions].should == [%q(posts__blog.id = ?), 1]
    end

    it 'should not change the inner filter joins when chaining filters' do
      base = @post.for_blog(1)
      base.with_offensive_comments
      base.inspect
      @post.last_find[:joins].should == %q(INNER JOIN "blogs" AS posts__blog ON "posts".blog_id = posts__blog.id)
    end

    it 'should not change an original filter when reusing it' do
      base = @post.for_blog(1)
      level1 = base.with_offensive_comments.inspect
      level2 = base.with_interesting_comments
      @post.last_find[:conditions].should == %q((posts__comments.offensive = 't') AND (posts__blog.id = 1))
      @post.last_find[:joins].should == [%q(INNER JOIN "comments" AS posts__comments ON "posts".id = posts__comments.post_id), %q(INNER JOIN "blogs" AS posts__blog ON "posts".blog_id = posts__blog.id)]
    end
  end

  describe 'chaining named filters with regular AR associations' do
    before do
      Post.named_filter(:published) do
        with(:published, true)
      end
      @blog = Blog.create
      @blog.posts.published.inspect
    end

    it 'should combine the conditions from the association with the named filter' do
      Post.last_find[:conditions].should == "(\"posts\".published = 't') AND (\"posts\".blog_id = #{@blog.id})"
    end
  end

  describe 'chaining named filters with AR associations that involve joins' do
    before(:all) do
      Comment.named_filter(:with_user_named) do |name|
        having(:user).with(:first_name, name)
      end
    end

    before(:each) do
      @blog = Blog.create
      @blog.comments.with_user_named('Bob').inspect
    end

    it 'should combine the joins from the association with the named filter' do
      Comment.last_find[:joins].should == [%q(INNER JOIN "users" AS comments__user ON "comments".user_id = comments__user.id), %q(INNER JOIN "posts" ON "comments".post_id = "posts".id)]
    end

    it 'should combine the conditions from the association with the named filter' do
      Comment.last_find[:conditions].should == "(comments__user.first_name = 'Bob') AND ((\"posts\".blog_id = #{@blog.id}))"
    end
  end

  describe 'chaining multiple named filters with an AR association' do
    before do
      Comment.named_filter(:offensive) { with(:offensive, true) }
      Comment.named_filter(:with_fun_in_contents) { with(:contents).like('%fun%') }
      @post = Post.create
      @post.comments.offensive.with_fun_in_contents.inspect
    end

    it 'should combine the conditions correctly' do
      Comment.last_find[:conditions].should == "(\"comments\".contents LIKE '%fun%') AND ((\"comments\".offensive = 't') AND (\"comments\".post_id = #{@post.id}))"
    end
  end

  describe 'chaining multiple named filters with different joins' do
    before do
      @blog = Class.new(Blog)
      @blog.named_filter(:with_offensive_comments) { having(:comments).with(:offensive, true) }
      @blog.named_filter(:with_ads_with_content) { |content| having(:ads).with(:content, content) }
    end

    it 'compile the joins correctly' do
      @blog.with_offensive_comments.with_ads_with_content('ack').inspect
      @blog.last_find[:joins].should == [%q(INNER JOIN "ads" AS blogs__ads ON "blogs".id = blogs__ads.blog_id), %q(INNER JOIN "posts" AS blogs__posts ON "blogs".id = blogs__posts.blog_id INNER JOIN "comments" AS blogs__posts__comments ON blogs__posts.id = blogs__posts__comments.post_id)]
    end
  end

  describe 'with named filters that only include orders' do
    it 'should have an empty conditions hash' do
      blog = Class.new(Blog)
      blog.named_filter(:ordered_by_id) { order(:id, :desc) }
      blog.ordered_by_id.proxy_options.should == { :order => %q("blogs".id DESC) }
    end
  end
end
