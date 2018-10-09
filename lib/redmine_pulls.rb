require 'redmine_pulls/patches/adapters/abstract_adapter_helper'
require 'redmine_pulls/patches/adapters/git_adapter_helper'
require 'redmine_pulls/patches/application_helper_patch'
require 'redmine_pulls/patches/journal_patch'
require 'redmine_pulls/patches/queries_helper_patch'
require 'redmine_pulls/patches/routes_helper_patch'

if Redmine::Plugin.installed? :redmine_git_hosting
  require 'redmine_pulls/patches/adapters/xitolite_adapter_adapter'
end
