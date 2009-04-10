class Post < ActiveRecord::Base
  extend TestModel

  belongs_to :blog
  has_many :comments
  has_one :photo
  has_and_belongs_to_many :tags
end
