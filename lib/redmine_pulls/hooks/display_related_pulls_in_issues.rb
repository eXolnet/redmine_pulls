module RedminePulls
  module Hooks
    class DisplayRelatedPullsInIssues < Redmine::Hook::ViewListener
      render_on :view_issues_show_description_bottom, :partial => 'issues/pull_relations'
    end
  end
end
