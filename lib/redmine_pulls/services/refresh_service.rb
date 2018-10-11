module RedminePulls
  module Services
    class RefreshService < BaseService
      def execute
        return if @pull.closed?

        close_when_head_is_missing
        detect_new_commits
        detect_manually_merged
        reload_merge_status
      rescue Redmine::Scm::Adapters::AbstractAdapter::ScmCommandAborted
        # do nothing
      end

      private

      def close_when_head_is_missing
        return if @pull.head_branch_exists?

        @pull.close
      end

      def detect_new_commits
        return if @pull.closed? || @pull.branch_missing?

        # First, detect the last commit in the head branch
        @pull.commit_head_revision = last_head_revision

        return if is_merged

        # Next, detect the first ancestor of both branches
        commit_base_revision = branch_point_revision
        @pull.commit_base_revision = commit_base_revision unless commit_base_revision.blank?
      end

      def detect_manually_merged
        return if @pull.closed? || @pull.commit_head_revision.blank?

        @pull.mark_as_merged if is_merged
      end

      def reload_merge_status
        return unless @pull.merge_status == 'unchecked'

        if @pull.branch_missing?
          @pull.mark_as_unmergeable
        elsif @pull.repository.mergable?(@pull.commit_base, @pull.commit_head)
          @pull.mark_as_mergeable
        else
          @pull.mark_as_conflicts
        end
      end

      def notify_about_new_commits
        #
      end

      private

      def is_merged
        @pull.repository.is_ancestor? @pull.commit_head_revision, @pull.commit_base
      end

      def last_head_revision
        @pull.repository.scm.revisions(nil, nil, @pull.commit_head, :reverse => true, :limit => 1).first&.identifier
      end

      def branch_point_revision
        @pull.repository.scm.merge_base(@pull.commit_base, @pull.commit_head)
      end
    end
  end
end
