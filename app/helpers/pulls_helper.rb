module PullsHelper
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

  def pull_tabs
    tabs = [
      {:name => 'history', :partial => 'pulls/history', :label => :label_history},
      {:name => 'commits', :partial => 'pulls/commits', :label => :label_commits},
      {:name => 'files', :partial => 'pulls/files', :label => :label_files},
    ]
  end
end
