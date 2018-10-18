class AddLastRevisionToPullReviews < ActiveRecord::Migration
  def self.up
    add_column :pull_reviews, :last_revision, :string, :after => 'status'
  end

  def self.down
    remove_column :pull_reviews, :last_revision
  end
end
