require 'redmine'

PULLS_VERSION_NUMBER = '1.2.1'
PULLS_VERSION_TYPE = "Light version"

Redmine::Plugin.register :redmine_pulls do
  name "Pull Requests (#{PULLS_VERSION_TYPE})"
  author 'eXolnet'
  description 'Allows users to create pull requests for repositories linked to projects.'
  version PULLS_VERSION_NUMBER
  url 'https://github.com/eXolnet/redmine_pulls'
  author_url 'https://www.exolnet.com'

  requires_redmine :version_or_higher => '2.4'

  menu :application_menu, :pulls, { :controller => 'pulls', :action => 'index' }, :caption => Proc.new {|project| RedminePulls.menu_caption(project) }, :after => :issues, :if => Proc.new { User.current.allowed_to?(:view_pulls, nil, :global => true) }
  menu :project_menu, :pulls, { :controller => 'pulls', :action => 'index' }, :caption => Proc.new {|project| RedminePulls.menu_caption(project) }, :after => :issues, :param => :project_id
  menu :project_menu, :new_pull, { :controller => 'pulls', :action => 'new' }, :caption => :label_new_pull, :after => :new_issue_sub, :param => :project_id, :parent => :new_object

  project_module :pulls do
    permission :view_pulls,            { :pulls => [:index, :show] }, :read => true
    permission :add_pulls,             { :pulls => [:new, :create, :commit] }
    permission :edit_pulls,            { :pulls => [:edit, :update] }
    permission :delete_pulls,          { :pulls => [:destroy] }, :require => :member

    # Reviews
    permission :review_pull,           {}
    permission :add_pull_reviewers,    {}
    permission :delete_pull_reviewers, {}

    # Watchers
    permission :view_pull_watchers, {}, :read => true
    permission :add_pull_watchers, {:watchers => [:new, :create, :append, :autocomplete_for_user]}
    permission :delete_pull_watchers, {:watchers => :destroy}

    # Related issues
    permission :manage_pull_relations, {}

    # Related issues
    permission :manage_pulls, {}
  end

  # Pulls are added to the activity view
  activity_provider :pulls, :class_name => ['Pull', 'Journal']
end

require 'redmine_pulls'
