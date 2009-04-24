require 'rubygems'
gem 'rspec', '~> 1.1'
gem 'sqlite3-ruby'

require 'ruby-debug'
require 'spec'

require File.join(File.dirname(__FILE__), '..', 'lib', 'record_filter')

module TestModel
  mattr_reader :extended_models
  @@extended_models = []

  attr_accessor :last_find

  def find(*args)
    @last_find = current_scoped_methods[:find] if current_scoped_methods
    super
  end

  def count(*args)
    @last_find = current_scoped_methods[:find] if current_scoped_methods
    super
  end

  def self.extended(base)
    @@extended_models << base
  end
end

require File.join(File.dirname(__FILE__), 'models')

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => File.join(File.dirname(__FILE__), 'test.db')
)
