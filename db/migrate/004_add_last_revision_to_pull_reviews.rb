migration_class = ActiveRecord::VERSION::MAJOR >= 5 ? ActiveRecord::Migration[4.2] : ActiveRecord::Migration

class AddLastRevisionToPullReviews < migration_class
  def self.up
    add_column :pull_reviews, :last_revision, :string, :after => 'status'
  end

  def self.down
    remove_column :pull_reviews, :last_revision
  end
end
