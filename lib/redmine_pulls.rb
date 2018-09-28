Rails.configuration.to_prepare do
  require 'redmine_pulls/patches/abstract_adapter_helper'
  require 'redmine_pulls/patches/application_helper_patch'
  require 'redmine_pulls/patches/git_adapter_helper'
  require 'redmine_pulls/patches/journal_patch'
  require 'redmine_pulls/patches/queries_helper_patch'
  require 'redmine_pulls/patches/routes_helper_patch'

  if Redmine::Plugin.installed? :redmine_git_hosting
    require 'redmine_pulls/patches/xitolite_adapter_adapter'
  end
end

module RedminePulls
end
