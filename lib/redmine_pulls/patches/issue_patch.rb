require_dependency 'issue'

module RedminePulls
  module Patches
    module IssuePatch
      extend ActiveSupport::Concern

      included do
        has_and_belongs_to_many :pulls, :join_table => 'pull_issues', :readonly => true
      end
    end
  end
end

unless Issue.included_modules.include?(RedminePulls::Patches::IssuePatch)
  Issue.send(:include, RedminePulls::Patches::IssuePatch)
end
