require_dependency 'redmine/scm/adapters/git_adapter'

module RedminePulls
  module Patches
    module GitAdapterPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
        end
      end

      module InstanceMethods
        def mergable(commit_base, commit_head)
          cmd_args = %w|merge-base|
          cmd_args << commit_base
          cmd_args << commit_head

          merge_base = nil
          git_cmd(cmd_args) { |io| io.binmode; merge_base = io.read }

          # We need a common ancestor to perform a merge
          return false unless merge_base

          cmd_args = %w|merge-tree|
          cmd_args << merge_base.strip
          cmd_args << commit_base
          cmd_args << commit_head

          merge_result = nil
          git_cmd(cmd_args) { |io| io.binmode; merge_result = io.read }

          ! (merge_result =~ /<<<<<<<.*=======.*>>>>>>>/m)
        end
      end
    end
  end
end

unless Redmine::Scm::Adapters::GitAdapter.included_modules.include?(RedminePulls::Patches::GitAdapterPatch)
  Redmine::Scm::Adapters::GitAdapter.send(:include, RedminePulls::Patches::GitAdapterPatch)
end

