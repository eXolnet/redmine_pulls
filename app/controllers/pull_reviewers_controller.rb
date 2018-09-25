class PullReviewersController < ApplicationController
  before_action :find_pull

  helper RedminePulls::Helpers

  def new
    @users = users_for_new_reviewer
  end

  def create
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

    respond_to do |format|
      format.html { redirect_to_referer_or {render :html => 'Reviewer added.', :status => 200, :layout => true}}
      format.js { @users = users_for_new_reviewer }
      format.api { render_api_ok }
    end
  end

  def destroy
    user = User.find(params[:user_id])

    @pull.reviews.where(:reviewer_id => user.id).delete_all

    respond_to do |format|
      format.html { redirect_to_referer_or {render :html => 'Reviewer removed.', :status => 200, :layout => true} }
      format.js
      format.api { render_api_ok }
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def autocomplete_for_user
    @users = users_for_new_reviewer
    render :layout => false
  end

  private

  def find_pull
    @pull = Pull.find(params[:pull_id])
    @project = @pull.project
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
    users -= @pull.reviewers
    users
  end
end
