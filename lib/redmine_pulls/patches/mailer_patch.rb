require_dependency 'mailer'

module RedminePulls
  module Patches
    module Mailer
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
        end
      end

      module InstanceMethods
        def pull_added(pull)
          pull_headers(pull)

          # Reviewers should not be notified since they will recived a separate
          # email asking them to review the pull request
          mail :to => @pull.notified_users - @pull.reviewers,
               :cc => @pull.notified_following_users - @pull.reviewers,
               :subject => @pull.mail_subject
        end

        def pull_merged(pull)
          pull_headers(pull)

          mail :to => @pull.notified_users,
               :cc => @pull.notified_following_users,
               :subject => @pull.mail_subject
        end

        def pull_closed(pull)
          pull_headers(pull)

          mail :to => @pull.notified_users,
               :cc => @pull.notified_following_users,
               :subject => @pull.mail_subject
        end

        def pull_reopen(pull)
          pull_headers(pull)

          mail :to => @pull.notified_users,
               :cc => @pull.notified_following_users,
               :subject => @pull.mail_subject
        end

        def pull_push(pull)
          #
        end

        def pull_unmergable(pull)
          pull_headers(pull)

          mail :to => @pull.notified_users,
               :cc => @pull.notified_following_users,
               :subject => @pull.mail_subject
        end

        def pull_new_mentions(pull)
          #
        end

        def pull_approved(review)
          pull_review_headers(review)

          mail :to => @pull.notified_users,
               :cc => @pull.notified_following_users,
               :subject => @pull.mail_subject
        end

        def pull_changes_requested(review)
          pull_review_headers(review)

          mail :to => @pull.notified_users,
               :cc => @pull.notified_following_users,
               :subject => @pull.mail_subject
        end

        def pull_review_requested(review)
          pull_review_headers(review)

          mail :to => review.reviewer,
               :subject => @pull.mail_subject
        end

        private

        def pull_headers(pull)
          @author = User.current
          @pull = pull
          @pull_url = url_for(:controller => 'pulls', :action => 'show', :id => @pull)

          redmine_headers 'Project' => @pull.project.identifier,
                          'Pull-Id' => @pull.id,
                          'Pull-Author' => @pull.author.login
          redmine_headers 'Pull-Assignee' => @pull.assigned_to.login if @pull.assigned_to
          message_id @pull
        end

        def pull_review_headers(review)
          pull_headers(review.pull)

          @review = review
          @reviewer = review.reviewer

          redmine_headers 'Pull-Reviewer' => @reviewer.login
        end
      end
    end
  end
end

unless Mailer.included_modules.include?(RedminePulls::Patches::Mailer)
  Mailer.send(:include, RedminePulls::Patches::Mailer)
end
