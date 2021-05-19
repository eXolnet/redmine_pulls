module RedminePulls
  module Patches
    module NotifiablePatch
      extend ActiveSupport::Concern

      included do
        class << self
          alias_method :all_without_pulls, :all
          alias_method :all, :all_with_pulls
        end
      end

      class_methods do
        def all_with_pulls
          notifications = all_without_pulls

          notifications << Redmine::Notifiable.new('pull_added')
          notifications << Redmine::Notifiable.new('pull_merged')
          notifications << Redmine::Notifiable.new('pull_closed')
          notifications << Redmine::Notifiable.new('pull_reopen')
          notifications << Redmine::Notifiable.new('pull_push')
          notifications << Redmine::Notifiable.new('pull_unmergable')
          notifications << Redmine::Notifiable.new('pull_new_mentions')
          notifications << Redmine::Notifiable.new('pull_approved')
          notifications << Redmine::Notifiable.new('pull_changes_requested')
          notifications << Redmine::Notifiable.new('pull_review_requested')

          notifications
        end
      end
    end
  end
end

unless Redmine::Notifiable.included_modules.include?(RedminePulls::Patches::NotifiablePatch)
  Redmine::Notifiable.send(:include, RedminePulls::Patches::NotifiablePatch)
end
