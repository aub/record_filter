class Blog < ActiveRecord::Base
  extend TestModel

  has_many :posts
  has_many :ads
end
