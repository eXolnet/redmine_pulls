require_dependency 'projects_helper'

module RedminePulls
  module Patches
    module ProjectsHelperPatch
      extend ActiveSupport::Concern

      included do
        include InstanceMethods

        alias_method :project_settings_tabs_without_pulls, :project_settings_tabs
        alias_method :project_settings_tabs, :project_settings_tabs_with_pulls
      end

      module InstanceMethods
        def project_settings_tabs_with_pulls
          tabs = project_settings_tabs_without_pulls

          if User.current.allowed_to?(:manage_pulls, @project)
            tabs << { :name => 'pulls',
                      :action => :manage_pulls,
                      :partial => 'projects/settings/pulls',
                      :label => :label_pulls }
          end

          tabs
        end
      end
    end
  end
end

unless ProjectsHelper.included_modules.include?(RedminePulls::Patches::ProjectsHelperPatch)
  ProjectsHelper.send(:include, RedminePulls::Patches::ProjectsHelperPatch)
end
