require 'rubygems'
gem 'rspec', '~> 1.1'
gem 'sqlite3-ruby'

require 'ruby-debug'
require 'spec'

require File.join(File.dirname(__FILE__), '..', 'lib', 'record_filter')

module TestModel
  attr_reader :last_find

  def all(params = {})
    @last_find = params
  end
end

Dir.glob(File.join(File.dirname(__FILE__), 'models', '*.rb')).each { |file| require file }

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => File.join(File.dirname(__FILE__), 'test.db')
)
