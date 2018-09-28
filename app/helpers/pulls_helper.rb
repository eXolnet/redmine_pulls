module PullsHelper
  # Returns an array of users that are proposed as watchers
  # on the new issue form
  def users_for_new_pull_reviewers(pull)
    users = pull.reviewers.select{|u| u.status == User::STATUS_ACTIVE}
    if pull.project.users.count <= 20
      users = (users + pull.project.users.sort).uniq
    end
    users
  end

  def pull_reviewers_checkboxes(object, users, checked=nil)
    users.map do |user|
      c = checked.nil? ? object.watched_by?(user) : checked
      tag = check_box_tag 'pull[reviewer_ids][]', user.id, c, :id => nil
      content_tag 'label', "#{tag} #{h(user)}".html_safe,
                  :id => "pull_reviewer_ids_#{user.id}",
                  :class => "floating"
    end.join.html_safe
  end

  # Returns an array of users that are proposed as watchers
  # on the new issue form
  def users_for_new_pull_watchers(pull)
    users = pull.watcher_users.select{|u| u.status == User::STATUS_ACTIVE}
    if pull.project.users.count <= 20
      users = (users + pull.project.users.sort).uniq
    end
    users
  end

  def pull_watchers_checkboxes(object, users, checked=nil)
    users.map do |user|
      c = checked.nil? ? object.watched_by?(user) : checked
      tag = check_box_tag 'pull[watcher_user_ids][]', user.id, c, :id => nil
      content_tag 'label', "#{tag} #{h(user)}".html_safe,
                  :id => "pull_watcher_user_ids_#{user.id}",
                  :class => "floating"
    end.join.html_safe
  end

  def pull_review_title(pull)
    changes_count = pull.reviews.where(:status => PullReview::STATUS_CONCERNED).count
    pending_count = pull.reviews.where(:status => PullReview::STATUS_REQUESTED).count
    approved_count = pull.reviews.where(:status => PullReview::STATUS_APPROVED).count

    if changes_count > 0
      l(:label_changes_requested)
    elsif pending_count > 0
      l(:label_review_requested)
    elsif approved_count > 0
      l(:label_changes_approved)
    else
      l(:label_no_review_requested)
    end
  end

  def pull_review_description(pull)
    changes_count = pull.reviews.where(:status => PullReview::STATUS_CONCERNED).count
    approved_count = pull.reviews.where(:status => PullReview::STATUS_APPROVED).count
    pending_count = pull.reviews.where(:status => PullReview::STATUS_REQUESTED).count

    list = []

    list << l(:label_x_review_requesting_changes, changes_count) if changes_count > 0
    list << l(:label_x_approving_review, approved_count) if approved_count > 0
    list << l(:label_x_pending_reviews, pending_count) if pending_count > 0

    list.join(', ')
  end

  def pull_tabs
    tabs = [
      {:name => 'conversation', :partial => 'pulls/conversation', :label => :label_conversation},
      {:name => 'commits', :partial => 'pulls/commits', :label => :label_commits},
      {:name => 'changes', :partial => 'pulls/changes', :label => :label_changes},
    ]
  end

  def pull_query(body, project, query = {})
    query[:utf8] = '✓'
    query[:set_filter] = 1

    classes = 'query'

    if query.to_param == request.query_string
      classes << ' selected'
    end

    link_to body, _project_pulls_path(project, query), :class => classes
  end

  def get_pull_diff_type
    diff_type = params[:type] || User.current.pref[:diff_type] || 'inline'
    diff_type = 'inline' unless %w(inline sbs).include?(diff_type)

    # Save diff type as user preference
    if User.current.logged? && diff_type != User.current.pref[:diff_type]
      User.current.pref[:diff_type] = diff_type
      User.current.preference.save
    end

    diff_type
  end

  def refresh_pull_state(pull)
    return if pull.closed? || pull.revisions.count == 0

    pull.commit_base_revision = pull.repository.scm.merge_base(pull.commit_base, pull.commit_head)
    pull.commit_head_revision = pull.revisions_ids.first

    if pull.merge_status == 'unchecked'
      calculate_pull_merge_status(pull)
    end
  end

  def calculate_pull_review_status(pull)
    changes_count = pull.reviews.where(:status => PullReview::STATUS_CONCERNED).count
    pending_count = pull.reviews.where(:status => PullReview::STATUS_REQUESTED).count
    approved_count = pull.reviews.where(:status => PullReview::STATUS_APPROVED).count

    if changes_count > 0
      pull.mark_as_changes_concerned
    elsif pending_count > 0
      pull.mark_as_review_requested
    elsif approved_count > 0
      pull.mark_as_changes_approved
    else
      pull.mark_as_unreviewed
    end
  end

  def calculate_pull_merge_status(pull)
    if ! pull.is_commit_base_a_branch? || ! pull.commit_base_revision
      pull.mark_as_unmergeable
    elsif pull.repository.scm.mergable(pull.commit_base, pull.commit_head)
      pull.mark_as_mergeable
    else
      pull.mark_as_conflicts
    end
  end

  def merge_pull(pull)
    return unless pull.mergable?

    pull.mark_as_merged
  end
end
