class PullReviewer < ActiveRecord::Base
  include Redmine::SafeAttributes

  belongs_to :pull
  belongs_to :reviewer, :class_name => 'User'

  validates_presence_of :pull, :reviewer
end
