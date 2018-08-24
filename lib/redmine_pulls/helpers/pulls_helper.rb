module RedminePulls
  module Helpers
    def retrieve_pull_query
      if !params[:query_id].blank?
        cond = "project_id IS NULL"
        cond << " OR project_id = #{@project.id}" if @project
        @query = PullQuery.where(cond).find(params[:query_id])
        raise ::Unauthorized unless @query.visible?
        @query.project = @project
        session[:pull_query] = {:id => @query.id, :project_id => @query.project_id}
        sort_clear
      elsif true || api_request? || params[:set_filter] || session[:pull_query].nil? || session[:pull_query][:project_id] != (@project ? @project.id : nil)
        @query = PullQuery.new(:name => "_")
        @query.project = @project
        @query.build_from_params(params)
        session[:query] = {:project_id => @query.project_id,
                           :filters => @query.filters,
                           :group_by => @query.group_by,
                           :column_names => @query.column_names}
      else
        # retrieve from session
        @query = nil
        @query ||= PullQuery.find_by_id(session[:pull_query][:id]) if session[:pull_query][:id]
        @query ||= PullQuery.new(:name => "_",
                                  :filters => session[:pull_query][:filters],
                                  :group_by => session[:pull_query][:group_by],
                                  :column_names => session[:pull_query][:column_names])
        @query.project = @project
      end
    end
  end
end
