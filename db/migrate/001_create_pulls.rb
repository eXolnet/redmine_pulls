class CreatePulls < ActiveRecord::Migration
    def change
      create_table :pulls do |t|
        t.integer  :project_id,        :null => false
        t.string   :subject,           :null => false
        t.text     :description
        t.integer  :repository_id,     :null => false
        t.string   :commit_base,       :null => false
        t.string   :commit_head,       :null => false
        t.integer  :category_id
        t.integer  :assigned_to_id
        t.integer  :priority_id,       :null => false
        t.integer  :author_id,         :null => false
        t.datetime :created_on,        :null => false
        t.datetime :updated_on,        :null => false
        t.datetime :merged_on
        t.datetime :closed_on
      end
    end
  end
