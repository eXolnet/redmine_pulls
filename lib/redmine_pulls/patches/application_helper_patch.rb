require_dependency 'application_helper'

module RedminePulls
  module Patches
    module ApplicationHelperPatch
      extend ActiveSupport::Concern

      included do
        include InstanceMethods
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
