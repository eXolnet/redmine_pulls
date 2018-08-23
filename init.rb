require 'redmine'

#Rails.configuration.to_prepare do
#  require_dependency 'redmine_pull_requests/patches/...'
#end

# Configure our plugin
Redmine::Plugin.register :code_audit do
  name 'Pull Requests'
  author 'eXolnet'
  description 'Allows users to create pull requests for repositories linked to projects.'
  version '0.1.0'
  url 'https://github.com/eXolnet/redmine-pull-requests'
  author_url 'https://www.exolnet.com'

  #project_module :audits do
  #  permission :view_audits, { :audits => [:index] }
  #end

  menu :project_menu, :pulls, { :controller => 'pulls', :action => 'index' }, :caption => 'Pull requests', :after => :issues, :param => :project_id
end
