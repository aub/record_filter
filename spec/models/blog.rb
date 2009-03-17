class Blog < ActiveRecord::Base
  extend TestModel

  has_many :posts
end
