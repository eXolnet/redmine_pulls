require_dependency 'mailer'

module RedminePulls
  module Patches
    module MailerPatch
      extend ActiveSupport::Concern

      included do
        include InstanceMethods
      end

      class_methods do
        def deliver_pull_added(pull)
          # Reviewers should not be notified since they will recived a separate
          # email asking them to review the pull request
          users = pull_recipients(pull) - pull.reviewers

          users.each { |user| pull_added(user, pull).deliver_later }
        end

        def deliver_pull_merged(pull)
          pull_recipients(pull).each { |user| pull_merged(user, pull).deliver_later }
        end

        def deliver_pull_closed(pull)
          pull_recipients(pull).each { |user| pull_closed(user, pull).deliver_later }
        end

        def deliver_pull_reopen(pull)
          pull_recipients(pull).each { |user| pull_reopen(user, pull).deliver_later }
        end

        def deliver_pull_push(pull)
          #
        end

        def deliver_pull_unmergable(pull)
          pull_recipients(pull).each { |user| pull_unmergable(user, pull).deliver_later }
        end

        def deliver_pull_new_mentions(pull)
          #
        end

        def deliver_pull_approved(review)
          pull_recipients(review.pull).each { |user| pull_approved(user, review).deliver_later }
        end

        def deliver_pull_changes_requested(review)
          pull_recipients(review.pull).each { |user| pull_changes_requested(user, review).deliver_later }
        end

        def deliver_pull_review_requested(review)
          pull_review_requested(review.reviewer, review).deliver_later
        end

        private

        def pull_recipients(pull)
          pull.notified_users | pull.notified_following_users
        end
      end

      module InstanceMethods
        def pull_added(user, pull)
          pull_mail(user, pull)
        end

        def pull_merged(user, pull)
          pull_mail(user, pull)
        end

        def pull_closed(user, pull)
          pull_mail(user, pull)
        end

        def pull_reopen(user, pull)
          pull_mail(user, pull)
        end

        def pull_push(user, pull)
          #
        end

        def pull_unmergable(user, pull)
          pull_mail(user, pull)
        end

        def pull_new_mentions(user, pull)
          #
        end

        def pull_approved(user, review)
          pull_review_mail(user, review.pull, review)
        end

        def pull_changes_requested(user, review)
          pull_review_mail(user, review.pull, review)
        end

        def pull_review_requested(user, review)
          pull_mail(user, review.pull, review)
        end

        private

        def pull_mail(user, pull, review = nil)
          @author = User.current
          @pull = pull
          @pull_url = url_for(:controller => 'pulls', :action => 'show', :id => @pull)

          redmine_headers 'Project' => @pull.project.identifier,
                          'Pull-Id' => @pull.id,
                          'Pull-Author' => @pull.author.login
          redmine_headers 'Pull-Assignee' => @pull.assigned_to.login if @pull.assigned_to
          message_id @pull

          if review
            @review = review
            @reviewer = review.reviewer
  
            redmine_headers 'Pull-Reviewer' => @reviewer.login
          end

          mail :to => user, :subject => pull.mail_subject
        end
      end
    end
  end
end

unless Mailer.included_modules.include?(RedminePulls::Patches::MailerPatch)
  Mailer.send(:include, RedminePulls::Patches::MailerPatch)
end
