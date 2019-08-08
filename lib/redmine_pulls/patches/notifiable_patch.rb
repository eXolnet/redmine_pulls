module RedminePulls
  module Patches
    module Notifiable
      def self.included(base) # :nodoc:
        base.extend ClassMethods

        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development

          class << self
            alias_method :all_without_pulls, :all
            alias_method :all, :all_with_pulls
          end
        end
      end

      module ClassMethods
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

unless Redmine::Notifiable.included_modules.include?(RedminePulls::Patches::Notifiable)
  Redmine::Notifiable.send(:include, RedminePulls::Patches::Notifiable)
end
