class PullReviewersController < ApplicationController
  before_action :find_project

  include PullsHelper

  def new
    raise Unauthorized unless User.current.allowed_to?(:add_pull_reviewers, @project)

    @users = users_for_new_reviewer
  end

  def create
    raise Unauthorized unless User.current.allowed_to?(:add_pull_reviewers, @project)

    user_ids = []
    if params[:pull]
      user_ids << (params[:pull][:user_ids] || params[:pull][:user_id])
    else
      user_ids << params[:user_id]
    end

    users = User.active.visible.where(:id => user_ids.flatten.compact.uniq)

    users.each do |user|
        PullReview.create(:pull => @pull, :reviewer => user, :status => PullReview::STATUS_REQUESTED)
    end

    calculate_pull_review_status(@pull)

    respond_to do |format|
      format.html { redirect_to_referer_or {render :html => 'Reviewer added.', :status => 200, :layout => true}}
      format.js { @users = users_for_new_reviewer }
      format.api { render_api_ok }
    end
  end

  def destroy
    raise Unauthorized unless User.current.allowed_to?(:delete_pull_reviewers, @project)

    user = User.find(params[:user_id])

    @pull.reviews.where(:reviewer_id => user.id).delete_all

    calculate_pull_review_status(@pull)

    respond_to do |format|
      format.html { redirect_to_referer_or {render :html => 'Reviewer removed.', :status => 200, :layout => true} }
      format.js
      format.api { render_api_ok }
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def autocomplete_for_user
    raise Unauthorized unless User.current.allowed_to?(:add_pull_reviewers, @project)

    @users = users_for_new_reviewer
    render :layout => false
  end

  private

  def find_project
    if params[:pull_id]
      @pull = Pull.find(params[:pull_id])
      @project = @pull.project
    elsif params[:project_id]
      @project = Project.visible.find_by_param(params[:project_id])
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def users_for_new_reviewer
    scope = nil
    if params[:q].blank? && @project.present?
      scope = @project.users
    else
      scope = User.all.limit(100)
    end

    users = scope.active.visible.sorted.like(params[:q]).to_a

    if @pull.present?
      users -= @pull.reviewers
    end

    users
  end
end
