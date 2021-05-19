require_dependency 'repository'

module RedminePulls
  module Patches
    module Repository
      extend ActiveSupport::Concern

      included do
        include InstanceMethods
      end

      module InstanceMethods
        def create_branch(identifier, commit)
          scm.create_branch(identifier, commit)
        end

        def delete_branch(identifier)
          scm.delete_branch(identifier)
        end

        def merge_base(commit_base, commit_head)
          scm.merge_base(commit_base, commit_head)
        end

        def mergable?(commit_base, commit_head)
          scm.mergable?(commit_base, commit_head)
        end

        def merge(commit_base, commit_head, options = {})
          scm.merge(commit_base, commit_head, options)
        end

        def revision(identifier)
          scm.revision(identifier)
        end

        def is_ancestor?(commit_ancestor, commit_descendant)
          scm.is_ancestor?(commit_ancestor, commit_descendant)
        end

        def conflicting_files(commit_base, commit_head)
          scm.conflicting_files(commit_base, commit_head)
        end

        def pull_default_branch
          h = extra_info || {}

          h["pull_default_branch"] || scm.default_branch
        end

        def pull_default_branch=(branch)
          merge_extra_info "pull_default_branch" => branch
        end

        def pull_delete_branch
          h = extra_info || {}

          h["pull_delete_branch"] || false
        end

        def pull_delete_branch=(value)
          merge_extra_info "pull_delete_branch" => value
        end
      end
    end
  end
end

unless Repository.included_modules.include?(RedminePulls::Patches::Repository)
  Repository.send(:include, RedminePulls::Patches::Repository)
end
