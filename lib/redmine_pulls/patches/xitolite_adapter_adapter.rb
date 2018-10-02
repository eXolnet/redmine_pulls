require_dependency 'redmine/scm/adapters/xitolite_adapter'

module RedminePulls
  module Patches
    module XitoliteAdapterPatch
      def self.included(base) # :nodoc:
        base.send(:include, RedminePulls::Patches::GitAdapterPatch::InstanceMethods)

        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
        end
      end
    end
  end
end

unless Redmine::Scm::Adapters::XitoliteAdapter.included_modules.include?(RedminePulls::Patches::XitoliteAdapterPatch)
  Redmine::Scm::Adapters::XitoliteAdapter.send(:include, RedminePulls::Patches::XitoliteAdapterPatch)
end

