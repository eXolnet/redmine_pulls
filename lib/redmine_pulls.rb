require 'redmine_pulls/hooks/views_layouts_hook'
require 'redmine_pulls/hooks/display_related_pulls_in_issues'

require 'redmine_pulls/patches/adapters/abstract_adapter_helper'
require 'redmine_pulls/patches/adapters/git_adapter_helper'
require 'redmine_pulls/patches/application_helper_patch'
require 'redmine_pulls/patches/issue_patch'
require 'redmine_pulls/patches/journal_patch'
require 'redmine_pulls/patches/mailer_patch'
require 'redmine_pulls/patches/notifiable_patch'
require 'redmine_pulls/patches/projects_helper_patch'
require 'redmine_pulls/patches/queries_helper_patch'
require 'redmine_pulls/patches/repository_patch'
require 'redmine_pulls/patches/routes_helper_patch'

if Redmine::Plugin.installed? :redmine_git_hosting
  require 'redmine_pulls/patches/adapters/xitolite_adapter_adapter'
end
