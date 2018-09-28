class CreatePulls < ActiveRecord::Migration
    def change
      create_table :pulls do |t|
        t.integer  :project_id,            :null => false
        t.string   :subject,               :null => false
        t.text     :description
        t.integer  :repository_id,         :null => false
        t.string   :commit_base,           :null => false
        t.string   :commit_base_revision
        t.string   :commit_head,           :null => false
        t.string   :commit_head_revision
        t.string   :status,                :null => false, :default => "opened"
        t.string   :review_status,         :null => false, :default => "unreviewed"
        t.string   :merge_status,          :null => false, :default => "unchecked"
        t.integer  :category_id
        t.integer  :assigned_to_id
        t.integer  :priority_id,           :null => false
        t.integer  :fixed_version_id
        t.integer  :author_id,             :null => false
        t.integer  :merge_user_id
        t.datetime :created_on,            :null => false
        t.datetime :updated_on,            :null => false
        t.datetime :merged_on
        t.datetime :closed_on
      end
    end
  end
