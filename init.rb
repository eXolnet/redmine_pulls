require 'redmine'

Redmine::Plugin.register :redmine_pulls do
  name 'Pull Requests'
  author 'eXolnet'
  description 'Allows users to create pull requests for repositories linked to projects.'
  version '0.1.0'
  url 'https://github.com/eXolnet/redmine-pulls'
  author_url 'https://www.exolnet.com'

  requires_redmine :version_or_higher => '2.3'
  #requires_redmine_plugin :redmine_git_hosting, :version_or_higher => '1.2.0'

  menu :application_menu, :pulls, { :controller => 'pulls', :action => 'index' }, :caption => :label_pulls, :after => :issues
  menu :project_menu, :pulls, { :controller => 'pulls', :action => 'index' }, :caption => :label_pulls, :after => :issues, :param => :project_id
  menu :project_menu, :new_pull, { :controller => 'pulls', :action => 'new' }, :caption => :label_new_pull, :after => :new_issue_sub, :param => :project_id, :parent => :new_object

  project_module :pulls do
    permission :view_pulls,           { :pulls => [:index, :show] }
    permission :add_pulls,            { :pulls => [:new, :create, :commit] }
    permission :edit_pulls,           { :pulls => [:edit, :update] }
    permission :delete_pulls,         { :pulls => [:destroy] }
    permission :add_pull_notes,       { :pulls => [] }
    permission :edit_pull_notes,      { :pulls => [] }
    permission :edit_own_pull_notes,  { :pulls => [] }
    permission :view_pull_watchers,   { :pulls => [] }
    permission :add_pull_watchers,    { :pulls => [] }
    permission :delete_pull_watchers, { :pulls => [] }
  end
end

require 'redmine_pulls'
