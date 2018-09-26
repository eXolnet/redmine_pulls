require_dependency 'application_helper'

module RedminePulls
  module Patches
    module ApplicationHelperPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
        end
      end

      module InstanceMethods
        def link_to_pull(pull, options={})
          text = options.delete(:text) || pull.summary

          link_to(h(text), {:controller => 'pulls', :action => 'show', :id => pull}, :title => text)
        end
      end
    end
  end
end

unless ApplicationHelper.included_modules.include?(RedminePulls::Patches::ApplicationHelperPatch)
  ApplicationHelper.send(:include, RedminePulls::Patches::ApplicationHelperPatch)
end
