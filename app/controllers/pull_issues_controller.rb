class PullIssuesController < ApplicationController
  before_action :find_pull
  before_action :ensure_authorized

  helper :pulls
  include PullsHelper

  def create
    issue_id = params[:issue_id].to_s.sub(/^#/,'')
    @issue = @pull.find_referenced_issue_by_id(issue_id)

    if @issue && (!@issue.visible? || @pull.issues.include?(@issue))
      @issue = nil
    end

    if @issue
      @pull.init_journal(User.current)
      @pull.issues << @issue
    end
  end

  def destroy
    @issue = Issue.visible.find_by_id(params[:issue_id])

    if @issue
      @pull.init_journal(User.current)
      @pull.issues.delete(@issue)
    end
  end

  private

  def ensure_authorized
    raise Unauthorized unless User.current.allowed_to?(:manage_pull_relations, @pull.project)
  end
end
