class PullsController < ApplicationController
  default_search_scope :pulls
  menu_item :pulls

  before_action :find_optional_project, :only => [:index, :new, :create]
  before_action :build_new_pull_from_params, :only => [:new, :create]

  rescue_from Query::StatementInvalid, :with => :query_statement_invalid

  helper :projects
  helper :watchers
  helper :queries
  include QueriesHelper
  helper :repositories

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
    # TODO
  end

  def show
    # TODO
  end

  def edit
    # TODO
  end

  def update
    # TODO
  end

  def destroy
    # TODO
  end

  def build_new_pull_from_params
    @pull = Pull.new
    @pull.project = @project
    @pull.author ||= User.current

    @priorities = IssuePriority.active
  end
end
