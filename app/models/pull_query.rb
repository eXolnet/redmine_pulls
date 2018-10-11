class PullQuery < Query
  MERGE_OPTIONS = %w(conflicts_detected can_be_merged cannot_be_merged)
  REVIEW_OPTIONS = %w{no_review review_requested approved_review changes_requested reviewed_by_you awaiting_review_from_you}

  self.queried_class = Pull
  self.view_permission = :view_pulls

  self.available_columns = [
    QueryColumn.new(:id, :sortable => "#{Pull.table_name}.id", :default_order => 'desc', :caption => :label_pull_id),
    QueryColumn.new(:project, :groupable => "#{Pull.table_name}.project_id", :sortable => "#{Project.table_name}.id"),
    QueryColumn.new(:priority, :sortable => "#{IssuePriority.table_name}.position", :default_order => 'desc', :groupable => true),
    QueryColumn.new(:subject, :sortable => "#{Pull.table_name}.subject"),
    QueryColumn.new(:author, :sortable => lambda {User.fields_for_order_statement("authors")}, :groupable => true),
    QueryColumn.new(:assigned_to, :sortable => lambda {User.fields_for_order_statement}, :groupable => true),
    QueryColumn.new(:created_on, :sortable => "#{Pull.table_name}.created_on", :default_order => 'desc'),
    QueryColumn.new(:updated_on, :sortable => "#{Pull.table_name}.updated_on", :default_order => 'desc'),
    QueryColumn.new(:merged_on, :sortable => "#{Pull.table_name}.merged_on", :default_order => 'desc'),
    QueryColumn.new(:closed_on, :sortable => "#{Pull.table_name}.closed_on", :default_order => 'desc'),
    QueryColumn.new(:category, :sortable => "#{IssueCategory.table_name}.name", :groupable => true),
    QueryColumn.new(:fixed_version, :sortable => lambda {Version.fields_for_order_statement}, :groupable => true),
    QueryColumn.new(:last_updated_by, :sortable => lambda {User.fields_for_order_statement("last_journal_user")}),
    QueryColumn.new(:description, :inline => false),
    QueryColumn.new(:last_notes, :caption => :label_last_notes, :inline => false)
  ]

  def initialize(attributes=nil, *args)
    super attributes
    self.filters ||= { 'status' => {:operator => "=", :values => ["opened"]} }
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

    add_available_filter("member_of_group",
                         :type => :list_optional, :values => lambda { Group.givable.visible.collect {|g| [g.name, g.id.to_s] } }
    )

    add_available_filter("assigned_to_role",
                         :type => :list_optional, :values => lambda { Role.givable.collect {|r| [r.name, r.id.to_s] } }
    )

    add_available_filter "fixed_version_id",
                         :type => :list_optional, :values => lambda { fixed_version_values }

    add_available_filter "fixed_version.due_date",
                         :type => :date,
                         :name => l(:label_attribute_of_fixed_version, :name => l(:field_effective_date))

    add_available_filter "fixed_version.status",
                         :type => :list,
                         :name => l(:label_attribute_of_fixed_version, :name => l(:field_status)),
                         :values => Version::VERSION_STATUSES.map{|s| [l("version_status_#{s}"), s] }

    add_available_filter "category_id",
                        :type => :list_optional,
                        :values => lambda { project.issue_categories.collect{|s| [s.name, s.id.to_s] } } if project

    add_available_filter"status",
                        :type => :list,
                        :values => lambda { pull_state_labels(:status) }

    add_available_filter"merge_status",
                        :type => :list,
                        :values => MERGE_OPTIONS.map{|s| [l("label_merge_status_#{s}"), s] }

    add_available_filter"review",
                        :type => :list,
                        :values => REVIEW_OPTIONS.map{|s| [l("label_review_#{s}"), s] }

    add_available_filter "subject", :type => :text
    add_available_filter "description", :type => :text
    add_available_filter "commit_base", :type => :text
    add_available_filter "commit_head", :type => :text
    add_available_filter "created_on", :type => :date_past
    add_available_filter "updated_on", :type => :date_past
    add_available_filter "merged_on", :type => :date_past
    add_available_filter "closed_on", :type => :date_past

    if User.current.logged?
      add_available_filter "watcher_id",
                           :type => :list, :values => [["<< #{l(:label_me)} >>", "me"]]
    end

    add_available_filter("updated_by",
                         :type => :list, :values => lambda { author_values }
    )

    add_available_filter("last_updated_by",
                         :type => :list, :values => lambda { author_values }
    )

    if project && !project.leaf?
      add_available_filter "subproject_id",
                           :type => :list_subprojects,
                           :values => lambda { subproject_values }
    end

    add_associations_custom_fields_filters :project, :author, :assigned_to, :fixed_version
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
    if has_custom_field_column?
      scope = scope.preload(:custom_values)
    end

    pulls = scope.to_a

    if has_column?(:last_updated_by)
      Pull.load_visible_last_updated_by(pulls)
    end
    if has_column?(:last_notes)
      Pull.load_visible_last_notes(pulls)
    end

    pulls
  rescue ::ActiveRecord::StatementInvalid => e
    raise StatementInvalid.new(e.message)
  end

  def sql_for_review_field(field, operator, value)
    neg = (operator == '!' ? 'NOT' : '')

    subqueries = value.collect do |v|
      subquery = "SELECT 1 FROM #{PullReview.table_name}" +
        " WHERE #{PullReview.table_name}.pull_id = #{Pull.table_name}.id"

      if v == 'no_review'
        return sql_for_field field, operator, ['unreviewed'], Pull.table_name, 'review_status'
      elsif v == 'review_requested'
        subquery  << " AND #{PullReview.table_name}.status = 'requested'"
      elsif v == 'approved_review'
        return sql_for_field field, operator, ['approved'], Pull.table_name, 'review_status'
      elsif v == 'changes_requested'
        return sql_for_field field, operator, ['concerned'], Pull.table_name, 'review_status'
      elsif v == 'reviewed_by_you'
        subquery  << " AND #{PullReview.table_name}.status <> 'requested'"
        subquery  << Pull.send(:sanitize_sql_for_conditions, [" AND #{PullReview.table_name}.reviewer_id = ?", User.current.id])
      elsif v == 'awaiting_review_from_you'
        subquery  << " AND #{PullReview.table_name}.status = 'requested'"
        subquery  << Pull.send(:sanitize_sql_for_conditions, [" AND #{PullReview.table_name}.reviewer_id = ?", User.current.id])
      end

      "#{neg} EXISTS (#{subquery})"
    end

    "(#{subqueries.join(' OR ')})"
  end

  def sql_for_updated_by_field(field, operator, value)
    neg = (operator == '!' ? 'NOT' : '')
    subquery = "SELECT 1 FROM #{Journal.table_name}" +
      " WHERE #{Journal.table_name}.journalized_type='Pull' AND #{Journal.table_name}.journalized_id=#{Pull.table_name}.id" +
      " AND (#{sql_for_field field, '=', value, Journal.table_name, 'user_id'})" +
      " AND (#{Journal.visible_notes_condition(User.current, :skip_pre_condition => true)})"

    "#{neg} EXISTS (#{subquery})"
  end

  def sql_for_last_updated_by_field(field, operator, value)
    neg = (operator == '!' ? 'NOT' : '')
    subquery = "SELECT 1 FROM #{Journal.table_name} sj" +
      " WHERE sj.journalized_type='Pull' AND sj.journalized_id=#{Pull.table_name}.id AND (#{sql_for_field field, '=', value, 'sj', 'user_id'})" +
      " AND sj.id = (SELECT MAX(#{Journal.table_name}.id) FROM #{Journal.table_name}" +
      "   WHERE #{Journal.table_name}.journalized_type='Pull' AND #{Journal.table_name}.journalized_id=#{Pull.table_name}.id" +
      "   AND (#{Journal.visible_notes_condition(User.current, :skip_pre_condition => true)}))"

    "#{neg} EXISTS (#{subquery})"
  end

  def sql_for_watcher_id_field(field, operator, value)
    db_table = Watcher.table_name
    "#{Pull.table_name}.id #{ operator == '=' ? 'IN' : 'NOT IN' } (SELECT #{db_table}.watchable_id FROM #{db_table} WHERE #{db_table}.watchable_type='Pull' AND " +
      sql_for_field(field, '=', value, db_table, 'user_id') + ')'
  end

  def sql_for_member_of_group_field(field, operator, value)
    if operator == '*' # Any group
      groups = Group.givable
      operator = '=' # Override the operator since we want to find by assigned_to
    elsif operator == "!*"
      groups = Group.givable
      operator = '!' # Override the operator since we want to find by assigned_to
    else
      groups = Group.where(:id => value).to_a
    end
    groups ||= []

    members_of_groups = groups.inject([]) {|user_ids, group|
      user_ids + group.user_ids + [group.id]
    }.uniq.compact.sort.collect(&:to_s)

    '(' + sql_for_field("assigned_to_id", operator, members_of_groups, Pull.table_name, "assigned_to_id", false) + ')'
  end

  def sql_for_assigned_to_role_field(field, operator, value)
    case operator
    when "*", "!*" # Member / Not member
      sw = operator == "!*" ? 'NOT' : ''
      nl = operator == "!*" ? "#{Pull.table_name}.assigned_to_id IS NULL OR" : ''
      "(#{nl} #{Pull.table_name}.assigned_to_id #{sw} IN (SELECT DISTINCT #{Member.table_name}.user_id FROM #{Member.table_name}" +
        " WHERE #{Member.table_name}.project_id = #{Pull.table_name}.project_id))"
    when "=", "!"
      role_cond = value.any? ?
                    "#{MemberRole.table_name}.role_id IN (" + value.collect{|val| "'#{self.class.connection.quote_string(val)}'"}.join(",") + ")" :
                    "1=0"

      sw = operator == "!" ? 'NOT' : ''
      nl = operator == "!" ? "#{Pull.table_name}.assigned_to_id IS NULL OR" : ''
      "(#{nl} #{Pull.table_name}.assigned_to_id #{sw} IN (SELECT DISTINCT #{Member.table_name}.user_id FROM #{Member.table_name}, #{MemberRole.table_name}" +
        " WHERE #{Member.table_name}.project_id = #{Pull.table_name}.project_id AND #{Member.table_name}.id = #{MemberRole.table_name}.member_id AND #{role_cond}))"
    end
  end

  def sql_for_fixed_version_field(db_field, field, operator, value)
    where = sql_for_field(field, operator, value, Version.table_name, db_field)
    version_ids = versions(:conditions => [where]).map(&:id)

    nl = operator == "!" ? "#{Pull.table_name}.fixed_version_id IS NULL OR" : ''
    "(#{nl} #{sql_for_field("fixed_version_id", "=", version_ids, Pull.table_name, "fixed_version_id")})"
  end

  def sql_for_fixed_version_status_field(field, operator, value)
    sql_for_fixed_version_field("status", field, operator, value)
  end

  def sql_for_fixed_version_due_date_field(field, operator, value)
    sql_for_fixed_version_field("effective_date", field, operator, value)
  end

  def sql_for_updated_on_field(field, operator, value)
    case operator
    when "!*"
      "#{Pull.table_name}.updated_on = #{Pull.table_name}.created_on"
    when "*"
      "#{Pull.table_name}.updated_on > #{Pull.table_name}.created_on"
    else
      sql_for_field("updated_on", operator, value, Pull.table_name, "updated_on")
    end
  end

  def joins_for_order_statement(order_options)
    joins = [super]

    if order_options
      if order_options.include?('authors')
        joins << "LEFT OUTER JOIN #{User.table_name} authors ON authors.id = #{queried_table_name}.author_id"
      end
      if order_options.include?('users')
        joins << "LEFT OUTER JOIN #{User.table_name} ON #{User.table_name}.id = #{queried_table_name}.assigned_to_id"
      end
      if order_options.include?('last_journal_user')
        joins << "LEFT OUTER JOIN #{Journal.table_name} ON #{Journal.table_name}.id = (SELECT MAX(#{Journal.table_name}.id) FROM #{Journal.table_name}" +
          " WHERE #{Journal.table_name}.journalized_type='Pull' AND #{Journal.table_name}.journalized_id=#{Pull.table_name}.id AND #{Journal.visible_notes_condition(User.current, :skip_pre_condition => true)})" +
          " LEFT OUTER JOIN #{User.table_name} last_journal_user ON last_journal_user.id = #{Journal.table_name}.user_id";
      end
      if order_options.include?('versions')
        joins << "LEFT OUTER JOIN #{Version.table_name} ON #{Version.table_name}.id = #{queried_table_name}.fixed_version_id"
      end
      if order_options.include?('issue_categories')
        joins << "LEFT OUTER JOIN #{IssueCategory.table_name} ON #{IssueCategory.table_name}.id = #{queried_table_name}.category_id"
      end
      if order_options.include?('enumerations')
        joins << "LEFT OUTER JOIN #{IssuePriority.table_name} ON #{IssuePriority.table_name}.id = #{queried_table_name}.priority_id"
      end
    end

    joins.any? ? joins.join(' ') : nil
  end

  private

  def pull_state_labels(field)
    Pull.state_machines[field].states.collect do |s|
      label = l(("label_"+ (field.to_s) +"_" + s.name.to_s).to_sym)

      [ label, s.name ]
    end
  end
end
