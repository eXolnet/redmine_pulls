require 'redmine'

PULLS_VERSION_NUMBER = '0.1.0'
PULLS_VERSION_TYPE = "Light version"

Redmine::Plugin.register :redmine_pulls do
  name "Pull Requests (#{PULLS_VERSION_TYPE})"
  author 'eXolnet'
  description 'Allows users to create pull requests for repositories linked to projects.'
  version PULLS_VERSION_NUMBER
  url 'https://github.com/eXolnet/redmine-pulls'
  author_url 'https://www.exolnet.com'

  requires_redmine :version_or_higher => '2.3'

  menu :application_menu, :pulls, { :controller => 'pulls', :action => 'index' }, :caption => :label_pulls, :after => :issues
  menu :project_menu, :pulls, { :controller => 'pulls', :action => 'index' }, :caption => :label_pulls, :after => :issues, :param => :project_id
  menu :project_menu, :new_pull, { :controller => 'pulls', :action => 'new' }, :caption => :label_new_pull, :after => :new_issue_sub, :param => :project_id, :parent => :new_object

  project_module :pulls do
    permission :view_pulls,            { :pulls => [:index, :show] }, :read => true
    permission :add_pulls,             { :pulls => [:new, :create, :commit] }
    permission :edit_pulls,            { :pulls => [:edit, :update] }
    permission :delete_pulls,          { :pulls => [:destroy] }, :require => :member

    # Notes
    permission :add_pull_notes,        {}
    permission :edit_pull_notes,       {}
    permission :edit_own_pull_notes,   {}

    # Watchers
    permission :view_pull_watchers,    {}, :read => true
    permission :add_pull_watchers,     {:watchers => [:new, :create, :append, :autocomplete_for_user]}
    permission :delete_pull_watchers,  {:watchers => :destroy}

    # Related issues
    permission :manage_pull_relations, {}
  end
end

require 'redmine_pulls'
