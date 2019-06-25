require_dependency 'issue'

module RedminePulls
  module Patches
    module IssuePatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development

          has_and_belongs_to_many :pulls, :join_table => 'pull_issues', :readonly => true
        end
      end

      module InstanceMethods
        #
      end
    end
  end
end

unless Issue.included_modules.include?(RedminePulls::Patches::IssuePatch)
  Issue.send(:include, RedminePulls::Patches::IssuePatch)
end
