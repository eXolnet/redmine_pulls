class PullReview < ActiveRecord::Base
  include Redmine::SafeAttributes

  STATUS_REQUESTED = 'requested'
  STATUS_APPROVED = 'approved'
  STATUS_CHANGES_REQUESTED = 'changes_requested'

  belongs_to :pull
  belongs_to :reviewer, :class_name => 'User'

  validates_presence_of :pull, :reviewer

  state_machine :status, initial: :requested do
    event :mark_as_requested do
      transition [:concerned, :approved] => :requested
    end

    event :mark_as_concerned do
      transition [:requested, :approved] => :concerned
    end

    event :mark_as_approved do
      transition [:requested, :concerned] => :approved
    end

    state :requested
    state :concerned
    state :approved
  end
end
