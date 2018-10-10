module RedminePulls
  module Services
    class PullRefreshService < PullBaseService
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
        @pull.close unless @pull.head_branch_exists?
      end

      def detect_new_commits
        return if pull.closed?

        commit_base_revision = @pull.repository.merge_base(@pull.commit_base, @pull.commit_head)
        commit_head_revision = @pull.repository.scm.revisions(nil, @pull.commit_base, @pull.commit_head).collect {|revision| revision.identifier}.first

        @pull.commit_base_revision = commit_base_revision unless commit_base_revision.blank?
        @pull.commit_head_revision = commit_head_revision unless commit_head_revision.blank?
      end

      def detect_manually_merged
        return if pull.closed?

        @pull.mark_as_merged if @pull.repository.is_ancestor? @pull.commit_head_revision, @pull.commit_base
      end

      def reload_merge_status
        return unless pull.merge_status == 'unchecked'

        if ! @pull.base_branch_exists? || ! @pull.commit_base_revision
          @pull.mark_as_unmergeable
        elsif @pull.repository.scm.mergable(@pull.commit_base, @pull.commit_head)
          @pull.mark_as_mergeable
        else
          @pull.mark_as_conflicts
        end
      end

      def notify_about_new_commits
        #
      end
    end
  end
end
