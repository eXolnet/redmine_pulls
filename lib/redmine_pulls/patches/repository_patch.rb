require_dependency 'repository'

module RedminePulls
  module Patches
    module Repository
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
        end
      end

      module InstanceMethods
        def delete_branch(identifier)
          scm.delete_branch(identifier)
        end

        def merge_base(commit_base, commit_head)
          scm.merge_base(commit_base, commit_head)
        end

        def mergable?(commit_base, commit_head)
          scm.mergable?(commit_base, commit_head)
        end
      end
    end
  end
end

unless Repository.included_modules.include?(RedminePulls::Patches::Repository)
  Repository.send(:include, RedminePulls::Patches::Repository)
end
