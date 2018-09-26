require_dependency 'routes_helper'

module RedminePulls
  module Patches
    module RoutesHelperPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
        end
      end

      module InstanceMethods
        def _project_pulls_path(project, *args)
          if project
            project_pulls_path(project, *args)
          else
            pulls_path(*args)
          end
        end

        def _new_project_pull_path(project, *args)
          if project
            new_project_pull_path(project, *args)
          else
            new_pull_path(*args)
          end
        end
      end
    end
  end
end

unless RoutesHelper.included_modules.include?(RedminePulls::Patches::RoutesHelperPatch)
  RoutesHelper.send(:include, RedminePulls::Patches::RoutesHelperPatch)
end
