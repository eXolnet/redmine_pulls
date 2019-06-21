class PullSettingsController < ApplicationController
  before_action :find_project_by_project_id

  def update
    return render_403 unless editable?

    attrs = (params[:repository] || {}).deep_dup

    repository = @project.repository
    repository.pull_default_branch = attrs[:pull_default_branch]
    repository.save!

    flash[:notice] = l(:notice_successful_update)
    redirect_to settings_project_path(@project, :tab => 'pulls')
  end

  private

  def editable?
    User.current.allowed_to?(:manage_pulls, @project)
  end
end
