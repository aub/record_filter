class Post < ActiveRecord::Base
  extend TestModel

  belongs_to :blog
  has_one :photo
end
