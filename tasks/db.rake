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

        create_table :comments do |t|
          t.references :blog
          t.string :contents
          t.boolean :offensive
        end
      end
    end
  end
end
