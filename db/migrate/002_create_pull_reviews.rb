migration_class = ActiveRecord::VERSION::MAJOR >= 5 ? ActiveRecord::Migration[4.2] : ActiveRecord::Migration

class CreatePullReviews < migration_class
  def change
    create_table :pull_reviews do |t|
      t.integer  :pull_id,      :null => false
      t.integer  :reviewer_id,  :null => false
      t.string   :status,       :null => false
      t.datetime :created_on,   :null => false
      t.datetime :updated_on,   :null => false
    end
  end
end
