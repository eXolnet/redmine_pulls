require_dependency 'redmine/scm/adapters/xitolite_adapter'

module RedminePulls
  module Patches
    module Adapters
      module XitoliteAdapterPatch
        extend RedminePulls::Patches::Adapters::GitAdapterPatch
      end
    end
  end
end

unless Redmine::Scm::Adapters::XitoliteAdapter.included_modules.include?(RedminePulls::Patches::Adapters::XitoliteAdapterPatch)
  Redmine::Scm::Adapters::XitoliteAdapter.send(:include, RedminePulls::Patches::Adapters::XitoliteAdapterPatch)
end

