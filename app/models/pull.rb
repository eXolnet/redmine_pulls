class Pull < ActiveRecord::Base
  include Redmine::SafeAttributes

  belongs_to :project
  belongs_to :status, :class_name => 'IssueStatus'
  belongs_to :author, :class_name => 'User'
  belongs_to :assigned_to, :class_name => 'Principal'
  belongs_to :fixed_version, :class_name => 'Version'
  belongs_to :priority, :class_name => 'IssuePriority'
  belongs_to :category, :class_name => 'IssueCategory'

  validates_presence_of :subject, :project
  validates_presence_of :priority, :if => Proc.new {|issue| issue.new_record? || issue.priority_id_changed?}
  validates_presence_of :status, :if => Proc.new {|issue| issue.new_record? || issue.status_id_changed?}
  validates_presence_of :author, :if => Proc.new {|issue| issue.new_record? || issue.author_id_changed?}

  validates_length_of :subject, :maximum => 255
  attr_protected :id

  safe_attributes 'project_id',
                  'repository_id',
                  'status_id',
                  'category_id',
                  'assigned_to_id',
                  'priority_id',
                  'fixed_version_id',
                  'subject',
                  'description',
                  'branch_base',
                  'branch_compare'

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
end
