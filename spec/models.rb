class Ad < ActiveRecord::Base
  extend TestModel
  belongs_to :blog
end


class Article < ActiveRecord::Base
  extend TestModel
  default_scope :order => 'created_at DESC', :conditions => { :created_at => nil }
end


class Author < ActiveRecord::Base
  extend TestModel
  belongs_to :user
  belongs_to :post
end


class Blog < ActiveRecord::Base
  extend TestModel
  has_many :posts
  has_many :ordered_posts, :class_name => 'Post', :order => 'created_at DESC'
  has_many :special_posts, :class_name => 'Post', :foreign_key => :special_blog_id
  has_many :special_public_posts, :class_name => 'Post', :primary_key => :special_id
  has_many :comments, :through => :posts
  has_many :nasty_comments, :through => :posts, :source => :bad_comments
  has_many :ads
  has_many :stories, :class_name => 'NewsStory'
  has_many :features
  has_many :featured_posts, :through => :features, :source => :featurable, :source_type => 'Post'
  has_many :posts_with_comments, :class_name => 'Post', :include => :comments
  has_many :articles
end


class Comment < ActiveRecord::Base
  extend TestModel
  belongs_to :post
  belongs_to :user
end


class Feature < ActiveRecord::Base
  extend TestModel
  belongs_to :blog
  belongs_to :featurable, :polymorphic => true
end


class Photo < ActiveRecord::Base
  belongs_to :post
end


class Post < ActiveRecord::Base
  extend TestModel
  belongs_to :blog
  belongs_to :publication, :class_name => 'Blog'
  belongs_to :special_blog, :class_name => 'Blog', :foreign_key => :special_blog_id
  has_many :comments
  has_many :bad_comments, :conditions => { :offensive => true }, :class_name => 'Comment'
  has_one :photo
  has_and_belongs_to_many :tags
  has_many :features, :as => :featurable
  has_many :reviews, :as => :reviewable
  has_one :author
  has_one :user, :through => :author
end

class PublicPost < Post
end

class Review < ActiveRecord::Base
  extend TestModel
  belongs_to :reviewable, :polymorphic => true
end


class NewsStory < ActiveRecord::Base
  extend TestModel
  belongs_to :blog
end


class Tag < ActiveRecord::Base
  has_and_belongs_to_many :posts
end


class User < ActiveRecord::Base
  extend TestModel
  has_one :author
  has_many :comments
end

