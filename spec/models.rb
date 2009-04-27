class Ad < ActiveRecord::Base
  extend TestModel
  belongs_to :blog
end


class Author < ActiveRecord::Base
  extend TestModel
  belongs_to :user
  belongs_to :post
end


class Blog < ActiveRecord::Base
  extend TestModel
  has_many :posts
  has_many :comments, :through => :posts
  has_many :ads
end


class Comment < ActiveRecord::Base
  extend TestModel
  belongs_to :post
  belongs_to :user
end


class Feature < ActiveRecord::Base
  extend TestModel
  belongs_to :featurable, :polymorphic => true
end


class Photo < ActiveRecord::Base
  belongs_to :post
end


class Post < ActiveRecord::Base
  extend TestModel
  belongs_to :blog
  has_many :comments
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


class Tag < ActiveRecord::Base
  has_and_belongs_to_many :posts
end


class User < ActiveRecord::Base
  extend TestModel
  has_one :author
  has_many :comments
end
