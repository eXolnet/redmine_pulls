class Pull < ActiveRecord::Base
  include Redmine::SafeAttributes

  belongs_to :project
  belongs_to :repository
  belongs_to :author, :class_name => 'User'
  belongs_to :assigned_to, :class_name => 'Principal'
  belongs_to :fixed_version, :class_name => 'Version'
  belongs_to :priority, :class_name => 'IssuePriority'
  belongs_to :category, :class_name => 'IssueCategory'

  acts_as_customizable
  acts_as_watchable

  validates_presence_of :subject, :project, :commit_base, :commit_compare
  validates_presence_of :priority, :if => Proc.new {|issue| issue.new_record? || issue.priority_id_changed?}
  validates_presence_of :author, :if => Proc.new {|issue| issue.new_record? || issue.author_id_changed?}

  validates_length_of :subject, :maximum => 255
  attr_protected :id

  safe_attributes 'project_id',
                  'repository_id',
                  'category_id',
                  'assigned_to_id',
                  'priority_id',
                  'fixed_version_id',
                  'subject',
                  'description',
                  'commit_base',
                  'commit_compare'

  safe_attributes 'watcher_user_ids',
                  :if => lambda {|pull, user| pull.new_record? && user.allowed_to?(:add_pull_watchers, pull.project)}

  # Returns true if user or current user is allowed to edit or add notes to the issue
  def editable?(user=User.current)
    attributes_editable?(user) || notes_addable?(user)
  end

  # Returns true if user or current user is allowed to edit the issue
  def attributes_editable?(user=User.current)
    user_permission?(user, :edit_pulls)
  end

  # Returns true if user or current user is allowed to add notes to the issue
  def notes_addable?(user=User.current)
    user_permission?(user, :add_pull_notes)
  end

  # Returns true if user or current user is allowed to delete the issue
  def deletable?(user=User.current)
    user_permission?(user, :delete_pulls)
  end

  def initialize(attributes=nil, *args)
    super
    if new_record?
      # set default values for new records only
      self.priority ||= IssuePriority.default
    end
  end

  # Users the pull request can be assigned to
  def assignable_users
    users = project.assignable_users.to_a
    users << author if author && author.active?
    if assigned_to_id_was.present? && assignee = Principal.find_by_id(assigned_to_id_was)
      users << assignee
    end
    users.uniq.sort
  end

  # Versions that the pull request can be assigned to
  def assignable_versions
    return @assignable_versions if @assignable_versions

    versions = project.shared_versions.open.to_a
    if fixed_version
      if fixed_version_id_changed?
        # nothing to do
      elsif project_id_changed?
        if project.shared_versions.include?(fixed_version)
          versions << fixed_version
        end
      else
        versions << fixed_version
      end
    end
    @assignable_versions = versions.uniq.sort
  end

  # Returns a string of css classes that apply to the issue
  def css_classes(user=User.current)
    s = "pull #{priority.try(:css_classes)}"
    #s << ' closed' if closed?
    if user.logged?
      s << ' created-by-me' if author_id == user.id
      s << ' assigned-to-me' if assigned_to_id == user.id
      s << ' assigned-to-my-group' if user.groups.any? {|g| g.id == assigned_to_id}
    end
    s
  end

  private

  def user_permission?(user, permission)
    if project && !project.active?
      perm = Redmine::AccessControl.permission(permission)
      return false unless perm && perm.read?
    end

    user.allowed_to?(permission, project)
  end
end
