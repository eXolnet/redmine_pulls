migration_class = ActiveRecord::VERSION::MAJOR >= 5 ? ActiveRecord::Migration[4.2] : ActiveRecord::Migration

class CreatePullIssues < migration_class
  def change
    create_table :pull_issues do |t|
      t.integer  :pull_id,      :null => false
      t.integer  :issue_id,     :null => false
    end

    add_index :pull_issues, [:pull_id, :issue_id], :unique => true, :name => :pull_issues_ids
  end
end
