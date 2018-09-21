class PullsController < ApplicationController
  default_search_scope :pulls
  menu_item :pulls

  before_action :find_pull, :only => [:show, :edit, :update, :destroy]
  before_action :find_optional_project, :only => [:index, :new, :create]
  before_action :ensure_project_has_repository
  before_action :build_new_pull_from_params, :only => [:new, :create]

  rescue_from Query::StatementInvalid, :with => :query_statement_invalid

  helper :projects
  helper :issues
  helper :watchers
  helper :queries
  include QueriesHelper
  helper :repositories
  helper RedminePulls::Helpers

  def index
    retrieve_query(PullQuery)

    if @query.valid?
      respond_to do |format|
        format.html {
          @pull_count = @query.pull_count
          @pull_pages = Paginator.new @pull_count, per_page_option, params['page']
          @pulls = @query.pulls(:offset => @pull_pages.offset, :limit => @pull_pages.per_page)
          render :layout => !request.xhr?
        }
        format.api  {
          @offset, @limit = api_offset_and_limit
          @query.column_names = %w(author)
          @pull_count = @query.pull_count
          @pulls = @query.pulls(:offset => @offset, :limit => @limit)
          Issue.load_visible_relations(@pulls) if include_in_api_response?('relations')
        }
      end
    else
      respond_to do |format|
        format.html { render :layout => !request.xhr? }
        format.any(:atom, :csv, :pdf) { head 422 }
        format.api { render_validation_errors(@query) }
      end
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def new
    @pull = Pull.new
    @pull.project = @project

    @priorities = IssuePriority.active
  end

  def create
    unless User.current.allowed_to?(:add_pulls, @pull.project, :global => true)
      raise ::Unauthorized
    end

    if @pull.save
      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_pull_successful_create, :id => view_context.link_to("##{@pull.id}", pull_path(@pull), :title => @pull.subject))

          if params[:continue]
            url_params = {}
            url_params[:back_url] = params[:back_url].presence

            redirect_to _new_project_pull_path(@project, url_params)
          else
            redirect_back_or_default pull_path(@pull)
          end
        }
        format.api  { render :action => 'show', :status => :created, :location => pull_path(@pull) }
      end
      return
    else
      respond_to do |format|
        format.html {
          if @pull.project.nil?
            render_error :status => 422
          else
            render :action => 'new'
          end
        }
        format.api  { render_validation_errors(@pull) }
      end
    end
  end

  def show
    puts "SHOW"
  end

  def edit
    # TODO
  end

  def update
    # TODO
  end

  def destroy
    raise Unauthorized unless @pull.deletable?

    @pull.destroy

    flash[:notice] = l(:notice_pull_successful_delete)

    respond_to do |format|
      format.html { redirect_back_or_default _project_pulls_path(@project) }
      format.api  { render_api_ok }
    end
  end

  def preview
    @pull = Pull.visible.find_by_id(params[:id]) unless params[:id].blank?

    if @pull
      @description = params[:pull] && params[:pull][:description]

      if @description && @description.gsub(/(\r?\n|\n\r?)/, "\n") == @pull.description.to_s.gsub(/(\r?\n|\n\r?)/, "\n")
        @description = nil
      end

      #@notes = params[:journal] ? params[:journal][:notes] : nil
      #@notes ||= params[:pull] ? params[:pull][:notes] : nil
    else
      @description = (params[:pull] ? params[:pull][:description] : nil)
    end

    render :layout => false
  end

  def find_pull
    @pull = Pull.find(params[:id])
    @project = @pull.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def ensure_project_has_repository
    if @project && ! @project.repository
      render :template => 'pulls/no_repository'
    end
  end

  def build_new_pull_from_params
    @pull = Pull.new
    @pull.project = @project
    @pull.author ||= User.current
    @pull.repository ||= @project.repository

    attrs = (params[:pull] || {}).deep_dup
    @pull.safe_attributes = attrs

    @priorities = IssuePriority.active
  end
end
