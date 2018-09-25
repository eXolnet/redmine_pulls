class PullReview < ActiveRecord::Base
  include Redmine::SafeAttributes

  STATUS_REQUESTED = 'requested'
  STATUS_APPROVED = 'approved'
  STATUS_CHANGES_REQUESTED = 'changes_requested'

  belongs_to :pull
  belongs_to :reviewer, :class_name => 'User'

  validates_presence_of :pull, :reviewer
end
