class Post < ActiveRecord::Base
  extend TestModel

  belongs_to :blog
  has_many :comments
end
