require File.expand_path('../../test_helper', __FILE__)

class PullsControllerTest < ActionController::TestCase
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :enabled_modules,
           :enumerations,
           :repositories,
           :changesets,
           :changes,
           :pulls

  def setup
    @project1 = Project.find(1)
    @project2 = Project.find(5)
    EnabledModule.create(:project => @project1, :name => 'pulls')
    EnabledModule.create(:project => @project2, :name => 'pulls')
    @request.session[:user_id] = 1

    Repository.any_instance.stubs(:default_branch).returns('master')
  end

  def test_get_index_without_project
    compatible_request :get, :index

    assert_response :success
  end

  def test_get_index_with_project
    compatible_request :get, :index, :project_id => 'ecookbook'

    assert_response :success
  end

  def test_get_new
    compatible_request :get, :new, :project_id => 'ecookbook'

    assert_response :success
  end

  def test_post_create
    Repository.any_instance.stubs(:branches).returns(['master', 'feature/not-merged'])
    Repository.any_instance.stubs(:revision).with('feature/not-merged').returns('0622573968bb7dcd4602c7200e835176d2203ce4')
    Repository.any_instance.stubs(:merge_base).with('master', 'feature/not-merged').returns('2ec457ef43fec4dbe1452cca82bf5c08c0bfe370')

    assert_difference 'Pull.count' do
      compatible_request :post, :create, :project_id => 'ecookbook',
        :pull => {
          :commit_base => 'master',
          :commit_head => 'feature/not-merged',
          :subject => 'Subject',
          :description => 'Description',
          :priority_id => 4,
          :assigned_to_id => 2,
          :category_id => 1,
          :fixed_version_id => 4,
          :reviewer_ids => ['2'],
          :watcher_user_ids => ['2', '3'],
        }

        assert_response 302
    end

    pull = Pull.order('id DESC').first
    assert_equal 'master', pull.commit_base
    assert_equal 'feature/not-merged', pull.commit_head
    assert_equal 'Subject', pull.subject
    assert_equal 'Description', pull.description
    assert_equal 4, pull.priority_id
    assert_equal 2, pull.assigned_to_id
    assert_equal 1, pull.category_id
    assert_equal 4, pull.fixed_version_id
    assert_equal [2], pull.reviewer_ids.sort
    assert_equal [2, 3], pull.watcher_user_ids.sort
  end

  def test_get_new_with_pull_request_template
    Repository.any_instance.stubs(:cat).returns('Pull request template example')

    compatible_request :get, :new, :project_id => 'ecookbook'

    assert_response :success
    assert_select '#pull_description', :text => /Pull request template example/
  end

  #def test_show_with_repository
  #  compatible_request get, :show, :id => 1
  #
  #  assert_response :success
  #  assert_select '#content .warning', false, :text => /This pull request’s repository is missing/
  #end

  def test_show_with_repository_deleted
    compatible_request :get, :show, :id => 2

    assert_response :success
    assert_select '#content .warning', :text => /This pull request’s repository is missing/
  end
end
