class PullsController < ApplicationController
  default_search_scope :pulls
  menu_item :pulls

  before_action :find_pull, :only => [:show, :edit, :update, :destroy]
  before_action :find_optional_project, :only => [:index, :new, :create, :commit]
  before_action :ensure_project_has_repository
  before_action :build_new_pull_from_params, :only => [:new, :create, :commit]

  rescue_from Query::StatementInvalid, :with => :query_statement_invalid

  helper :journals
  helper :projects
  helper :custom_fields
  helper :issues
  helper :watchers
  helper :queries
  include QueriesHelper
  helper :repositories
  helper :pull_reviewers
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
      end
    else
      respond_to do |format|
        format.html { render :layout => !request.xhr? }
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
      end
    end
  end

  def show
    @journals = @pull.visible_journals_with_index

    if User.current.wants_comments_in_reverse_order?
      @journals.reverse!
    end

    # Prepare diff
    @repository = @pull.repository
    @diff = @repository.diff(nil, @pull.commit_head, @pull.commit_base)
    @diff_type = params[:type] || User.current.pref[:diff_type] || 'inline'
    @diff_type = 'inline' unless %w(inline sbs).include?(@diff_type)
    @revision_ids = @repository.scm.revisions(nil, @pull.commit_base, @pull.commit_head).collect {|revision| revision.identifier}
    @revisions = @repository.changesets.where(revision: @revision_ids).all

    respond_to do |format|
      format.html {
        @priorities = IssuePriority.active
        render :template => 'pulls/show'
      }
    end
  end

  def edit
    return unless update_pull_from_params

    respond_to do |format|
      format.html { }
    end
  end

  def update
    return unless update_pull_from_params

    saved = false
    begin
      saved = save_pull
    rescue ActiveRecord::StaleObjectError
      @conflict = true

      if params[:last_journal_id]
        @conflict_journals = @pull.journals_after(params[:last_journal_id]).to_a
        @conflict_journals.reject!(&:private_notes?) unless User.current.allowed_to?(:view_private_notes, @pull.project)
      end
    end

    if saved
      flash[:notice] = l(:notice_successful_update) unless @pull.current_journal.new_record?

      respond_to do |format|
        format.html { redirect_back_or_default pull_path(@pull) }
        format.api  { render_api_ok }
      end
    else
      respond_to do |format|
        format.html { render :action => 'edit' }
        format.api  { render_validation_errors(@pull) }
      end
    end
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

  def commit
    @kind = params[:kind] || 'base'
  end

  def preview
    @pull = Pull.find_by_id(params[:id]) unless params[:id].blank?

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

  private

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

  # Used by #edit and #update to set some common instance variables
  # from the params
  def update_pull_from_params
    @pull.init_journal(User.current)

    pull_attributes = params[:pull]
    if pull_attributes && params[:conflict_resolution]
      case params[:conflict_resolution]
        when 'overwrite'
          pull_attributes = pull_attributes.dup
          pull_attributes.delete(:lock_version)
        when 'add_notes'
          pull_attributes = pull_attributes.slice(:notes, :private_notes)
        when 'cancel'
          redirect_to pull_path(@pull)
          return false
      end
    end

    @pull.safe_attributes = pull_attributes
    @priorities = IssuePriority.active

    if params[:merge]
      @pull.merged_on = Time.now
    elsif params[:close]
      @pull.closed_on = Time.now
    end

    if params[:review_status]
      review = @pull.review

      review.status = params[:review_status]
      review.save
    end

    true
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

  # Saves @pull from the parameters
  def save_pull
    Pull.transaction do
      call_hook(:controller_pulls_edit_before_save, { :params => params, :pull => @pull, :journal => @pull.current_journal})
      if @pull.save
        call_hook(:controller_pulls_edit_after_save, { :params => params, :pull => @pull, :journal => @pull.current_journal})
      else
        raise ActiveRecord::Rollback
      end
    end
  end
end
