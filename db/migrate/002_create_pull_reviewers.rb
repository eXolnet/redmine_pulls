class CreatePullReviewers < ActiveRecord::Migration
    def change
      create_table :pull_reviewers do |t|
        t.integer  :pull_id,      :null => false
        t.integer  :reviewer_id,  :null => false
        t.integer  :status,       :null => false
        t.datetime :created_on,   :null => false
        t.datetime :updated_on,   :null => false
      end
    end
  end
