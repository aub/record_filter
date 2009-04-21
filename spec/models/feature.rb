class Feature < ActiveRecord::Base
  extend TestModel

  belongs_to :featurable, :polymorphic => true
end
