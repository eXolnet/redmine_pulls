require 'redmine'

Redmine::Plugin.register :redmine_pulls do
  name 'Pull Requests'
  author 'eXolnet'
  description 'Allows users to create pull requests for repositories linked to projects.'
  version '0.1.0'
  url 'https://github.com/eXolnet/redmine-pulls'
  author_url 'https://www.exolnet.com'

  requires_redmine :version_or_higher => '2.3'

  menu :project_menu, :pulls, { :controller => 'pulls', :action => 'index' }, :caption => 'Pull requests', :after => :issues, :param => :project_id

  project_module :pulls do
    permission :view_pulls, { :pulls => [:index] }
  end
end

require 'redmine_pulls'
