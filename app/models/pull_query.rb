class PullQuery < Query
  self.queried_class = Pull
  self.view_permission = :view_pulls

  self.available_columns = [
    QueryColumn.new(:id, :sortable => "#{Pull.table_name}.id", :default_order => 'desc', :caption => :label_pull_id),
    QueryColumn.new(:project, :groupable => "#{Pull.table_name}.project_id", :sortable => "#{Project.table_name}.id"),
    QueryColumn.new(:priority, :sortable => "#{IssuePriority.table_name}.position", :default_order => 'desc', :groupable => true),
    QueryColumn.new(:subject, :sortable => "#{Pull.table_name}.subject"),
    QueryColumn.new(:assigned_to, :sortable => lambda {User.fields_for_order_statement}, :groupable => "#{Pull.table_name}.assigned_to_id"),
    QueryColumn.new(:author, :sortable => lambda {User.fields_for_order_statement("authors")}, :groupable => true),
    QueryColumn.new(:assigned_to, :sortable => lambda {User.fields_for_order_statement}, :groupable => true),
    QueryColumn.new(:updated_on, :sortable => "#{Pull.table_name}.updated_on", :default_order => 'desc'),
    QueryColumn.new(:category, :sortable => "#{IssueCategory.table_name}.name", :groupable => true),
    QueryColumn.new(:fixed_version, :sortable => lambda {Version.fields_for_order_statement}, :groupable => true)
  ]

  def initialize(attributes=nil, *args)
    super attributes
    self.filters = {}
    #self.filters ||= { 'status_id' => {:operator => "o", :values => [""]} }
  end

  # Returns true if the query is visible to +user+ or the current user.
  def visible?(user=User.current)
    true
  end

  def default_columns_names
    @default_columns_names = [:id, :subject, :author, :updated_on]
  end

  def base_scope
    Pull.joins(:project).where(statement)
  end

  # Returns the pull request count
  def pull_count
    base_scope.count
  rescue ::ActiveRecord::StatementInvalid => e
    raise StatementInvalid.new(e.message)
  end

  # Returns the pull requests
  # Valid options are :order, :offset, :limit, :include, :conditions
  def pulls(options={})
    order_option = [group_by_sort_order, (options[:order] || sort_clause)].flatten.reject(&:blank?)

    scope = Pull.
      joins(:project).
      preload(:priority).
      where(statement).
      includes(([:project] + (options[:include] || [])).uniq).
      where(options[:conditions]).
      order(order_option).
      joins(joins_for_order_statement(order_option.join(','))).
      limit(options[:limit]).
      offset(options[:offset])

    scope = scope.preload([:author, :assigned_to, :fixed_version, :category] & columns.map(&:name))

    scope.to_a
  rescue ::ActiveRecord::StatementInvalid => e
    raise StatementInvalid.new(e.message)
  end
end
