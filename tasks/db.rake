namespace :db do
  namespace :test do
    desc 'drop database and recreate from test schema'
    task :prepare do
      require File.join(File.dirname(__FILE__), '..', 'spec', 'spec_helper')
      
      FileUtils.rm(File.join(File.dirname(__FILE__), '..', 'spec', 'test.db'))

      ActiveRecord::Schema.define do
        create_table :posts do |t|
          t.integer :blog_id
          t.string :permalink
          t.timestamp :created_at
        end

        create_table :blogs do |t|
          t.string :name
        end

        create_table :photos do |t|
          t.integer :post_id
          t.string :path
          t.string :format
        end
      end
    end
  end
end
