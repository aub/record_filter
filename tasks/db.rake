namespace :db do
  namespace :spec do
    desc 'drop database and recreate from test schema'
    task :prepare do
      require File.join(File.dirname(__FILE__), '..', 'spec', 'spec_helper')
      
      FileUtils.rm(File.join(File.dirname(__FILE__), '..', 'spec', 'test.db'))

      ActiveRecord::Schema.define do
        create_table :posts do |t|
          t.integer :blog_id
          t.string :permalink
          t.timestamp :created_at
          t.boolean :published
        end

        create_table :blogs do |t|
          t.string :name
          t.boolean :published
        end

        create_table :comments do |t|
          t.references :post
          t.string :contents
          t.boolean :offensive
        end

        create_table :photos do |t|
          t.integer :post_id
          t.string :path
          t.string :format
        end

        create_table :tags do |t|
          t.string :name
        end

        create_table :posts_tags, :id => false do |t|
          t.integer :post_id
          t.integer :tag_id
        end

        create_table :features do |t|
          t.integer :featurable_id
          t.string :featurable_type
          t.integer :priority
        end

        create_table :reviews do |t|
          t.integer :reviewable_id
          t.string :reviewable_type
          t.integer :stars_count
        end

        create_table :ads do |t|
          t.integer :blog_id
          t.string :content
        end
      end
    end
  end
end
