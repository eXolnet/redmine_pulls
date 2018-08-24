class PullsController < ApplicationController
  unloadable

  menu_item :pulls

  before_action :find_optional_project, :only => [:index]

  def index
    @project = Project.find(params[:project_id])
    @pulls = []
  end

  def new
    @project = Project.find(params[:project_id])
    # TODO
  end

  def create
    @project = Project.find(params[:project_id])
    # TODO
  end

  def show
    @project = Project.find(params[:project_id])
    # TODO
  end

  def edit
    @project = Project.find(params[:project_id])
    # TODO
  end

  def update
    @project = Project.find(params[:project_id])
    # TODO
  end

  def destroy
    @project = Project.find(params[:project_id])
    # TODO
  end
end
