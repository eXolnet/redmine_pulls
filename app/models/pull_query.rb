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
    QueryColumn.new(:created_on, :sortable => "#{Pull.table_name}.created_on", :default_order => 'desc'),
    QueryColumn.new(:updated_on, :sortable => "#{Pull.table_name}.updated_on", :default_order => 'desc'),
    QueryColumn.new(:closed_on, :sortable => "#{Pull.table_name}.closed_on", :default_order => 'desc'),
    QueryColumn.new(:category, :sortable => "#{IssueCategory.table_name}.name", :groupable => true),
    QueryColumn.new(:description, :inline => false)
  ]

  def initialize(attributes=nil, *args)
    super attributes
    self.filters ||= { 'closed_on' => {:operator => "!*", :values => [""]} }
  end

  def initialize_available_filters
    add_available_filter"project_id",
      :type => :list, :values => lambda { project_values } if project.nil?

    add_available_filter "priority_id",
      :type => :list, :values => IssuePriority.all.collect{|s| [s.name, s.id.to_s] }

    add_available_filter"author_id",
      :type => :list, :values => lambda { author_values }

    add_available_filter("assigned_to_id",
      :type => :list_optional, :values => lambda { assigned_to_values }
    )

    add_available_filter "category_id",
      :type => :list_optional,
      :values => lambda { project.issue_categories.collect{|s| [s.name, s.id.to_s] } } if project

    add_available_filter "subject", :type => :text
    add_available_filter "description", :type => :text
    add_available_filter "created_on", :type => :date_past
    add_available_filter "updated_on", :type => :date_past
    add_available_filter "merged_on", :type => :date_past
    add_available_filter "closed_on", :type => :date_past
  end

  # Returns true if the query is visible to +user+ or the current user.
  def visible?(user=User.current)
    true
  end

  def default_columns_names
    @default_columns_names = [:id, :priority, :subject, :author, :updated_on]
  end

  def default_sort_criteria
    [['id', 'desc']]
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

    scope = scope.preload([:author, :assigned_to, :category] & columns.map(&:name))

    scope.to_a
  rescue ::ActiveRecord::StatementInvalid => e
    raise StatementInvalid.new(e.message)
  end
end
