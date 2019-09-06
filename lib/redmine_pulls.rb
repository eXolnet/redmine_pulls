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

module RedminePulls
  include Redmine::I18n

  class << self
    def menu_caption(project = nil)
      caption = l(:label_pulls)

      # Add actionnable count, if greather than zero
      actionableQuery = Pull.actionable

      if project
        actionableQuery = actionableQuery.where("#{Pull.table_name}.project_id = ?", project.id)
      end

      actionableCount = actionableQuery.count

      if actionableCount > 0
        caption << " <span class='count'>#{actionableCount}</span>"
      end

      caption.html_safe
    end
  end
end
