module PullsHelper
  def find_pull
    pull_id = params[:pull_id] || params[:id]

    @pull = Pull.find(pull_id)
    raise Unauthorized unless @pull.visible?
    @project = @pull.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def ensure_project_has_repository
    # Do not validate on the global pulls page
    return unless @project

    return if @project.repository&.default_branch.present?

    render :template => 'pulls/no_repository'
  end

  # Returns an array of users that are proposed as watchers
  # on the new issue form
  def users_for_new_pull_reviewers(pull)
    users = users_for_new_pull(pull)

    users.select{|user| pull.reviewable?(user) }
  end

  # Returns an array of users that are proposed as watchers
  # on the new issue form
  def users_for_new_pull_watchers(pull)
    users_for_new_pull(pull)
  end

  def pull_reviewers_checkboxes(object, users, checked=nil)
    pull_users_checkboxes('reviewer_ids', object, users, checked)
  end

  def pull_watchers_checkboxes(object, users, checked=nil)
    pull_users_checkboxes('watcher_user_ids', object, users, checked)
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

  def pull_tabs(pull)
    tabs = [
      {:name => 'conversation', :partial => 'pulls/conversation', :label => :label_conversation},
    ]

    tabs << {:name => 'commits', :partial => 'pulls/commits', :label => :label_commits} unless pull.broken?
    tabs << {:name => 'changes', :partial => 'pulls/changes', :label => :label_changes} unless pull.broken?

    tabs
  end

  def available_pull_priorities
    IssuePriority.active
  end

  def pull_query(body, project, query = {})
    query[:utf8] = '✓'
    query[:set_filter] = 1

    classes = 'query'

    # Wrong way of doing it
    # if query.to_param == request.query_string
    #  classes << ' selected'
    # end

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

  def get_pull_changes_from
    params[:changes_from].presence
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

  def merge_pull(pull)
    return unless pull.mergable?

    pull.repository.merge(
      pull.commit_base,
      pull.commit_head,
      message: pull.merge_commit_message,
      author_name: pull.merge_commit_author_name,
      author_email: pull.merge_commit_author_email
    )

    pull.mark_as_merged
  end

  private

  def pull_users_checkboxes(name, object, users, checked=nil)
    users.map do |user|
      c = checked.nil? ? object.watched_by?(user) : checked
      tag = check_box_tag "pull[#{name}][]", user.id, c, :id => nil
      content_tag 'label', "#{tag} #{h(user)}".html_safe,
                  :id => "pull_#{name}_#{user.id}",
                  :class => "floating"
    end.join.html_safe
  end

  def users_for_new_pull(pull)
    users = pull.reviewers.select{|u| u.status == User::STATUS_ACTIVE}

    if pull.project.users.count <= 20
      users = (users + pull.project.users.sort).uniq
    end

    users
  end

  def render_pull_relations(pull)
    manage_relations = User.current.allowed_to?(:manage_pull_relations, pull.project)

    relations = pull.issues.visible.collect do |issue|
      delete_link = link_to(l(:label_relation_delete),
                            {:controller => 'pull_issues', :action => 'destroy', :pull_id => @pull, :issue_id => issue},
                            :remote => true,
                            :method => :delete,
                            :data => {:confirm => l(:text_are_you_sure)},
                            :title => l(:label_relation_delete),
                            :class => 'icon-only icon-link-break')

      relation = ''.html_safe

      relation << content_tag('td', check_box_tag("ids[]", issue.id, false, :id => nil), :class => 'checkbox')
      relation << content_tag('td', link_to_issue(issue, :project => Setting.cross_project_issue_relations?).html_safe, :class => 'subject', :style => 'width: 50%')
      relation << content_tag('td', issue.status, :class => 'status')
      relation << content_tag('td', issue.start_date, :class => 'start_date')
      relation << content_tag('td', issue.due_date, :class => 'due_date')
      relation << content_tag('td', progress_bar(issue.done_ratio), :class=> 'done_ratio') unless issue.disabled_core_fields.include?('done_ratio')
      relation << content_tag('td', delete_link, :class => 'buttons') if manage_relations

      content_tag('tr', relation, :id => "relation-#{issue.id}", :class => "issue hascontextmenu #{issue.css_classes}")
    end

    content_tag('table', relations.join.html_safe, :class => 'list issues odd-even')
  end
end
