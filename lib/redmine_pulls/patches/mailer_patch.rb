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
          #
        end

        def pull_merged(pull)
          @author = User.current
          @pull = pull
          @pull_url = url_for(:controller => 'pulls', :action => 'show', :id => @pull)

          redmine_headers 'Project' => @pull.project.identifier,
                          'Pull-Id' => @pull.id,
                          'Pull-Author' => @pull.author.login
          redmine_headers 'Pull-Assignee' => @pull.assigned_to.login if @pull.assigned_to
          message_id @pull

          mail :to => @pull.author,
               :cc => (@pull.watchers + @pull.reviewers).uniq,
               :subject => @pull.mail_subject
        end

        def pull_closed(pull)
          @author = User.current
          @pull = pull
          @pull_url = url_for(:controller => 'pulls', :action => 'show', :id => @pull)

          redmine_headers 'Project' => @pull.project.identifier,
                          'Pull-Id' => @pull.id,
                          'Pull-Author' => @pull.author.login
          redmine_headers 'Pull-Assignee' => @pull.assigned_to.login if @pull.assigned_to
          message_id @pull

          mail :to => @pull.author,
               :cc => (@pull.watchers + @pull.reviewers).uniq,
               :subject => @pull.mail_subject
        end

        def pull_reopen(pull)
          @author = User.current
          @pull = pull
          @pull_url = url_for(:controller => 'pulls', :action => 'show', :id => @pull)

          redmine_headers 'Project' => @pull.project.identifier,
                          'Pull-Id' => @pull.id,
                          'Pull-Author' => @pull.author.login
          redmine_headers 'Pull-Assignee' => @pull.assigned_to.login if @pull.assigned_to
          message_id @pull

          mail :to => @pull.author,
               :cc => (@pull.watchers + @pull.reviewers).uniq,
               :subject => @pull.mail_subject
        end

        def pull_push(pull)
          #
        end

        def pull_unmergable(pull)
          #
        end

        def pull_new_mentions(pull)
          #
        end

        def pull_approved(review)
          @author = User.current
          @review = review
          @pull = review.pull
          @reviewer = review.reviewer
          @pull_url = url_for(:controller => 'pulls', :action => 'show', :id => @pull)

          redmine_headers 'Project' => @pull.project.identifier,
                          'Pull-Id' => @pull.id,
                          'Pull-Author' => @pull.author.login,
                          'Pull-Reviewer' => @reviewer.login
          redmine_headers 'Pull-Assignee' => @pull.assigned_to.login if @pull.assigned_to
          message_id @pull

          mail :to => @pull.author,
               :cc => (@pull.watchers + @pull.reviewers - [@pull.author]).uniq,
               :subject => @pull.mail_subject
        end

        def pull_changes_requested(review)
          @author = User.current
          @review = review
          @pull = review.pull
          @reviewer = review.reviewer
          @pull_url = url_for(:controller => 'pulls', :action => 'show', :id => @pull)

          redmine_headers 'Project' => @pull.project.identifier,
                          'Pull-Id' => @pull.id,
                          'Pull-Author' => @pull.author.login,
                          'Pull-Reviewer' => @reviewer.login
          redmine_headers 'Pull-Assignee' => @pull.assigned_to.login if @pull.assigned_to
          message_id @pull

          mail :to => @pull.author,
               :cc => (@pull.watchers + @pull.reviewers - [@pull.author]).uniq,
               :subject => @pull.mail_subject
        end

        def pull_review_requested(review)
          @author = User.current
          @review = review
          @pull = review.pull
          @reviewer = review.reviewer
          @pull_url = url_for(:controller => 'pulls', :action => 'show', :id => @pull)

          redmine_headers 'Project' => @pull.project.identifier,
                          'Pull-Id' => @pull.id,
                          'Pull-Author' => @pull.author.login,
                          'Pull-Reviewer' => @reviewer.login
          redmine_headers 'Pull-Assignee' => @pull.assigned_to.login if @pull.assigned_to
          message_id @pull

          mail :to => review.reviewer,
               :subject => @pull.mail_subject
        end
      end
    end
  end
end

unless Mailer.included_modules.include?(RedminePulls::Patches::Mailer)
  Mailer.send(:include, RedminePulls::Patches::Mailer)
end
