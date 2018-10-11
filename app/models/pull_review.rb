class PullReview < ActiveRecord::Base
  include Redmine::SafeAttributes

  STATUS_REQUESTED = 'requested'
  STATUS_APPROVED = 'approved'
  STATUS_CONCERNED = 'concerned'

  belongs_to :pull
  belongs_to :reviewer, :class_name => 'User'

  validates_presence_of :pull, :reviewer

  after_save :send_notification

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

  def send_notification
    return unless status_changed?

    if status == 'requested'
      send_notification_requested
    elsif status == 'concerned'
      send_notification_concerned
    elsif status == 'approved'
      send_notification_approved
    end
  end

  private

  def send_notification_requested
    if Setting.notified_events.include?('pull_review_requested')
      Mailer.pull_review_requested(self).deliver
    end
  end

  def send_notification_concerned
    if Setting.notified_events.include?('pull_changes_requested')
      Mailer.pull_changes_requested(self).deliver
    end
  end

  def send_notification_approved
    if Setting.notified_events.include?('pull_approved')
      Mailer.pull_approved(self).deliver
    end
  end
end
