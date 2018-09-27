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
    changes_count = pull.reviews.where(:status => PullReview::STATUS_CHANGES_REQUESTED).count
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
    changes_count = pull.reviews.where(:status => PullReview::STATUS_CHANGES_REQUESTED).count
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
      {:name => 'files', :partial => 'pulls/files', :label => :label_files},
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
end
