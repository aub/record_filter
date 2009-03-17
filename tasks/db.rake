namespace :db do
  namespace :test do
    desc 'drop database and recreate from test schema'
    task :prepare do
      require File.join(File.dirname(__FILE__), 'test', 'test_helper')
      
      FileUtils.rm(File.join(File.dirname(__FILE__), 'test', 'test.db'))

      ActiveRecord::Schema.define do
        create_table :posts do |t|
          t.integer :blog_id
          t.string :permalink
          t.timestamp :created_at
        end
      end
    end
  end
end
