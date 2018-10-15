class PullsController < ApplicationController
  default_search_scope :pulls
  menu_item :pulls

  before_action :find_pull, :only => [:show, :edit, :update, :destroy, :quoted]
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
  include PullsHelper
  helper :repositories
  helper :pull_reviewers

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
    respond_to do |format|
      format.html { render :action => 'new', :layout => !request.xhr? }
    end
  end

  def create
    raise Unauthorized unless User.current.allowed_to?(:add_pulls, @pull.project, :global => true)

    unless @pull.save
      return respond_to do |format|
        format.html { render :action => 'new' }
      end
    end

    # TODO - Move this to the Pull model
    calculate_pull_review_status(@pull)

    respond_to do |format|
      format.html {
        flash[:notice] = l(:notice_pull_successful_create, :id => view_context.link_to("##{@pull.id}", pull_path(@pull), :title => @pull.subject))

        if params[:continue]
          redirect_to _new_project_pull_path(@project, { :back_url => params[:back_url].presence })
        else
          redirect_back_or_default pull_path(@pull)
        end
      }
    end
  end

  def show
    RedminePulls::Services::RefreshService.new(@pull).execute

    @journals = @pull.visible_journals_with_index

    if User.current.wants_comments_in_reverse_order?
      @journals.reverse!
    end

    @diff_type = get_pull_diff_type

    respond_to do |format|
      format.html {
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
    raise Unauthorized unless User.current.allowed_to?(:add_pulls, @project)

    @kind = params[:kind] || 'base'
  end

  def preview
    @pull        = Pull.find_by_id(params[:id]) unless params[:id].blank?
    @description = params[:pull] && params[:pull][:description]

    if @pull
      raise Unauthorized unless @pull.editable? || @pull.notes_addable?

      if @description && @description.gsub(/(\r?\n|\n\r?)/, "\n") == @pull.description.to_s.gsub(/(\r?\n|\n\r?)/, "\n")
        @description = nil
      end

      @notes   = params[:journal] ? params[:journal][:notes] : nil
      @notes ||= params[:pull] ? params[:pull][:notes] : nil
    end

    render :layout => false
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def quoted
    raise Unauthorized unless @pull.notes_addable?

    user = @pull.author
    text = @pull.description

    # Replaces pre blocks with [...]
    text = text.to_s.strip.gsub(%r{<pre>(.*?)</pre>}m, '[...]')
    @content = "#{ll(Setting.default_language, :text_user_wrote, user)}\n> "
    @content << text.gsub(/(\r?\n|\r\n?)/, "\n> ") + "\n\n"

    render :template => 'journals/new'
  end

  private

  def build_new_pull_from_params
    @pull = Pull.new
    @pull.project = @project
    @pull.author ||= User.current
    @pull.repository ||= @project.repository

    default_branch = @pull.repository.scm.default_branch
    @pull.commit_base = default_branch
    @pull.commit_head = default_branch

    attrs = (params[:pull] || {}).deep_dup
    @pull.safe_attributes = attrs
  end

  def build_pull_params_for_update
    pull_attributes = (params[:pull] || {}).deep_dup

    if pull_attributes && params[:conflict_resolution]
      case params[:conflict_resolution]
      when 'overwrite'
        pull_attributes.delete(:lock_version)
      when 'add_notes'
        pull_attributes = pull_attributes.slice(:notes, :private_notes)
      when 'cancel'
        return nil
      end
    end

    pull_attributes
  end

  # Used by #edit and #update to set some common instance variables
  # from the params
  def update_pull_from_params
    raise ::Unauthorized unless @pull.editable?

    pull_attributes = build_pull_params_for_update

    if pull_attributes.nil?
      redirect_to pull_path(@pull)
      return false
    end

    @pull.init_journal(User.current)
    @pull.safe_attributes = pull_attributes

    if params[:review_status]
      review = @pull.review
      review.status = params[:review_status]
    end

    true
  end

  # Saves @pull from the parameters
  def save_pull
    Pull.transaction do
      call_hook(:controller_pulls_edit_before_save, { :params => params, :pull => @pull, :journal => @pull.current_journal})

      raise ActiveRecord::Rollback unless @pull.save

      call_hook(:controller_pulls_edit_after_save, { :params => params, :pull => @pull, :journal => @pull.current_journal})

      execute_pull_actions

      true
    end
  end

  def execute_pull_actions
    if params[:merge]
      merge_pull(@pull)

      flash[:notice] = l(:notice_pull_successful_merge)
    elsif params[:close]
      @pull.close

      flash[:notice] = l(:notice_pull_successful_close)
    elsif params[:reopen]
      @pull.reopen

      flash[:notice] = l(:notice_pull_successful_reopen)
    elsif params[:delete_branch] && @pull.head_branch_deletable? && @pull.commitable?
      @pull.delete_head_branch

      flash[:notice] = l(:notice_pull_branch_successful_delete)
    end
  end
end
