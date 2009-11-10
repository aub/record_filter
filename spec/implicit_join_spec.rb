require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'implicit joins' do
  before do
    TestModel.extended_models.each { |model| model.last_find = {} }
  end

  describe 'on belongs_to' do
    describe 'with single condition inline' do
      before do
        Post.filter do
          having(:blog).with :name, 'Test Name'
        end.inspect
      end

      it 'should add correct join' do
        Post.last_find[:joins].should == [%q(INNER JOIN "blogs" AS posts__blog ON "posts".blog_id = posts__blog.id)]
      end

      it 'should query against condition on join table' do
        Post.last_find[:conditions].should == ['posts__blog.name = ?', 'Test Name']
      end
    end

    shared_examples_for 'multiple conditions on single join' do
      it 'should add join once' do
        Post.last_find[:joins].should == [%q(INNER JOIN "blogs" AS posts__blog ON "posts".blog_id = posts__blog.id)]
      end

      it 'should query against conditions on join table' do
        Post.last_find[:conditions].should == [%q((posts__blog.name = ?) AND (posts__blog.published = ?)), 'Test Name', true]
      end
    end

    describe 'with multiple conditions on single join inline' do
      before do
        Post.filter do
          having(:blog).with :name, 'Test Name'
          having(:blog).with :published, true
        end.inspect
      end

      it_should_behave_like 'multiple conditions on single join'
    end

    describe 'with multiple conditions on a single join in a block' do
      before do
        Post.filter do
          having :blog do
            with :name, 'Test Name'
            with :published, true
          end
        end.inspect
      end

      it_should_behave_like 'multiple conditions on single join'
    end
  end

  describe 'on has_many' do
    before do
      Blog.filter do
        having(:posts).with :permalink, 'test-post'
      end.inspect
    end

    it 'should add correct join' do
      Blog.last_find[:joins].should == [%q(INNER JOIN "posts" AS blogs__posts ON "blogs".id = blogs__posts.blog_id)]
    end

    it 'should query against condition on join table' do
      Blog.last_find[:conditions].should == [%q(blogs__posts.permalink = ?), 'test-post']
    end
  end

  describe 'with multiple joins' do
    before do
      Blog.filter do
        having(:posts) do
          with :permalink, 'test-post'
          having(:comments).with :offensive, true
        end
      end.inspect
    end

    it 'should add both joins' do
      Blog.last_find[:joins].should == [%q(INNER JOIN "posts" AS blogs__posts ON "blogs".id = blogs__posts.blog_id),
                                        %q(INNER JOIN "comments" AS blogs__posts__comments ON blogs__posts.id = blogs__posts__comments.post_id)]
    end

    it 'should query against both conditions' do
      Blog.last_find[:conditions].should == [%q((blogs__posts.permalink = ?) AND (blogs__posts__comments.offensive = ?)), 'test-post', true] 
    end
  end

  describe 'with one having statement expressing multiple joins' do
    before do
      Blog.filter do
        having(:posts => :comments) do
          with :offensive, true
        end
      end.inspect
    end

    it 'should add both joins' do
      Blog.last_find[:joins].should == [%q(INNER JOIN "posts" AS blogs__posts ON "blogs".id = blogs__posts.blog_id),
                                        %q(INNER JOIN "comments" AS blogs__posts__comments ON blogs__posts.id = blogs__posts__comments.post_id)]
    end

    it 'should query against both conditions' do
      Blog.last_find[:conditions].should == [%q(blogs__posts__comments.offensive = ?), true] 
    end
  end

  describe 'on has_one' do
    before do
      Post.filter do
        having(:photo).with :format, 'jpg'
      end.inspect
    end

    it 'should add correct join' do
      Post.last_find[:joins].should == [%q(INNER JOIN "photos" AS posts__photo ON "posts".id = posts__photo.post_id)]
    end

    it 'should query against condition on join table' do
      Post.last_find[:conditions].should == ['posts__photo.format = ?', 'jpg']
    end
  end

  describe 'with nested joins' do
    before do
      Blog.filter do
        having(:posts).having(:photo).with :format, 'png'
      end.inspect
    end

    it 'should add correct join' do
      Blog.last_find[:joins].should == [%q(INNER JOIN "posts" AS blogs__posts ON "blogs".id = blogs__posts.blog_id),
                                        %q(INNER JOIN "photos" AS blogs__posts__photo ON blogs__posts.id = blogs__posts__photo.post_id)]
    end

    it 'should query against condition on join table' do
      Blog.last_find[:conditions].should == ['blogs__posts__photo.format = ?', 'png']
    end
  end

  describe 'with has and belongs to many joins' do
    before do
      Post.filter do
        having(:tags).with :name, 'activerecord'
      end.inspect
    end

    it 'should add correct join' do
      Post.last_find[:joins].should == [%q(INNER JOIN "posts_tags" AS __posts__tags ON "posts".id = __posts__tags.post_id),
                                        %q(INNER JOIN "tags" AS posts__tags ON __posts__tags.tag_id = posts__tags.id)]
    end
  end

  describe 'with negative conditions' do
    before do
      Comment.filter do
        with :offensive, false
      end.inspect
    end

    it 'should create the correct condition' do
      Comment.last_find[:conditions].should == [%q("comments".offensive = ?), false]
    end
  end

  describe 'with nil conditions' do
    before do
      Comment.filter do
        with :contents, nil
        with :offensive, true
      end.inspect
    end

    it 'should create the correct IS NULL condition' do
      Comment.last_find[:conditions].should == [%q(("comments".contents IS NULL) AND ("comments".offensive = ?)), true]
    end
  end

  describe 'with negated conditions' do
    before do
      Comment.filter do
        with(:offensive).not(false)
      end.inspect
    end

    it 'should create the correct condition' do
      Comment.last_find[:conditions].should == [%q("comments".offensive <> ?), false]
    end
  end

  describe 'with negated nil conditions' do
    before do
      Comment.filter do
        with(:contents).not(nil)
        with :offensive, true
      end.inspect
    end

    it 'should create the correct IS NOT NULL condition' do
      Comment.last_find[:conditions].should == [%q(("comments".contents IS NOT NULL) AND ("comments".offensive = ?)), true]
    end
  end

  describe 'with negated nil conditions using is_null' do
    before do
      Comment.filter do
        with(:contents).not.is_null
        with :offensive, true
      end.inspect
    end

    it 'should create the correct IS NOT NULL condition' do
      Comment.last_find[:conditions].should == [%q(("comments".contents IS NOT NULL) AND ("comments".offensive = ?)), true]
    end
  end

  describe 'passing the join type to having' do
    before do
      Blog.filter do
        having(:posts, :join_type => :left) do
          with(:permalink, 'ack')
        end
      end.inspect
    end

    it 'should create the correct condition' do
      Blog.last_find[:conditions].should == [%q(blogs__posts.permalink = ?), 'ack']
    end

    it 'should create the correct join' do
      Blog.last_find[:joins].should == [%q(LEFT OUTER JOIN "posts" AS blogs__posts ON "blogs".id = blogs__posts.blog_id)]
    end
  end

  describe 'passing the join type to having with multiple joins' do
    before do
      Blog.filter do
        having({ :posts => :comments }, :join_type => :left) do
          with(:offensive, true)
        end
      end.inspect
    end

    it 'should create the correct condition' do
      Blog.last_find[:conditions].should == [%q(blogs__posts__comments.offensive = ?), true]
    end

    it 'should create the correct join' do
      Blog.last_find[:joins].should == [%q(LEFT OUTER JOIN "posts" AS blogs__posts ON "blogs".id = blogs__posts.blog_id), %q(LEFT OUTER JOIN "comments" AS blogs__posts__comments ON blogs__posts.id = blogs__posts__comments.post_id)]
    end
  end

  describe 'on polymorphic associations' do
    before do
      PublicPost.filter do
        having(:reviews) do
          with(:stars_count, 3)
        end
      end.inspect
    end

    it 'should create the correct condition' do
      PublicPost.last_find[:conditions].should == [%q(posts__reviews.stars_count = ?), 3]
    end

    it 'should create the correct join' do
      PublicPost.last_find[:joins].should == [%q(INNER JOIN "reviews" AS posts__reviews ON "posts".id = posts__reviews.reviewable_id AND (posts__reviews.reviewable_type = 'Post'))]
    end
  end

  describe 'on has_many_through associations' do
    before do
      Blog.filter do
        having(:comments) do
          with(:offensive, true)
        end
      end.inspect
    end

    it 'should create the correct condition' do
      Blog.last_find[:conditions].should == [%q(blogs__posts__comments.offensive = ?), true]
    end

    it 'should create the correct join' do
      Blog.last_find[:joins].should == [%q(INNER JOIN "posts" AS blogs__posts ON "blogs".id = blogs__posts.blog_id), %q(INNER JOIN "comments" AS blogs__posts__comments ON blogs__posts.id = blogs__posts__comments.post_id)]
    end
  end

  describe 'on has_one_through associations' do
    before do
      Post.filter do
        having(:user) do
          with(:first_name, 'Joe')
        end
      end.inspect
    end

    it 'should create the correct condition' do
      Post.last_find[:conditions].should == [%q(posts__author__user.first_name = ?), 'Joe']
    end

    it 'should create the correct join' do
      Post.last_find[:joins].should == [%q(INNER JOIN "authors" AS posts__author ON "posts".id = posts__author.post_id), %q(INNER JOIN "users" AS posts__author__user ON posts__author.user_id = posts__author__user.id)]
    end
  end

  describe 'passing strings instead of symbols' do
    before do
      Post.filter do
        having('comments') do
          with('offensive', true)
        end
        with('id').gte(12)
      end.inspect
    end

    it 'should create the correct condition' do
      Post.last_find[:conditions].should == [%q((posts__comments.offensive = ?) AND ("posts".id >= ?)), true, 12]
    end

    it 'should create the correct join' do
      Post.last_find[:joins].should == [%q(INNER JOIN "comments" AS posts__comments ON "posts".id = posts__comments.post_id)]
    end
  end

  describe 'using a table alias' do
    before do
      Post.filter do
        having(:comments, :alias => 'arghs') do
          with(:offensive, true)
        end
      end.inspect
    end

    it 'should create the correct condition' do
      Post.last_find[:conditions].should == [%q(arghs.offensive = ?), true]
    end

    it 'should create the correct join' do
      Post.last_find[:joins].should == [%q(INNER JOIN "comments" AS arghs ON "posts".id = arghs.post_id)]
    end
  end

  describe 'using a table alias to do multiple joins on the same association' do
    before do
      Post.filter do
        having(:comments, :alias => 'ooohs').with(:offensive, true)
        having(:comments, :alias => 'aaahs').with(:offensive, false)
      end.inspect
    end

    it 'should create the correct condition' do
      Post.last_find[:conditions].should == [%q((ooohs.offensive = ?) AND (aaahs.offensive = ?)), true, false]
    end

    it 'should create the correct join' do
      Post.last_find[:joins].should == [%q(INNER JOIN "comments" AS ooohs ON "posts".id = ooohs.post_id), %q(INNER JOIN "comments" AS aaahs ON "posts".id = aaahs.post_id)]
    end
  end

  describe 'using a table alias with has_many :through associations' do
    before do
      Blog.filter do
        having(:comments, :alias => 'arghs') do
          with(:offensive, true)
        end
      end.inspect
    end

    it 'should create the correct condition' do
      Blog.last_find[:conditions].should == [%q(arghs.offensive = ?), true]
    end

    it 'should create the correct join' do
      Blog.last_find[:joins].should == [%q(INNER JOIN "posts" AS blogs__posts ON "blogs".id = blogs__posts.blog_id), %q(INNER JOIN "comments" AS arghs ON blogs__posts.id = arghs.post_id)]
    end
  end

  describe 'using a table alias' do
    before do
      Post.filter do
        having(:comments, :alias => 'arghs') do
          with(:offensive, true)
        end
      end.inspect
    end

    it 'should create the correct condition' do
      Post.last_find[:conditions].should == [%q(arghs.offensive = ?), true]
    end

    it 'should create the correct join' do
      Post.last_find[:joins].should == [%q(INNER JOIN "comments" AS arghs ON "posts".id = arghs.post_id)]
    end
  end

  describe 'with nonstandard primary and foreign keys' do
    it 'should join with the correct key on belongs_to' do
      Subscription.filter { having(:user).with(:first_name, 'Bob') }.inspect
      Subscription.last_find[:joins].should == [%q(INNER JOIN "users" AS subscriptions__user ON "subscriptions".email = subscriptions__user.email_address)]
    end

    it 'should join to the correct key on has_many' do
      User.filter { having(:subscriptions).with(:created_at).gt(3.weeks.ago.utc) }.inspect
      User.last_find[:joins].should == [%q(INNER JOIN "subscriptions" AS users__subscriptions ON "users".email_address = users__subscriptions.email)]
    end
  end
end
