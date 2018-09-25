class CreatePullReviews < ActiveRecord::Migration
    def change
      create_table :pull_reviews do |t|
        t.integer  :pull_id,      :null => false
        t.integer  :user_id,      :null => false
        t.string   :status,       :null => false
        t.datetime :created_on,   :null => false
        t.datetime :updated_on,   :null => false
      end
    end
  end
